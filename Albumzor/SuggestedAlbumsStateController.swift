//
//  SuggestedAlbumsStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/18/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class SuggestedAlbumsStateController {
    
    //MARK: - Dependencies
    
    private let localDatabaseService: LocalDatabaseServiceProtocol
    private let remoteDataService: RemoteDataServiceProtocol
    private let shufflingService: ShufflingService
    
    //MARK: - Exposed State
    
    private(set) lazy var currentAlbum: Observable<AlbumData?> = {
        return self.suggestedAlbumQueue.asObservable()
            .map { queue -> AlbumData? in
                return queue.elementAt(0)?.0
            }
            .distinctUntilChanged() { $0 == $1 }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentArtist: Observable<ArtistData?> = {
        return self.suggestedAlbumQueue.asObservable()
            .map { queue -> ArtistData? in
                return queue.elementAt(0)?.1
            }
            .distinctUntilChanged() { $0 == $1 }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentAlbumArt: Observable<UIImage?> = {
        return self.albumArtObservableQueue
            .map { albumArtQueue -> Observable<UIImage?>? in
                return albumArtQueue.elementAt(0)
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { $0 } 
            .shareReplay(1)
    }()
    
    private(set) lazy var nextAlbumArt: Observable<UIImage?> = {
        return self.albumArtObservableQueue
            .map { albumArtQueue -> Observable<UIImage?>? in
                return albumArtQueue.elementAt(1)
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { $0 }
            .shareReplay(1)
    }()
    
    private(set) lazy var likedAlbumArtistStream: Observable<ArtistData> = {
        return self.likedAlbumArtistSubject.asObservable()
    }()
    
    //MARK: - Artist Queue
    
    private let artistPoolEventSubject = PublishSubject<ArtistPoolEvent>()
    
    private lazy var currentArtistPool: Observable<(InspectableQueue<ArtistData>, FetchAlbumProcessEvent)> = {
        return self.artistPoolEventSubject.asObservable()
            .scan((InspectableQueue<ArtistData>(), .none)) { (accumulator, artistPoolEvent) -> (InspectableQueue<ArtistData>, FetchAlbumProcessEvent) in
                var currentArtistQueue = accumulator.0
                switch artistPoolEvent {
                case .addArtists(let newArtistData):
                    currentArtistQueue.enqueueUnique(elements: newArtistData)
                    return (currentArtistQueue, .none)
                 case .fetchAlbumForNextArtist:
                    guard let artist = currentArtistQueue.dequeue() else {
                        //potentially trigger something else here
                        return (currentArtistQueue, .none)
                    }
                    return (currentArtistQueue, .fetchAlbumForArtist(artist: artist))
                }
            }
            .shareReplay(1)
    }()
    
    //MARK: - Album Queue
    
    private lazy var fetchAlbumProcess: Observable<AlbumQueueEvent> = {
        return self.currentArtistPool
            .map { (_, albumProcessEvent) in
                return albumProcessEvent
            }
            .map { albumProcessEvent -> ArtistData? in
                switch albumProcessEvent {
                case .fetchAlbumForArtist(let artistData):
                    return artistData
                default:
                    return nil
                }
            }
            .filter { $0 != nil }
            .map { return $0! }
            .map { [unowned self] artistData -> Observable<(AlbumData, ArtistData)> in
                return self.localDatabaseService.getTopUnseenAlbumForArtist(artistData)
                    .nextEventsOnly()
            }
            .flatMap { return $0 }
            .map { (albumData, artistData) -> AlbumQueueEvent in
                return AlbumQueueEvent.addAlbum(albumData: albumData, artistData: artistData)
            }
            .share()
    }()
    
    private let nextAlbumSubject = PublishSubject<AlbumQueueEvent>()
    
    private lazy var suggestedAlbumQueue: Observable<InspectableQueue<(AlbumData, ArtistData)>> = {
        return Observable.of(self.fetchAlbumProcess, self.nextAlbumSubject.asObservable()).merge()
            .scan(InspectableQueue<(AlbumData, ArtistData)>()) { (accumulator, albumQueueEvent) -> InspectableQueue<(AlbumData, ArtistData)> in
                var albumQueue = accumulator
                
                switch albumQueueEvent {
                case .addAlbum(let albumData, let artistData):
                    albumQueue.enqueue((albumData, artistData))
                    return albumQueue
                case .nextAlbum:
                    _ = albumQueue.dequeue()
                    return albumQueue
                }
            }
            .shareReplay(1)
    }()
    
    //MARK: - Album Art Queue

    private lazy var albumArtObservableQueue: Observable<InspectableQueue<Observable<UIImage?>>> = {
        
        return Observable.of(self.fetchAlbumProcess, self.nextAlbumSubject.asObservable()).merge()
            .scan(InspectableQueue<Observable<UIImage?>>()) { [weak self] (accumulator, albumQueueEvent) -> InspectableQueue<Observable<UIImage?>> in
                var albumArtQueue = accumulator
                
//                print("In album art, album queue event \(albumQueueEvent)")
                
                switch albumQueueEvent {
                case .addAlbum(let albumData, let artistData):
                    if let albumArtObservable = self?.remoteDataService.fetchImageFrom(urlString: albumData.largeImage),
                        let disposeBag = self?.disposeBag
                    {
                        albumArtQueue.enqueue(albumArtObservable.nextEventsOnly().makeEventTypeOptional(initialValue: nil))
                    } else {
                        albumArtQueue.enqueue(Observable<UIImage?>.just(nil).nextEventsOnly())
                    }
                case .nextAlbum:
                    _ = albumArtQueue.dequeue()
                }
                
                return albumArtQueue
            }
            .shareReplay(1)
    }()
    
    //MARK: - Liked Albums
    
    private let likedAlbumArtistSubject = PublishSubject<ArtistData>()
    
    //Review Album
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(localDatabaseService: LocalDatabaseServiceProtocol, remoteDataService: RemoteDataServiceProtocol, shufflingService: ShufflingService) {
        self.localDatabaseService = localDatabaseService
        self.remoteDataService = remoteDataService
        self.shufflingService = shufflingService

        bindMonitors()
        getInitialArtists()
        
    }
    
    private func bindMonitors() {
        
        //Trigger album art observables
        albumArtObservableQueue
            .take(1)
            .subscribe()
            .disposed(by: disposeBag)
        
        //create first album fetch monitor
        currentArtistPool
            .map { (artistQueue, _) -> Int in
                return artistQueue.count
            }
            .filter { $0 > 0 }
            .take(1)
            .delay(RxTimeInterval(0.1), scheduler: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .subscribe(onNext: { [unowned self] _ in
                self.artistPoolEventSubject.onNext(.fetchAlbumForNextArtist)
            })
            .disposed(by: disposeBag)
        
        //ArtistPoolMonitor
        currentArtistPool
            .map { (artistQueue, _) -> Int in

//                print("\nUpdate artist queue \(artistQueue.count)\n")
//                for i in 0..<artistQueue.count {
//                    print("Artist \(artistQueue.elementAt(i)!.name)")
//                }

                return artistQueue.count
            }
            .filter { count in
                return count < 8
            }
            .map { [unowned self] _ -> Observable<[ArtistData]> in
                return self.localDatabaseService
                    .getArtistsByExposuresAndScore(max: 10)
                    .nextEventsOnly()
            }
            .flatMap { $0 }
            .map { [unowned self] artists -> [ArtistData] in
                return Array(self.shufflingService.shuffleArray(array: artists)[0...5])
            }
            .subscribe(onNext: { [unowned self] artists in
                self.artistPoolEventSubject.onNext(.addArtists(artists))
            })
            .disposed(by: disposeBag)

        //AlbumQueueMonitor
        suggestedAlbumQueue
            .map { queue -> Int in
                return queue.count
            }
            .filter { $0 < 10 }
            .subscribe(onNext: { [unowned self] _ in
                self.artistPoolEventSubject.onNext(.fetchAlbumForNextArtist)
            })
            .disposed(by: disposeBag)
        
    }
    
    //First step//
    private func getInitialArtists() {
        let artistsObservable = localDatabaseService.getArtistsByExposuresAndScore(max: 10)
        
        artistsObservable
            .subscribe(onNext: { [unowned self] artistsData in
                let shuffledArtistData = self.shufflingService.shuffleArray(array: artistsData)
                self.artistPoolEventSubject.onNext(ArtistPoolEvent.addArtists(shuffledArtistData))
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Process Event Types
    
    enum ArtistPoolEvent {
        case addArtists([ArtistData])
        case fetchAlbumForNextArtist
    }
    
    enum FetchAlbumProcessEvent {
        case fetchAlbumForArtist(artist: ArtistData)
        case none
    }
    
    enum AlbumQueueEvent {
        case addAlbum(albumData: AlbumData, artistData: ArtistData)
        case nextAlbum
    }
    
    //MARK: - Interface
    
    func reviewAlbum(liked: Bool) {
        //Update domain objects and persist
        let _ = Observable.just(liked)
            .withLatestFrom(suggestedAlbumQueue.asObservable()) { (liked, albumQueue) -> (Bool, InspectableQueue<(AlbumData, ArtistData)>) in
                return (liked, albumQueue)
            }
            .filter { (_, albumQueue) in
                return albumQueue.count > 0
            }
            .map { (liked, albumQueue) -> (Bool, AlbumData, ArtistData) in
                let albumAndArtist = albumQueue.elementAt(0)!
                return (liked, albumAndArtist.0, albumAndArtist.1)
            }
            .withLatestFrom(currentAlbumArt) { (data, albumArt) -> (Bool, AlbumData, ArtistData, UIImage?) in
                return (data.0, data.1, data.2, albumArt)
            }
           .subscribe(onNext: { [unowned self] data in
                let liked = data.0
                var albumData = data.1
                var artistData = data.2

                albumData.review(liked: liked)
                artistData.albumReviewed(liked: liked)
                if let image = data.3 {
                    albumData.imageData = UIImagePNGRepresentation(image)
                }

                self.localDatabaseService.save(album: albumData)
                self.localDatabaseService.save(artist: artistData)
            
                if liked {
                    self.likedAlbumArtistSubject.onNext(artistData)
                    self.getSmallImageData(forAlbum: albumData)
                }
            })
            .disposed(by: disposeBag)
        
        nextAlbumSubject.onNext(.nextAlbum)
    }
    
    private func getSmallImageData(forAlbum albumData: AlbumData) {
        let _ = remoteDataService.fetchImageFrom(urlString: albumData.smallImage)
            .subscribe(onNext: { [unowned self] image in
                var mutableAlbumData = albumData
                mutableAlbumData.smallImageData = UIImagePNGRepresentation(image)
                self.localDatabaseService.save(album: mutableAlbumData)
            })
            .disposed(by: disposeBag)
    }
    
}




