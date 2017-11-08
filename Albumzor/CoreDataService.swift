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
    func getTopUnseenAlbumForArtist(_ artist: ArtistData) -> Observable<(AlbumData, ArtistData)>
    
    func save(album albumData: AlbumData)
    
    func save(artist artistData: ArtistData)
    
    func getTracksForAlbum(_ albumData: AlbumData) -> Observable<[TrackData]>
    
    func save(tracks: [TrackData], forAlbum album: AlbumData)
    
    func getLikedAlbums() -> Observable<[AlbumData]>
    
    func getAlbumArtistTracks(forAlbumID albumID: String) -> Observable<(AlbumData, ArtistData, [TrackData]?)>
    
    func deleteAlbum(id: String)
    
    func resetData() -> Observable<DataOperationState>
}

class CoreDataService: LocalDatabaseServiceProtocol {
    
    //MARK: - Dependencies
    
    fileprivate let coreDataStack: CoreDataStack
    
    //MARK: - Initialization
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    //MARK: - Interface
    
    func resetData() -> Observable<DataOperationState> {
        return Observable<DataOperationState>.create { [weak self] (observer) -> Disposable in
            
            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            observer.onNext(.operationBegan)
            
            backgroundContext.perform {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    _ = try backgroundContext.execute(deleteRequest)
                    observer.onNext(.operationCompleted)
                } catch {
                    observer.onNext(.error(DatabaseOperationError.failure))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAlbum(id: String) {
        let backgroundContext = coreDataStack.backgroundContext
        backgroundContext.perform {
            
            let request = NSFetchRequest<Album>(entityName: "Album")
            request.predicate = NSPredicate(format: "id == %@", id)
            
            if let albumArray = try? backgroundContext.fetch(request), albumArray.count > 0 {
                backgroundContext.delete(albumArray[0])
                try? backgroundContext.save()
            }
        }
    }
    
    func getAlbumArtistTracks(forAlbumID albumID: String) -> Observable<(AlbumData, ArtistData, [TrackData]?)> {
        return Observable<(AlbumData, ArtistData, [TrackData]?)>.create { [weak self] (observer) -> Disposable in
            
            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            backgroundContext.perform {
                let request = NSFetchRequest<Album>(entityName: "Album")
                request.predicate = NSPredicate(format: "id == %@", albumID)
                
                if let albumArray = try? backgroundContext.fetch(request), albumArray.count > 0, let artist = albumArray[0].artist {
                    let album = albumArray[0]
                    
                    var trackData: [TrackData]? = nil
                    if let tracksSet = album.track, let tracksArray = Array(tracksSet) as? [Track] {
                        trackData = tracksArray.map {
                            return $0.trackDataRepresentation
                        }
                    }
                    
                    observer.onNext((album.albumDataRepresentation, artist.artistDataRepresentation, trackData))
                }
                
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
    }
    
    func getLikedAlbums() -> Observable<[AlbumData]> {
        return Observable<[AlbumData]>.create { [weak self] observer -> Disposable in
            
            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            backgroundContext.perform {
                let request = NSFetchRequest<Album>(entityName: "Album")
                request.predicate = NSPredicate(format: "(liked = true)")
                
                if let albumArray = try? backgroundContext.fetch(request) {
                    observer
                        .onNext(albumArray.map { album -> AlbumData in
                                    var albumData = album.albumDataRepresentation
                                    albumData.artistName = album.artist?.name
                                    return albumData
                                })
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    func save(tracks trackDataArray: [TrackData], forAlbum albumData: AlbumData) {
        let backgroundContext = coreDataStack.backgroundContext
        backgroundContext.perform {
            let request = NSFetchRequest<Album>(entityName: "Album")
            request.predicate = NSPredicate(format: "id = %@", albumData.id)
            guard
                let albumArray = try? backgroundContext.fetch(request),
                albumArray.count > 0 else
            {
                return
            }
            let album = albumArray[0]
            
            for trackData in trackDataArray {
                let track = Track(trackData: trackData, context: backgroundContext)
                track.album = album
            }
            try? backgroundContext.save()
        }
    }
    
    func save(album albumData: AlbumData) {
        let backgroundContext = coreDataStack.backgroundContext
        backgroundContext.perform {
            let request = NSFetchRequest<Album>(entityName: "Album")
            request.predicate = NSPredicate(format: "id = %@", albumData.id)
            
            guard let albumArray = try? backgroundContext.fetch(request),
                albumArray.count > 0 else
            {
                return
            }
            
            let album = albumArray[0]
            
            album.syncWithAlbumData(albumData)
            try? backgroundContext.save()
        }
    }
    
    func save(artist artistData: ArtistData) {
        let backgroundContext = coreDataStack.backgroundContext
        backgroundContext.perform {
            let request = NSFetchRequest<Artist>(entityName: "Artist")
            request.predicate = NSPredicate(format: "id = %@", artistData.id)
            
            guard let artistArray = try? backgroundContext.fetch(request),
                artistArray.count > 0 else
            {
                return
            }
            
            let artist = artistArray[0]
            
            artist.syncWithArtistData(artistData)
            try? backgroundContext.save()
        }
    }
    
    func getTopUnseenAlbumForArtist(_ artist: ArtistData) -> Observable<(AlbumData, ArtistData)> {
        return Observable<(AlbumData, ArtistData)>.create { [weak self] (observer) -> Disposable in

            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
                observer.onCompleted()
                return Disposables.create()
            }

            backgroundContext.perform {
                let request = NSFetchRequest<Album>(entityName: "Album")
                let predicate = NSPredicate(format: "(seen = false) AND (artist.id = %@)", artist.id)
                request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
                request.predicate = predicate
                
                if let albumArray = try? backgroundContext.fetch(request),
                    albumArray.count > 0
                {
                    observer.onNext((albumArray[0].albumDataRepresentation, artist))
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
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
                
                if
                    let artistArray = try? backgroundContext.fetch(request),
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
    
    func getTracksForAlbum(_ albumData: AlbumData) -> Observable<[TrackData]> {
        return Observable<[TrackData]>.create { [weak self] (observer) -> Disposable in

            guard let backgroundContext = self?.coreDataStack.backgroundContext else {
                observer.onCompleted()
                return Disposables.create()
            }

            backgroundContext.perform {
                let request = NSFetchRequest<Track>(entityName: "Track")
                request.predicate = NSPredicate(format: "album.id = %@", albumData.id)
                request.sortDescriptors = [NSSortDescriptor(key: "disc", ascending: true),
                                           NSSortDescriptor(key: "track", ascending: true)]

                if
                    let tracksArray = try? backgroundContext.fetch(request),
                    tracksArray.count > 0
                {
                    observer.onNext(tracksArray.map { $0.trackDataRepresentation })
                } else {
                    observer.onNext([TrackData]())
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

//MARK: - Utilities

extension CoreDataService {
    
    func resetDatabase() {
        print("! Reset database")
        try? coreDataStack.dropAllData()
    }
    
}















