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
    private let shufflingService: ShufflingService
    
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
    }()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(localDatabaseService: LocalDatabaseServiceProtocol, shufflingService: ShufflingService) {
        self.localDatabaseService = localDatabaseService
        self.shufflingService = shufflingService

        bindMonitors()
        getInitialArtists()
        
    }
    
    private func bindMonitors() {
        //ArtistPoolMonitor
        currentArtistPool
            .map { (artistQueue, _) -> Int in
               
//                print("\n\nQueue count \(artistQueue.count)")
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
    
    
    //MARK: - Suggestions Algorithm
    
    private func fetchAlbum() {
        
        
        
        
        
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
    
    enum AlbumPoolFinalEvent {
        case enqueueAlbum(AlbumData)
        case dequeueAlbum
    }
    
    
    
    //MARK: - Interface
    
    func reviewAlbum(like: Bool) {
        
    }
    
}


