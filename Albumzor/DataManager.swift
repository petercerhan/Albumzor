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
        
        backgroundContext.perform{
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
    
    func like(album albumID: NSManagedObjectID, addRelatedArtists: Bool) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            var artist: Artist?
            
            do {
                let album = try backgroundContext.existingObject(with: albumID) as! Album
                artist = album.artist
                album.liked = true
                
            } catch {
                print("Core data error")
            }
            
            guard artist != nil else {
                print("no artist")
                return
            }
            
            artist!.references += 1
            artist!.score += 1
            
            do {
                try backgroundContext.save()
            } catch {
                print("Could not save context")
            }
            self.stack.save()
            
            if addRelatedArtists {
                self.getRelatedArtists(artistID: artist!.id!) { error in
                    if let error = error {
                        print("error \(error)")
                    }
                }
            }
            
        }
    }
    
    func unlike(album albumID: NSManagedObjectID) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            var artist: Artist?
            
            do {
                let album = try backgroundContext.existingObject(with: albumID) as! Album
                artist = album.artist
                album.liked = false
                
            } catch {
                print("Core data error")
            }
            
            guard artist != nil else {
                print("no artist")
                return
            }
            
            artist!.references -= 1
            artist!.score -= 1
            
            do {
                try backgroundContext.save()
            } catch {
                print("Could not save context")
            }
            self.stack.save()
        }
    }
    
    //func star(album albumID: NSManagedObjectID){}
    func star(album albumID: NSManagedObjectID, addRelatedArtists: Bool) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            var artist: Artist?
            
            do {
                let album = try backgroundContext.existingObject(with: albumID) as! Album
                artist = album.artist
                album.starred = true
                
            } catch {
                print("Core data error")
            }
            
            guard artist != nil else {
                print("no artist")
                return
            }
            
            artist!.references += 1
            artist!.score += 1
            
            if addRelatedArtists {
                self.getRelatedArtists(artistID: artist!.id!) { error in
                    if let error = error {
                        print("error \(error)")
                    }
                }
            }
        }
    }
    
    //func unstar(album albumID: NSManagedObjectID) {}
    func unstar(album albumID: NSManagedObjectID) {
        let backgroundContext = stack.networkingContext
        
        backgroundContext.perform {
            var artist: Artist?
            
            do {
                let album = try backgroundContext.existingObject(with: albumID) as! Album
                artist = album.artist
                album.starred = false
                
            } catch {
                print("Core data error")
            }
            
            guard artist != nil else {
                print("no artist")
                return
            }
            
            artist!.references -= 1
            artist!.score -= 1
            
            do {
                try backgroundContext.save()
            } catch {
                print("Could not save context")
            }
            self.stack.save()
        }
    }
    
    //get albums to display. These albums are fetched in the main queue context
    func getAlbums() -> [Album] {
        let context = stack.context
        
        //Choose 3 unseen artists
        let unseenArtistRequest = NSFetchRequest<Artist>(entityName: "Artist")
        let unseenArtistPredicate = NSPredicate(format: "(seenAlbums = 0) AND (totalAlbums > 0)")
        unseenArtistRequest.predicate = unseenArtistPredicate
        unseenArtistRequest.fetchLimit = 3
        
        var unseenArtists: [Artist]?
        
        do {
            unseenArtists = try context.fetch(unseenArtistRequest)
        } catch {
            print("could not get artists")
        }
        
        //Fill remaining spots with artists based on score (references - seen)
        let scoreArtistRequest = NSFetchRequest<Artist>(entityName: "Artist")
        let scoreArtistPredicate = NSPredicate(format: "totalAlbums - seenAlbums > 0")
        scoreArtistRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
        scoreArtistRequest.predicate = scoreArtistPredicate
        scoreArtistRequest.fetchLimit = 13 - unseenArtists!.count
        
        var scoreArtists: [Artist]?
        
        do {
            scoreArtists = try context.fetch(scoreArtistRequest)
        } catch {
            print("could not get artists")
        }
        
        var albums = [Album]()
        
        if unseenArtists!.count > 0 {
            for artist in unseenArtists! {
                albums.append(chooseAlbum(artist: artist))
            }
        }
        
        for artist in scoreArtists! {
            if unseenArtists!.contains(artist) {
                continue
            }
            albums.append(chooseAlbum(artist: artist))
        }
        
        return albums
    }
    
    private func chooseAlbum(artist: Artist) -> Album {
        let request = NSFetchRequest<Album>(entityName: "Album")
        let predicate = NSPredicate(format: "(seen = false) AND (artist = %@)", artist)
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        request.predicate = predicate
        request.fetchLimit = 5
        
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
        
        switch count {
        case 5:
            index = chooseIndex([0.45, 0.25, 0.15, 0.1, 0.05])
        case 4:
            index = chooseIndex([0.5, 0.25, 0.15, 0.1])
        case 3:
            index = chooseIndex([0.55, 0.3, 0.15])
        case 2:
            index = chooseIndex([0.7, 0.3])
        default:
            index = 0
        }
        
        return index
    }
    
    //Completion handler will be invoked after the last album data request has been processed. However, multiple album requests are made asynchronously, so it is possible that some will not have finished by the time the completionHandler is called, and the code invoking this method should not depend on that.
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
    func getAlbums(forArtist artistData: [String : AnyObject], completionHandler: DataManagerCompletionHandler?) {
        
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
    
    func getAlbums(searchString: String, artist artistData: [String : AnyObject], completionHandler: DataManagerCompletionHandler?) {
        
        client.getAlbums(ids: searchString) { result, error in
            
            guard let albumsData = result as? [[String : AnyObject]] else {
                print("bad data structure")
                return
            }
            
            let backgroundContext = self.stack.networkingContext
            
            backgroundContext.perform {
                
            
                let artist = Artist(id: artistData["id"] as! String, name: artistData["name"] as! String, context: backgroundContext)
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
                                 "Best of"]

    func titleContainsDissallowedKeywords(title: String) -> Bool {
        for keyword in DataManager.filterKeywords {
            if title.localizedCaseInsensitiveContains(keyword) {
                return true
            }
        }
        
        return false
    }
    
}


