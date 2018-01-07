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
    
    typealias AlbumDataGroup = (ArtistData, Observable<AlbumData?>, Observable<UIImage?>, Observable<[TrackData]?>)
    typealias AlbumQueue = InspectableQueue<AlbumDataGroup>

    //MARK: - Dependencies
    
    private let localDatabaseService: LocalDatabaseServiceProtocol
    private let remoteDataService: RemoteDataServiceProtocol
    private let shufflingService: ShufflingService
    
    //MARK: - Readable State
    
    private(set) lazy var currentAlbum: Observable<AlbumData?> = {
        return self.albumQueue_firstPositionUpdates
            .map { queue -> Observable<AlbumData?>? in
                return queue.elementAt(0)?.1
            }
            .filter { $0 != nil}
            .map { $0! }
            .flatMapLatest { $0 }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentArtist: Observable<ArtistData?> = {
        return self.albumQueue_firstPositionUpdates
            .map { queue -> ArtistData? in
                return queue.elementAt(0)?.0
            }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentAlbumArt: Observable<UIImage?> = {
        return self.albumQueue_firstPositionUpdates
            .map { queue -> Observable<UIImage?>? in
                return queue.elementAt(0)?.2
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { $0 }
            .shareReplay(1)
    }()
    
    private(set) lazy var nextAlbumArt: Observable<UIImage?> = {
        return self.albumQueue_secondPositionUpdates
            .map { queue -> Observable<UIImage?>? in
                return queue.elementAt(1)?.2
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { $0 }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentAlbumTracks: Observable<[TrackData]?> = {
        return self.albumQueue_firstPositionUpdates
            .map { queue -> Observable<[TrackData]?>? in
                return queue.elementAt(0)?.3
            }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { $0 }
            .shareReplay(1)
    }()
    
    private(set) lazy var likedAlbumArtistStream: Observable<ArtistData> = {
        return self.likedAlbumArtistSubject.asObservable()
    }()

    let showDetails = ReplaySubject<Bool>.create(bufferSize: 1)
    
    //MARK: - Album Queue
    
    private let albumQueueEventSubject = PublishSubject<AlbumQueueEvent>()
    
    private lazy var albumQueue: Observable<AlbumQueue> = {
        return self.albumQueueEventSubject.asObservable()
            .scan(AlbumQueue()) { [weak self] (accumulator, event) -> AlbumQueue in
                var albumQueue = accumulator
                
                switch event {
                case .enqueue(let dataGroup):
                    let artistName = dataGroup.0.name
                    var shouldEnqueue = true

                    for i in 0..<albumQueue.count {
                        if albumQueue.elementAt(i)!.0 == dataGroup.0 {
                            shouldEnqueue = false
                        }
                    }
                    if shouldEnqueue {
                        albumQueue.enqueue(dataGroup)
                    }
                    
                    if albumQueue.count < 5 {
                        self?.fetchNewAlbumDataGroup()
                    }
                    
                case .dequeue:
                    _ = albumQueue.dequeue()
                    self?.fetchNewAlbumDataGroup()
                }

                return albumQueue
            }
            .share()
    }()
    
    private lazy var albumQueue_firstPositionUpdates: Observable<AlbumQueue> = {
        return self.albumQueue
            .distinctUntilChanged() { lhs, rhs -> Bool in
                if lhs.count == 1 && rhs.count == 0 {
                    return true
                }
                guard let left = lhs.elementAt(0), let right = rhs.elementAt(0) else {
                    return false
                }
                return left.0 == right.0
            }
            .shareReplay(1)
    }()
    
    private lazy var albumQueue_secondPositionUpdates: Observable<AlbumQueue> = {
        return self.albumQueue
            .distinctUntilChanged() { lhs, rhs -> Bool in
                if lhs.count == 1 && rhs.count == 2 {
                    return true
                }
                guard let left = lhs.elementAt(1), let right = rhs.elementAt(1) else {
                    return false
                }
                return left.0 == right.0
            }
    }()
    
    //MARK: - Liked Albums
    
    private let likedAlbumArtistSubject = PublishSubject<ArtistData>()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(localDatabaseService: LocalDatabaseServiceProtocol, remoteDataService: RemoteDataServiceProtocol, shufflingService: ShufflingService) {
        
        print("Suggested Album State Controller Init")
        
        self.localDatabaseService = localDatabaseService
        self.remoteDataService = remoteDataService
        self.shufflingService = shufflingService
        
        fetchNewAlbumDataGroup()
        albumQueue.subscribe().disposed(by: disposeBag)
    }
    
    //TEMP
    deinit {
        print("Suggested Album State Controller Deinit")
    }
    
    //MARK: - Album Queue Methods

    private func fetchNewAlbumDataGroup() {
        localDatabaseService.getArtistsByExposuresAndScore(max: 10)
            .subscribe(onNext: { [unowned self] artistsData in
                let strongSelf = self
                let shuffledArtistData = self.shufflingService.shuffleArray(array: artistsData)
                let artistData = shuffledArtistData[0]
                
                let albumDataObservable: Observable<AlbumData> = self.localDatabaseService.getTopUnseenAlbumForArtist(artistData)
                    .map { data -> AlbumData in
                        return data.0
                    }
                    .shareReplay(1)
                
                let albumArtObservable = albumDataObservable
                    .map { [weak strongSelf] albumData -> Observable<UIImage?> in
                        guard let strongSelf = strongSelf else {
                            let emptyObservable: Observable<UIImage?> = Observable.just(nil)
                            return emptyObservable
                        }
                        return strongSelf.remoteDataService.fetchImageFrom(urlString: albumData.largeImage)
                            .makeEventTypeOptional(initialValue: nil)
                    }
                    .flatMap { $0 }
                    .shareReplay(1)

                let tracksObservable = albumDataObservable
                    .map { [weak strongSelf] albumData -> Observable<[TrackData]?> in
                        guard let strongSelf = strongSelf else {
                            let emptyObservable: Observable<[TrackData]?> = Observable.just(nil)
                            return emptyObservable
                        }
                        return strongSelf.getTracksForAlbum(albumData: albumData)
                    }
                    .flatMap { $0 }
                    .shareReplay(1)
                
                albumDataObservable.subscribe().disposed(by: self.disposeBag)
                albumArtObservable.subscribe().disposed(by: self.disposeBag)
                tracksObservable.subscribe().disposed(by: self.disposeBag)
                
                let albumDataGroup: AlbumDataGroup = (artistData,
                                                      albumDataObservable.makeEventTypeOptional(initialValue: nil),
                                                      albumArtObservable,
                                                      tracksObservable)
                
                self.albumQueueEventSubject.onNext(.enqueue(albumDataGroup))
            })
            .disposed(by: disposeBag)
    }
  
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
    
    //MARK: - Process Event Types
    
    enum AlbumQueueEvent {
        case enqueue(AlbumDataGroup)
        case dequeue
    }
    
    //MARK: - Interface
    
    func reviewAlbum(liked: Bool) {
        let _ = Observable.just(liked)
            .withLatestFrom(currentAlbum) { return ($0, $1) }
            .withLatestFrom(currentArtist) { data, artistData in
                return (data.0, data.1, artistData)
            }
            .withLatestFrom(currentAlbumArt) { data, albumArt in
                return(data.0, data.1, data.2, albumArt)
            }
            .subscribe(onNext: { [unowned self] (liked, albumData, artistData, imageData) in
                guard var albumData = albumData, var artistData = artistData else {
                    return
                }
                
                albumData.review(liked: liked)
                artistData.albumReviewed(liked: liked)

                if let imageData = imageData {
                    albumData.imageData = UIImagePNGRepresentation(imageData)
                }
                
                self.localDatabaseService.save(album: albumData)
                self.localDatabaseService.save(artist: artistData)
                
                if liked {
                    self.likedAlbumArtistSubject.onNext(artistData)
                    self.getSmallImageData(forAlbum: albumData)
                }
            })
        
        albumQueueEventSubject.onNext(.dequeue)
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

extension SuggestedAlbumsStateController: AlbumDetailsStateControllerProtocol {
    
    var albumDetails_album: Observable<AlbumData?> {
        return currentAlbum
    }
    var albumDetails_artist: Observable<ArtistData?> {
        return currentArtist
    }
    var albumDetails_albumArt: Observable<UIImage?> {
        return currentAlbumArt
    }
    var albumDetails_tracks: Observable<[TrackData]?> {
        return currentAlbumTracks
    }

}


