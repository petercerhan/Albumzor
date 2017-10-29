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
            .distinctUntilChanged() { $0 == $1 }
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
            .distinctUntilChanged() { $0 == $1 }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentAlbumTracks: Observable<[TrackData]?> = {
       return self.albumTracksObservableQueue
            .map { tracksQueue -> Observable<[TrackData]?>? in
                return tracksQueue.elementAt(0)
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { $0 }
            .distinctUntilChanged() { lhs, rhs -> Bool in
                if let lhs = lhs, let rhs = rhs, lhs.count == rhs.count {
                    for (index, element) in lhs.enumerated() {
                        if element != rhs[index] {
                            return false
                        }
                    }
                    return true
                } else if lhs == nil, rhs == nil {
                    return true
                }
                return false
            }
            .shareReplay(1)
    }()
    
    private(set) lazy var likedAlbumArtistStream: Observable<ArtistData> = {
        return self.likedAlbumArtistSubject.asObservable()
    }()

    let showDetails = ReplaySubject<Bool>.create(bufferSize: 1)
    
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
                
                switch albumQueueEvent {
                case .addAlbum(let albumData, let artistData):
                    if
                        let albumArtObservable = self?.remoteDataService.fetchImageFrom(urlString: albumData.largeImage),
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
    
    //MARK: - Tracks Queue
    
    private lazy var albumTracksObservableQueue: Observable<InspectableQueue<Observable<[TrackData]?>>> = {
        
        return Observable.of(self.fetchAlbumProcess, self.nextAlbumSubject.asObservable()).merge()
            .scan(InspectableQueue<Observable<[TrackData]?>>()) { [weak self] (accumulator, albumQueueEvent) -> InspectableQueue<Observable<[TrackData]?>> in
                var tracksQueue = accumulator
                
                switch albumQueueEvent {
                case .addAlbum(let albumData, let artistData):
                    if
                        let tracksObservable = self?.getTracksForAlbum(albumData: albumData).shareReplay(1),
                        let disposeBag = self?.disposeBag
                    {
                        tracksObservable.subscribe().disposed(by: disposeBag)
                        tracksQueue.enqueue(tracksObservable.nextEventsOnly().shareReplay(1))
                    } else {
                        tracksQueue.enqueue(Observable<[TrackData]?>.just(nil).nextEventsOnly())
                    }
                case .nextAlbum:
                    _ = tracksQueue.dequeue()
                }
                
                return tracksQueue
            }
            .shareReplay(1)
        
    }()
    
    private func getTracksForAlbum(albumData: AlbumData) -> Observable<[TrackData]?> {
        let tracksStream = Observable<[TrackData]?>.create { [weak self] (observer) -> Disposable in
            observer.onNext(nil)
            
            guard let strongSelf = self else { return Disposables.create() }
            
            let savedTracksStream = strongSelf.localDatabaseService.getTracksForAlbum(albumData)
            
            //if there are tracks already in the data return those; otherwise fetch from remote datasource
            savedTracksStream
                .subscribe(onNext: { tracks in
                    if tracks.count > 0 {
                        observer.onNext(tracks)
                    } else {
                        fetchTracksFromRemoteDatasource()
                    }
                })
                .disposed(by: strongSelf.disposeBag)

            //remote datasource step 1
            func fetchTracksFromRemoteDatasource() {
                strongSelf.remoteDataService.fetchTracksForAlbum(album: albumData)
                    .subscribe(onNext: { abbreviatedTrackData in
                        fetchTrackDetailsFromRemoteDatasource(abbreviatedTrackData: abbreviatedTrackData)
                    })
                    .disposed(by: strongSelf.disposeBag)
            }
            
            //remote datasource step 2
            func fetchTrackDetailsFromRemoteDatasource(abbreviatedTrackData: [AbbreviatedTrackData]) {
                strongSelf.remoteDataService.fetchTrackDetails(tracks: abbreviatedTrackData)
                    .subscribe(onNext: { tracks in
                        observer.onNext(tracks)
                        strongSelf.localDatabaseService.save(tracks: tracks, forAlbum: albumData)
                    })
                    .disposed(by: strongSelf.disposeBag)
            }
            
            return Disposables.create()
        }
        
        return tracksStream
    }
    
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
        
        //For dev only
        albumTracksObservableQueue
            .subscribe(onNext: { _ in
//                print("Got some album tracks")
            })
            .disposed(by: disposeBag)
        //
        
        
        
        
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
    
    func showDetails(_ show: Bool) {
        showDetails.onNext(show)
    }
    
}




