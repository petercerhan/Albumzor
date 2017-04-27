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
    
    func seen(album albumID: NSManagedObjectID) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            var artist: Artist?
            
            do {
                let album = try backgroundContext.existingObject(with: albumID) as! Album
                artist = album.artist
                album.seen = true
                
            } catch {
                print("Core data error")
            }
            
            guard artist != nil else {
                print("no artist")
                return
            }
            
            artist!.seenAlbums += 1
            artist!.score -= 1
            
            do {
                try backgroundContext.save()
            } catch {
                print("Could not save context")
            }
            self.stack.save()
        }        
    }
    
    func like(album albumID: NSManagedObjectID, addRelatedArtists: Bool, imageData: Data?) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            var artist: Artist?
            
            do {
                let album = try backgroundContext.existingObject(with: albumID) as! Album
                artist = album.artist
                album.liked = true
                if let imageData = imageData {
                    album.imageData = imageData as NSData?
                }
                
            } catch {
                print("Core data error")
            }
            
            guard artist != nil else {
                print("no artist")
                return
            }
            
            artist!.references += 1
            artist!.score += 1
            
            if addRelatedArtists, !(artist!.relatedAdded) {
                self.getRelatedArtists(artistID: artist!.id!) { error in
                    if let error = error {
                        print("error \(error)")
                    }
                }
                artist!.relatedAdded = true
            }
            
            do {
                try backgroundContext.save()
            } catch {
                print("Could not save context")
            }
            self.stack.save()
        }
    }

    //get albums to display. These albums are in the main context.
    func getAlbums() -> [Album] {
        let context = stack.context
        
        //Choose artists based on score (references - seen); 13 gives some cusion in case album art can't be downloaded for a few.
        let scoreArtistRequest = NSFetchRequest<Artist>(entityName: "Artist")
        let scoreArtistPredicate = NSPredicate(format: "totalAlbums - seenAlbums > 0")
        scoreArtistRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        scoreArtistRequest.predicate = scoreArtistPredicate
        scoreArtistRequest.fetchLimit = 13
        
        var scoreArtists: [Artist]?
        
        do {
            scoreArtists = try context.fetch(scoreArtistRequest)
        } catch {
            print("could not get artists")
        }
        
        var albums = [Album]()
        
        for artist in scoreArtists! {
            albums.append(chooseAlbum(artist: artist))
        }
        
        return albums
    }
    
    //get tracks to display. These tracks are in the main context
    func getTracks(forAlbum albumID: NSManagedObjectID) -> [Track] {
        let context = stack.context
        var album: Album?
        
        do {
            album = try context.existingObject(with: albumID) as! Album
        } catch {
            print("core data error")
        }
        
        let request = NSFetchRequest<Track>(entityName: "Track")
        let predicate = NSPredicate(format: "album = %@", album!)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "disc", ascending: true), NSSortDescriptor(key: "track", ascending: true)]
        
        var tracks: [Track]?
        
        do {
            tracks = try context.fetch(request)
        } catch {
            print("could not get tracks")
        }
        
        return tracks!
    }
    
    private func chooseAlbum(artist: Artist) -> Album {
        let request = NSFetchRequest<Album>(entityName: "Album")
        let predicate = NSPredicate(format: "(seen = false) AND (artist = %@)", artist)
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        request.predicate = predicate
        request.fetchLimit = 2
        
        var albums: [Album]?
        
        do {
            albums = try stack.context.fetch(request)
        } catch {
            print("could not get artists")
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
    
    //MUST BE CALLED IN A BACKGROUND QUEUE
    func getAlbumsCount() -> Int {
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.includesSubentities = false
        
        var count = 0
        
        do {
            count = try stack.context.count(for: request)
        } catch {
            print("could not get artists")
        }
        
        return count
    }
    
    //Completion handler will be invoked after the last album data request has been processed. However, when multiple album requests are made asynchronously, it is possible that some will not have finished by the time the completionHandler is called, and the code invoking this method should not depend on that.
    func addArtist(searchString: String, completionHandler: @escaping DataManagerCompletionHandler) {
        
        //start with artist search
        client.searchArtist(searchString: searchString) { result, error in
            
            if let error = error {
                print("Networking Error \(error)")
                return
            }
            
            guard let artistData = result as? [String : AnyObject] else {
                print("Networking Error \(error)")
                return
            }
            
            //Check that artist data is correct/exists; create and store artist object in core data
            //add artist
            
            self.getRelatedArtists(artistID: artistData["id"] as! String) { error in
                if let error = error {
                    completionHandler(error)
                } else {
                    completionHandler(nil)
                }
            }
        }
    }
    
    func getRelatedArtists(artistID: String, completionHandler: @escaping DataManagerCompletionHandler) {
        
        client.getRelatedArtists(forArtist: artistID) { result, error in
            
            if let error = error {
                print("error: \(error)")
                return
            }
            
            guard let artistsData = result as? [[String : AnyObject]] else {
                print("Data not formatted correctly")
                return
            }

            //
            
            let backgroundContext = self.stack.networkingContext
            
            backgroundContext.perform {
                
            for (index, artist) in artistsData.enumerated() {
                guard let _ = artist["name"] as? String, let id = artist["id"] as? String else {
                    continue
                }
                
                //If the artist is already saved, increment references. Some of this maybe should go in a helper function?
                let request = NSFetchRequest<Artist>(entityName: "Artist")
                request.predicate = NSPredicate(format: "id == %@", id)
                
                var testArtist: Artist?
                
                do {
                    let testArtists = try backgroundContext.fetch(request)
                    if testArtists.count > 0 { testArtist = testArtists[0] }
                } catch {
                    print("fetch request failed")
                }
                
                if let testArtist = testArtist {
                    testArtist.references += 1
                    testArtist.score += 1
                    
                    do {
                        try backgroundContext.save()
                    } catch {
                        print("Could not save context")
                    }
                    self.stack.save()
                    continue
                }
                
                //
                
                
                if index == artistsData.count - 1 {
                    self.getAlbums(forArtist: artist){ error in
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
            //
            
        }
    }
    
    //Optional closures are treated as escaping(?) SR-2444
    private func getAlbums(forArtist artistData: [String : AnyObject], completionHandler: DataManagerCompletionHandler?) {
        
        client.getAlbums(forArtist: artistData["id"] as! String) { result, error in
            
            if let error = error {
                print("error: \(error)")
                return
            }
            
            guard let albumsData = result as? [[String : AnyObject]] else {
                print("Bad return data")
                return
            }

            var albumSearchString = ""
            
            for album in albumsData {
                guard let id = album["id"] as? String, let name = album["name"] as? String else {
                    print("missing value")
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
            
            guard let albumsData = result as? [[String : AnyObject]] else {
                print("bad data structure")
                return
            }
            
            let backgroundContext = self.stack.networkingContext
            
            backgroundContext.perform {
                let artist = Artist(id: artistData["id"] as! String, name: artistData["name"] as! String, context: backgroundContext)
                print("Add artist \(artist.name!)")
                //unpack albums
                var albumsArray = [Album]()
                for album in albumsData {
                    guard let id = album["id"] as? String,
                          let name = album["name"] as? String,
                          let popularity = album["popularity"] as? Int,
                          let images = album["images"] as? [[String : AnyObject]],
                          images.count >= 3,
                          let largeImage = images[0]["url"] as? String,
                          let smallImage = images[2]["url"]  as? String else {

                        print("incomplete album data for album \(album["name"] as? String ?? "")")
                        continue
                    }
                    
                    if self.titleContainsDissallowedKeywords(title: name) {
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
                    print("Could not save context")
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
    
    //prepare array of SpotifyIDs of all "prior" albums
    private func listPriorAlbums() -> [String] {
        return [String]()
    }

    ///
    func addTracks(forAlbumID: String, albumManagedObjectID: NSManagedObjectID) {
        
        client.getTracks(albumID: forAlbumID) { result, error in
                
                guard let tracksData = result as? [[String : AnyObject]] else {
                    print("bad data structure")
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
            let backgroundContext = self.stack.networkingContext
            
            backgroundContext.perform {
                var album: Album?
                do {
                    album = try backgroundContext.existingObject(with: albumManagedObjectID) as? Album
                } catch {
                    print("Core data error")
                }
                
                guard album != nil else {
                    print("no album")
                    return
                }
                
                //don't add tracks a second time
                if let tracks = album!.track, tracks.count > 0 {
                    return
                }
                
                guard let tracksData = result as? [[String : AnyObject]] else {
                    print("bad data structure")
                    return
                }

                for trackData in tracksData {
                    guard let id = trackData["id"] as? String,
                        let name = trackData["name"] as? String,
                        let trackNo = trackData["track_number"] as? Int,
                        let discNo = trackData["disc_number"] as? Int else {
                            
                            print("Incomplete data for album \(album!.name!)")
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
                    print("Could not save context")
                }
                self.stack.save()
            }
        }
    }
    
    //Re-seed albums
    func reseed(completion: DataManagerCompletionHandler) {
        let backgroundContext = stack.networkingContext
        
        //get liked albums
        let request_likedAlbums = NSFetchRequest<Album>(entityName: "Album")
        let predicate_likeAlbums = NSPredicate(format: "(liked = true)")
        request_likedAlbums.predicate = predicate_likeAlbums
        var likedAlbums = [Album]()
        
        do {
            likedAlbums = try backgroundContext.fetch(request_likedAlbums)
        } catch {
            print("could not get tracks")
        }
        
        //set liked albums priorSeed = true
        //for each, get artist. If artist has priorSeed = true, next. Else, if a priorSeed artist already exists with same spotify ID, assign that one to the album. Else, artist prior = true
        for album in likedAlbums {
            album.priorSeed = true
            
            let artist = album.artist!
            if artist.priorSeed == false {
                
                //check if a "priorSeed" version of this artist already exists. If so, use that one instead of creating another
                let request = NSFetchRequest<Artist>(entityName: "Artist")
                let predicate = NSPredicate(format: "(id = \(artist.id)")
                request.predicate = predicate
                var existingPriorArtists: [Artist]?
                
                do {
                    existingPriorArtists = try backgroundContext.fetch(request)
                } catch {
                    print("could not get tracks")
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
            print("could not get tracks")
        }
        
        for artist in notPriorArtists {
            backgroundContext.delete(artist)
        }
        
        //get not prior albums delete (albums assigned to an artist that was turned prior)
        let request_notPriorAlbums = NSFetchRequest<Album>(entityName: "Album")
        let predicate_notPriorAlbums = NSPredicate(format: "priorSeed = false")
        request_notPriorAlbums.predicate = predicate_notPriorAlbums
        var notPriorAlbums = [Album]()
        
        do {
            notPriorAlbums = try backgroundContext.fetch(request_notPriorAlbums)
        } catch {
            print("could not get tracks")
        }
        
        for album in notPriorAlbums {
            backgroundContext.delete(album)
        }
        
        //Save and call completion handler
        do {
            try backgroundContext.save()
        } catch {
            print("Could not save context")
        }
        self.stack.save()
        
        completion(nil)
    }
}

//MARK:- Album filtering

extension DataManager {
    
    //Do not save albums with these keywords in the title
    static let filterKeywords = ["Live",
                                 "Collection",
                                 "Duets",
                                 "Anthology",
                                 "Greatest Hits",
                                 "20th Century Masters",
                                 "In Concert",
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


