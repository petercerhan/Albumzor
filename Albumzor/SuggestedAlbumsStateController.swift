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
    
    //MARK: - State
    
    
//    private let fetchedArtistsSubject = PublishSubject<ArtistPoolEvent>()
//
//    private let fetchNextAlbumSubject = PublishSubject<ArtistPoolEvent>()
//
//    private lazy var currentArtistsPool: Observable<[ArtistData]> = {
//
//        let source = Observable.of(fetchedArtistsSubject.asObservable(), fetchNextAlbumSubject.asObservable())
//
//
//        return self.fetchedArtistsSubject.asObservable()
//    }()

    private let artistPoolEventSubject = PublishSubject<ArtistPoolEvent>()
    
    private lazy var currentArtistPool: Observable<(InspectableQueue<ArtistData>, FetchAlbumProcessEvent)> = {
        return self.artistPoolEventSubject.asObservable()
            .scan((InspectableQueue<ArtistData>(), .none)) { (accumulator, artistPoolEvent) -> (InspectableQueue<ArtistData>, FetchAlbumProcessEvent) in
                var currentArtistQueue = accumulator.0
                
                switch artistPoolEvent {
                case .addArtists(let newArtistData):
                    currentArtistQueue.enqueue(elements: newArtistData)
                    return (currentArtistQueue, .none)
                case .fetchAlbumForNextArtist:
                    guard let artist = currentArtistQueue.dequeue() else {
                        //potentially trigger something else here
                        return (currentArtistQueue, .none)
                    }
                    return (currentArtistQueue, .fetchAlbumForArtist(artist: artist))
                }
            }
    }()
    
    
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(localDatabaseService: LocalDatabaseServiceProtocol) {
        self.localDatabaseService = localDatabaseService
        getArtists()
     
        bindMonitors()
        
    }
    
    private func bindMonitors() {
        
        currentArtistPool
            .map { (artistQueue, _) -> Int in
                return artistQueue.count
            }
            .filter { count in
                return count < 10
            }
            .map { [unowned self] _ -> Observable<[ArtistData]> in
                return self.localDatabaseService.getArtistsByExposuresAndScore(max: 10)
                    .materialize()
                    .filter { event in
                        switch event {
                        case .next:
                            return true
                        default:
                            return false
                        }
                    }
                    .dematerialize()
            }
            .flatMap { $0 }
            .subscribe(onNext: { [unowned self] artists in
                self.artistPoolEventSubject.onNext(.addArtists(artists))
            })
            .disposed(by: disposeBag)
        
    }
    
    
    //MARK: - Suggestions Algorithm
    
    private func fetchAlbum() {
        
        
        
        
        
    }
    
    private func getArtists() {
        let artistsObservable = localDatabaseService.getArtistsByExposuresAndScore(max: 10)
        
        artistsObservable
            .subscribe(onNext: { [unowned self] artistsData in
                self.artistPoolEventSubject.onNext(ArtistPoolEvent.addArtists(artistsData))
            })
            .disposed(by: disposeBag)
    }
    
    enum ArtistPoolEvent {
        case addArtists([ArtistData])
        case fetchAlbumForNextArtist
    }
    
    enum FetchAlbumProcessEvent {
        case fetchAlbumForArtist(artist: ArtistData)
        case none
    }
    
    enum AlbumPoolFinalEvent {
        case enqueueAlbum(AlbumData)
        case dequeueAlbum
    }
    
}


