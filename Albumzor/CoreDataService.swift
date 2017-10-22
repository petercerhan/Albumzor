//
//  CoreDataService.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

protocol LocalDatabaseServiceProtocol {
    func getArtist(id: String) -> Observable<ArtistData?>
    //Count Albums
    func countUnseenAlbums() -> Observable<Int>
    //Save artist, withAlbums
    func saveArtist(artist artistData: ArtistData, withAlbums albums: [AlbumData])
    
    //get artists by exposures and score
    func getArtistsByExposuresAndScore(max: Int) -> Observable<[ArtistData]>
    
    //get top rated unseen album for artistalbum
//    func getTopUnseenAlbumForArtist(_ artist: ArtistData) -> Observable<(AlbumData, ArtistData)>
    
}

class CoreDataService: LocalDatabaseServiceProtocol {
    
    //MARK: - Dependencies
    
    private let coreDataStack: CoreDataStack
    
    //MARK: - Initialization
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
//    func getTopUnseenAlbumForArtist(_ artist: ArtistData) -> Observable<(AlbumData, ArtistData)> {
//        return Observable<(AlbumData, ArtistData)>.create { [weak self] (observer) -> Disposable in
//
//            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
//                observer.onCompleted()
//                return Disposables.create()
//            }
//
//            backgroundContext.perform {
//                let request = NSFetchRequest<Album>(entityName: "Album")
//                let predicate = NSPredicate(format: "(seen = false) AND (artist.id = %@)", artist.id)
//                request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
//                request.predicate = predicate
//            }
//        }
//    }
    
    func getArtistsByExposuresAndScore(max: Int) -> Observable<[ArtistData]> {
        return Observable<[ArtistData]>.create { [weak self] (observer) -> Disposable in
            
            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            backgroundContext.perform {
                let request = NSFetchRequest<Artist>(entityName: "Artist")
                let predicate = NSPredicate(format: "totalAlbums - seenAlbums > 0 && priorSeed = false")
                request.sortDescriptors = [NSSortDescriptor(key: "seenAlbums", ascending: true), NSSortDescriptor(key: "score", ascending: false)]
                request.predicate = predicate
                request.fetchLimit = max
                
                if let artistArray = try? backgroundContext.fetch(request),
                    artistArray.count > 0
                {
                    observer.onNext(artistArray.map { $0.artistDataRepresentation })
                } else {
                    observer.onNext([ArtistData]())
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    
    
    func countUnseenAlbums() -> Observable<Int> {
        return Observable<Int>.create { [weak self] (observer) -> Disposable in
            
            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            backgroundContext.perform {
                let request = NSFetchRequest<Album>(entityName: "Album")
                let predicate = NSPredicate(format: "seen = false")
                request.predicate = predicate
                request.includesSubentities = false
                
                if let count = try? backgroundContext.count(for: request) {
                    observer.onNext(count)
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func getArtist(id: String) -> Observable<ArtistData?> {
        return Observable<ArtistData?>.create { [weak self] (observer) -> Disposable in
            
            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            backgroundContext.perform {
                let request = NSFetchRequest<Artist>(entityName: "Artist")
                request.predicate = NSPredicate(format: "id == %@", id)
                
                if let artistArray = try? backgroundContext.fetch(request),
                        artistArray.count > 0
                {
                    observer.onNext(artistArray[0].artistDataRepresentation)
                } else {
                    observer.onNext(nil)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
        
    }
    
    func saveArtist(artist artistData: ArtistData, withAlbums albums: [AlbumData]) {
        let backgroundContext = coreDataStack.backgroundContext
        backgroundContext.perform {
            let artist = Artist(artistData: artistData, context: backgroundContext)
            for albumData in albums {
                let album = Album(albumData: albumData, context: backgroundContext)
                album.artist = artist
            }
            
            try? backgroundContext.save()
        }
    }
    
    
    
}

















