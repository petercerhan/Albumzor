//
//  DataManager.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import CoreData

typealias DataManagerCompletionHandler = (_ error: NSError?) -> Void

class DataManager {
    
    let client = SpotifyClient.sharedInstance()
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
    var priorAlbumIDs: [String]!
    
    //init call refresh priorAlbumIDs
    init() {
        setPriorAlbumIDs()
    }
    
    //MARK: - Album review actions
    
    func seen(album albumID: NSManagedObjectID) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            var artist: Artist?
            
            do {
                let album = try backgroundContext.existingObject(with: albumID) as! Album
                artist = album.artist
                album.seen = true
            } catch {
                
            }
            
            guard artist != nil else {
                return
            }
            
            artist!.seenAlbums += 1
            artist!.score -= 1
            
            do {
                try backgroundContext.save()
            } catch {
                //save error
            }
            self.stack.save()
        }        
    }
    
    func like(album albumID: NSManagedObjectID, imageData: Data?) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            var artist: Artist?
            
            do {
                let album = try backgroundContext.existingObject(with: albumID) as! Album
                artist = album.artist
                album.liked = true
                album.likedDateTime = NSDate()
                if let imageData = imageData {
                    album.imageData = imageData as NSData?
                }
                //small image data
                self.getSmallImageData(album: album, context: backgroundContext)
            } catch {
                
            }
            
            guard artist != nil else {
                return
            }
            
            artist!.references += 1
            artist!.score += 1
            
            if !(artist!.relatedAdded) {
                self.getRelatedArtists(artistID: artist!.id!) { error in
                    if let _ = error {
                        //No action needed here (networking error is possible, but since this action operates in the background while the user is viewing suggested albums, no need to notify them. If internet connection is out they will be notified by the track loading errors)
                    }
                }
                artist!.relatedAdded = true
            }
            
            do {
                try backgroundContext.save()
            } catch {
                
            }
            self.stack.save()
        }
    }
    
    private func getSmallImageData(album: Album, context: NSManagedObjectContext) {
        context.perform {
            guard let smallImageURLString = album.smallImage, let url = URL(string: smallImageURLString) else {
                return
            }
            
            let session = URLSession.shared
            let request: NSURLRequest = NSURLRequest(url: url)
            
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
                context.perform {
                    if let _ = error {
                        return
                    } else {
                        album.smallImageData = data as NSData?
                    }
                    do {
                        try context.save()
                    } catch {
                        
                    }
                    self.stack.save()
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Retrieve objects for display

    //get albums to display. These albums are in the main context.
    func getAlbums() -> [Album] {
        let context = stack.context
        
        //potentially fetch new albums if running low starting here
        //check if albums have started running low and download some more
        //supplementAlbums()
        if let unseenCount = countUnseenAlbums(), unseenCount < 100 {
            supplementAlbums()
        }
        
        //Choose artists based on score (references - seen); 13 gives some fall-back in case album art can't be downloaded for a few.
        let request = NSFetchRequest<Artist>(entityName: "Artist")
        let predicate = NSPredicate(format: "totalAlbums - seenAlbums > 0 && priorSeed = false")
        request.sortDescriptors = [NSSortDescriptor(key: "seenAlbums", ascending: true), NSSortDescriptor(key: "score", ascending: false)]
        request.predicate = predicate
        request.fetchLimit = 13
        
        var artists: [Artist]?
        
        do {
            artists = try context.fetch(request)
        } catch {
            //Unexpected error state - core data queries should succeed
            return [Album]()
        }
        
        var albums = [Album]()
        
        for artist in artists! {
            guard let album = chooseAlbum(artist: artist) else {
                continue
            }
            albums.append(album)
        }
        
        return albums
    }
    
    private func chooseAlbum(artist: Artist) -> Album? {
        let request = NSFetchRequest<Album>(entityName: "Album")
        let predicate = NSPredicate(format: "(seen = false) AND (artist = %@)", artist)
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        request.predicate = predicate
        //limit to top two most popular albums remaining. This seems to be where most of the best suggestions come from for most artists.
        request.fetchLimit = 2
        
        var albums: [Album]?
        
        do {
            albums = try stack.context.fetch(request)
        } catch {
            //Unexpected error state - core data queries should succeed
            return nil
        }
        
        return albums![randomAlbumIndex(albumCount: albums!.count)]
    }
    
    private func randomAlbumIndex(albumCount count: Int) -> Int {
        func chooseIndex(_ probabilitites: [Double]) -> Int {
            let r = drand48()
            if r == 0 { return 1 }
            var sum = 0.0
            var index = 0
            
            while r > sum {
                sum += probabilitites[index]
                index += 1
            }
            
            return index - 1
        }
        
        var index = 0
        
        //spreads for 3-5 not currently used. Usage seems to suggest the top two albums are usually the best recomendations
        switch count {
        case 5:
            index = chooseIndex([0.45, 0.25, 0.15, 0.1, 0.05])
        case 4:
            index = chooseIndex([0.5, 0.25, 0.15, 0.1])
        case 3:
            index = chooseIndex([0.55, 0.3, 0.15])
        case 2:
            index = chooseIndex([0.8, 0.2])
        default:
            index = 0
        }
        
        return index
    }
    
    func countUnseenAlbums() -> Int? {
        let request = NSFetchRequest<Album>(entityName: "Album")
        let predicate = NSPredicate(format: "seen = false")
        request.predicate = predicate
        request.includesSubentities = false
        
        var count: Int?
        
        do {
            count = try stack.context.count(for: request)
        } catch {
            return nil
        }
        
        return count
    }
    
    private func supplementAlbums() {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            //Add albums for artist with highest score whose relateds have not been added
            let request = NSFetchRequest<Artist>(entityName: "Artist")
            let predicate = NSPredicate(format: "relatedAdded = false && priorSeed = false")
            request.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
            request.predicate = predicate
            request.fetchLimit = 1
            
            var artist: Artist?
            
            do {
                let artists = try backgroundContext.fetch(request)
                guard artists.count > 0 else {
                    return
                }
                artist = artists[0]
            } catch {
                return
            }
         
            artist!.relatedAdded = true
            do {
                try backgroundContext.save()
            } catch {
                return
            }
            self.stack.save()
            
            self.getRelatedArtists(artistID: artist!.id!) { _ in }
        }
    }
    
    //get tracks to display. These tracks are in the main context
    func getTracks(forAlbum albumID: NSManagedObjectID) -> [Track] {
        let context = stack.context
        var album: Album?
        
        do {
            album = try context.existingObject(with: albumID) as! Album
        } catch {
            
        }
        
        let request = NSFetchRequest<Track>(entityName: "Track")
        let predicate = NSPredicate(format: "album = %@", album!)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "disc", ascending: true), NSSortDescriptor(key: "track", ascending: true)]
        
        var tracks: [Track]?
        
        do {
            tracks = try context.fetch(request)
        } catch {
            
        }
        
        return tracks!
    }
    
    //MARK: - Fetching and storing artists, albums, and tracks
    
    /*
     getRelatedArtists kicks off the following process:
     1) Fetch related artists from Spotify
     2) For each related artists,
        a) Fetch albums for artist (fetches simplified album objects)
        b) Fetch full album objects for each album
     
     Completion handler will be invoked after the last album data request has been processed. However, because multiple album requests are made asynchronously, it is possible that some will not have finished by the time the completionHandler is called, and the code invoking this method should not count on that.
     */
    func getRelatedArtists(artistID: String, completionHandler: @escaping DataManagerCompletionHandler) {
        
        client.getRelatedArtists(forArtist: artistID) { result, error in
            
            if let error = error {
                return
            }
            
            guard let artistsData = result as? [[String : AnyObject]] else {
                return
            }
            
            let backgroundContext = self.stack.networkingContext
            
            backgroundContext.perform {
                for (index, artist) in artistsData.enumerated() {
                    guard let _ = artist["name"] as? String, let id = artist["id"] as? String else {
                        continue
                    }

                    //Check if the artist is already in our data. If so, increment score and references and continue to next artist
                    let request = NSFetchRequest<Artist>(entityName: "Artist")
                    request.predicate = NSPredicate(format: "id == %@", id)
                    
                    var testArtist: Artist?
                    
                    do {
                        let testArtists = try backgroundContext.fetch(request)
                        if testArtists.count > 0 { testArtist = testArtists[0] }
                    } catch {
                        
                    }
                    
                    if let testArtist = testArtist {
                        testArtist.references += 1
                        testArtist.score += 1
                        
                        do {
                            try backgroundContext.save()
                        } catch {
                            
                        }
                        self.stack.save()
                        continue
                    }
                    
                    //If the artist is not already in our data, add the artist and the artist's albums
                    //If the last artist, call the completion handler
                    if index == artistsData.count - 1 {
                        self.getAlbums(forArtist: artist) { error in
                            if let error = error {
                                completionHandler(error)
                            } else {
                                completionHandler(nil)
                            }
                        }
                    } else {
                        self.getAlbums(forArtist: artist, completionHandler: nil)
                    }
                }
            }
            
        }
    }
    
    //Optional closures are treated as escaping by default(?) SR-2444
    private func getAlbums(forArtist artistData: [String : AnyObject], completionHandler: DataManagerCompletionHandler?) {
        
        client.getAlbums(forArtist: artistData["id"] as! String) { result, error in
            
            if let error = error {
                if let completionHandler = completionHandler {
                    completionHandler(error)
                }
                return
            }
            
            guard let albumsData = result as? [[String : AnyObject]] else {
                //should not happen as SpotifyClient checks this also
                return
            }

            var albumSearchString = ""
            
            for album in albumsData {
                guard let id = album["id"] as? String, let name = album["name"] as? String else {
                    continue
                }
                
                if self.titleContainsDissallowedKeywords(title: name) {
                    continue
                }
                
                albumSearchString += id
                albumSearchString += ","
            }
            
            //remove last comma
            if albumSearchString != "" {
                albumSearchString.remove(at: albumSearchString.index(before: albumSearchString.endIndex))
            }
            
            self.getAlbums(searchString: albumSearchString, artist: artistData, completionHandler: completionHandler)
        }
    }
    
    private func getAlbums(searchString: String, artist artistData: [String : AnyObject], completionHandler: DataManagerCompletionHandler?) {
        
        client.getAlbums(ids: searchString) { result, error in
            
            if let error = error, let completionHandler = completionHandler {
                completionHandler(error)
            }
            
            guard let albumsData = result as? [[String : AnyObject]] else {
                //should not happen as SpotifyClient checks this also
                return
            }
            
            let backgroundContext = self.stack.networkingContext
            
            backgroundContext.perform {
                let artist = Artist(id: artistData["id"] as! String, name: artistData["name"] as! String, context: backgroundContext)
                
                var albumsArray = [Album]()
                for album in albumsData {
                    guard let id = album["id"] as? String,
                          let name = album["name"] as? String,
                          let popularity = album["popularity"] as? Int,
                          let images = album["images"] as? [[String : AnyObject]],
                          images.count >= 3,
                           let largeImage = images[0]["url"] as? String,
                          let smallImage = images[1]["url"]  as? String else {

                        continue
                    }
                    
                    if self.titleContainsDissallowedKeywords(title: name) {
                        continue
                    }
                    
                    if self.priorAlbumIDs.contains(id) {
                        continue
                    }
                    
                    let album = Album(id: id, name: name, popularity: Int16(popularity), largeImage: largeImage, smallImage: smallImage, context: backgroundContext)
                    album.artist = artist
                    albumsArray.append(album)
                }

                //Sort albums and remove multiple versions of the same album, based on popularity
                albumsArray = albumsArray.sorted {
                    if $0.name!.cleanAlbumName() == $1.name!.cleanAlbumName() {
                        return $0.popularity > $1.popularity
                    } else {
                        return $0.name!.cleanAlbumName().localizedCaseInsensitiveCompare($1.name!.cleanAlbumName()) == ComparisonResult.orderedAscending
                    }
                }
                
                artist.totalAlbums = Int16(albumsArray.count)
                
                for (index, album) in albumsArray.enumerated() {
                    if index != 0 {
                        if album.name!.cleanAlbumName().localizedCaseInsensitiveCompare(albumsArray[index - 1].name!.cleanAlbumName()) == ComparisonResult.orderedSame {
                            backgroundContext.delete(album as NSManagedObject)
                            artist.totalAlbums = artist.totalAlbums - 1
                        }
                    }
                }
                
                do {
                    try backgroundContext.save()
                } catch {
                    
                }
                self.stack.save()
            }
            
            //If the completion handler was passed, we know that we have received a response to the last album search request made. Although not gauranteed to be completely finished, it's reasonable to assume most of this networking process has completed. No object calling addArtist() should depend on the process being 100% finished retrieving, parsing, and adding its albums & artists to Core Data
            if let completionHandler = completionHandler {
                if let error = error {
                    completionHandler(error)
                } else {
                    completionHandler(nil)
                }
            }
            
        }
    }

    /*
     Add tracks kicks off the following process:
     1) Download tracks for the requested album from Spotify. Spotify returns simplified track objects
     2) Download the full track objects
     */
    func addTracks(forAlbumID: String, albumManagedObjectID: NSManagedObjectID) {
        
        client.getTracks(albumID: forAlbumID) { result, error in
                
                guard let tracksData = result as? [[String : AnyObject]] else {
                    return
                }
            
                var trackSearchString = ""
                
                for trackData in tracksData {
                    guard let id = trackData["id"] as? String else {
                        continue
                    }
                    
                    trackSearchString += id
                    trackSearchString += ","
                }
            
                //remove last comma
                if trackSearchString != "" {
                    trackSearchString.remove(at: trackSearchString.index(before: trackSearchString.endIndex))
                }
            
            self.addTracks(searchString: trackSearchString, albumManagedObjectID: albumManagedObjectID)
        }
    }
    
    private func addTracks(searchString: String, albumManagedObjectID: NSManagedObjectID) {
        
        client.getTracks(ids: searchString) { result, error in
            
            if let _ = error {
                return
            }
            
            let backgroundContext = self.stack.networkingContext
            
            backgroundContext.perform {
                var album: Album?
                do {
                    album = try backgroundContext.existingObject(with: albumManagedObjectID) as? Album
                } catch {
                    
                }
                
                guard album != nil else {
                    return
                }
                
                //don't add tracks a second time
                if let tracks = album!.track, tracks.count > 0 {
                    return
                }
                
                guard let tracksData = result as? [[String : AnyObject]] else {
                    return
                }

                for trackData in tracksData {
                    guard let id = trackData["id"] as? String,
                        let name = trackData["name"] as? String,
                        let trackNo = trackData["track_number"] as? Int,
                        let discNo = trackData["disc_number"] as? Int else {
                            
                            continue
                    }
                    
                    let track = Track(id: id, name: name, trackNo: trackNo, discNo: discNo, context: backgroundContext)
                    track.album = album

                    track.popularity = trackData["popularity"] as? Int16 ?? 0
                    track.previewURL = trackData["preview_url"] as? String
                }

                do {
                    try backgroundContext.save()
                } catch {

                }
                self.stack.save()
            }
        }
    }
    
    //MARK: - Dataset manipulation
    
    //Re-seed albums
    func reseed(completion: @escaping DataManagerCompletionHandler) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
        
            //get liked albums
            let request_likedAlbums = NSFetchRequest<Album>(entityName: "Album")
            let predicate_likedAlbums = NSPredicate(format: "(liked = true)")
            request_likedAlbums.predicate = predicate_likedAlbums
            var likedAlbums = [Album]()
            
            do {
                likedAlbums = try backgroundContext.fetch(request_likedAlbums)
            } catch {
                
            }
            
            //set liked albums priorSeed = true
            //for each, get artist. If artist has priorSeed = true, next. Else, if a priorSeed artist already exists with the same spotify ID, assign it to the album. Else, set artist priorSeed = true
            for album in likedAlbums {
                album.priorSeed = true
                
                let artist = album.artist!
                if artist.priorSeed == false {
                    
                    //check if a "priorSeed" version of this artist already exists. If so, use that one instead of creating another
                    let request = NSFetchRequest<Artist>(entityName: "Artist")
                    let predicate = NSPredicate(format: "id == %@ && priorSeed == true", artist.id!)
                    request.predicate = predicate
                    var existingPriorArtists: [Artist]?
                    
                    do {
                        existingPriorArtists = try backgroundContext.fetch(request)
                    } catch {
                        
                    }
                    
                    if let existingPriorArtists = existingPriorArtists, existingPriorArtists.count > 0 {
                        album.artist = existingPriorArtists[0]
                    } else {
                        artist.priorSeed = true
                    }
                }
            }
            
            //Get not prior artists, delete
            let request_notPriorArtists = NSFetchRequest<Artist>(entityName: "Artist")
            let predicate_notPriorArtists = NSPredicate(format: "priorSeed = false")
            request_notPriorArtists.predicate = predicate_notPriorArtists
            var notPriorArtists = [Artist]()
            
            do {
                notPriorArtists = try backgroundContext.fetch(request_notPriorArtists)
            } catch {
                
            }
            
            for artist in notPriorArtists {
                backgroundContext.delete(artist)
            }
            
            //get not prior albums, delete (albums assigned to an artist that was turned prior)
            let request_notPriorAlbums = NSFetchRequest<Album>(entityName: "Album")
            let predicate_notPriorAlbums = NSPredicate(format: "priorSeed = false")
            request_notPriorAlbums.predicate = predicate_notPriorAlbums
            var notPriorAlbums = [Album]()
            
            do {
                notPriorAlbums = try backgroundContext.fetch(request_notPriorAlbums)
            } catch {
                
            }
            
            for album in notPriorAlbums {
                backgroundContext.delete(album)
            }
            
            //Save and call completion handler
            do {
                try backgroundContext.save()
            } catch {
                
            }
            self.stack.save()
            
            DispatchQueue.main.async {
                self.setPriorAlbumIDs()
            }
            
            completion(nil)
        }
    }
    
    func reset(completion: @escaping DataManagerCompletionHandler) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            let request = NSFetchRequest<Artist>(entityName: "Artist")
            var artists = [Artist]()
            
            do {
                artists = try backgroundContext.fetch(request)
            } catch {
                
            }
            
            for artist in artists {
                backgroundContext.delete(artist)
            }
            
            //Save and call completion handler
            do {
                try backgroundContext.save()
            } catch {
                
            }
            self.stack.save()
            
            DispatchQueue.main.async {
                self.setPriorAlbumIDs()
            }
            
            completion(nil)
        }
    }
    
    private func setPriorAlbumIDs() {
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        let predicate = NSPredicate(format: "priorSeed = true")
        request.predicate = predicate
        var albums = [Album]()
        
        do {
            albums = try stack.context.fetch(request)
        } catch {
            
        }
        
        var ids = [String]()
        
        for album in albums {
            ids.append(album.id!)
        }
        
        priorAlbumIDs = ids
    }
    
    //MARK: - Utilities
    
    func getAlbumsCount() -> Int {
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.includesSubentities = false
        
        var count = 0
        
        do {
            count = try stack.context.count(for: request)
        } catch {
            
        }
        
        return count
    }
    
    func getArtistsCount() -> Int {
        let request = NSFetchRequest<Artist>(entityName: "Artist")
        request.includesSubentities = false
        
        var count = 0
        
        do {
            count = try stack.context.count(for: request)
        } catch {
            
        }
        
        return count
    }
    
    func artistList() {
        let context = stack.context
        
        let artistRequest = NSFetchRequest<Artist>(entityName: "Artist")
        artistRequest.sortDescriptors = [NSSortDescriptor(key: "priorSeed", ascending: false)]
        
        var artists = [Artist]()
        
        do {
            artists = try context.fetch(artistRequest)
        } catch {
            
        }
        
        for artist in artists {
            print("artist: \(artist.name!) priorSeed: \(artist.priorSeed)")
        }
    }
}

//MARK: - Album filtering

extension DataManager {
    
    //Do not save albums with these keywords in the title
    static let filterKeywords = ["Live",
                                 "Collection",
                                 "Duets",
                                 "Anthology",
                                 "Greatest Hits",
                                 "20th Century Masters",
                                 "Concert",
                                 "Spotify",
                                 "Best of",
                                 "Essential"]

    func titleContainsDissallowedKeywords(title: String) -> Bool {
        for keyword in DataManager.filterKeywords {
            if title.localizedCaseInsensitiveContains(keyword) {
                return true
            }
        }
        
        return false
    }
    
}


