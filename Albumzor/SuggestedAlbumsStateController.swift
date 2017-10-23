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
    
    //MARK: - State
    
    private(set) lazy var currentAlbum: Observable<AlbumData?> = {
        return self.suggestedAlbumQueue.asObservable()
            .map { queue -> AlbumData? in
                return queue.elementAt(0)?.0
            }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentArtist: Observable<ArtistData?> = {
        return self.suggestedAlbumQueue.asObservable()
            .map { queue -> ArtistData? in
                return queue.elementAt(0)?.1
            }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentAlbumArt: Observable<UIImage> = {
        return self.albumArtObservableQueue
            .map { albumArtQueue -> Observable<UIImage>? in
                return albumArtQueue.elementAt(0)
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { $0 }
            .shareReplay(1)
    }()
    
    //Artists Queue
    
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
            .share()
    }()
    
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
            .share()
    }()
    
    //Album Art Queue
    
    private let albumArtLoadingSubject = PublishSubject<ImageLoadState>()
    
    private lazy var albumArtObservableQueue: Observable<InspectableQueue<Observable<UIImage>>> = {
        return Observable
            .combineLatest(self.suggestedAlbumQueue, self.albumArtLoadingSubject.asObservable()) { return ($0, $1) }
            .scan(InspectableQueue<Observable<UIImage>>()) { [weak self] (accumulator, inputs) -> InspectableQueue<Observable<UIImage>> in
                var albumArtObservableQueue = accumulator
                let albumQueue = inputs.0
                let imageLoadState = inputs.1
                
                if albumQueue.count > albumArtObservableQueue.count,
                    imageLoadState == .notLoading,
                    let nextAlbum = albumQueue.elementAt(albumArtObservableQueue.count)?.0,
                    let albumArtObservable = self?.remoteDataService.fetchImageFrom(urlString: nextAlbum.largeImage),
                    let disposeBag = self?.disposeBag
                {
                    albumArtObservable.subscribe(
                        onError: { error in
                            self?.albumArtLoadingSubject.onNext(.notLoading)
                        }, onCompleted: {
                            self?.albumArtLoadingSubject.onNext(.notLoading)
                        })
                        .disposed(by: disposeBag)
                    
                    albumArtObservableQueue.enqueue(albumArtObservable.nextEventsOnly())
                }
                
                return albumArtObservableQueue
            }
        
    }()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(localDatabaseService: LocalDatabaseServiceProtocol, remoteDataService: RemoteDataServiceProtocol, shufflingService: ShufflingService) {
        self.localDatabaseService = localDatabaseService
        self.remoteDataService = remoteDataService
        self.shufflingService = shufflingService

        bindMonitors()
        getInitialArtists()
        albumArtLoadingSubject.onNext(.notLoading)
        
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
    
    enum ImageLoadState {
        case loading
        case notLoading
    }
    
    //MARK: - Interface
    
    func reviewAlbum(like: Bool) {
//        artistPoolEventSubject.onNext(.fetchAlbumForNextArtist)
        
        
    }
    
}



