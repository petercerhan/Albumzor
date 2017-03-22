//
//  DataManager.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import CoreData

class DataManager {
    
    let client = SpotifyClient.sharedInstance()
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
    func getInitialData() {
        
        //start with artist search
        client.searchArtist(searchString: "Bob Dylan") { result, error in
            
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
            
            self.getRelatedArtists(artist: artistData["id"] as! String)
        }
    }
    
    func getRelatedArtists(artist artistID: String) {

        let delegate = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
        
        client.getRelatedArtists(forArtist: artistID) { result, error in
            
            if let error = error {
                print("error: \(error)")
                return
            }
            
            guard let artistsData = result as? [[String : AnyObject]] else {
                print("Data not formatted correctly")
                return
            }
     
            var artists = [Artist]()

            //Probably don't need to make this array of artists
            for artist in artistsData {
                guard let name = artist["name"] as? String, let id = artist["id"] as? String else {
                    continue
                }
                artists.append(Artist(id: id, name: name, context: delegate.persistingContext))
            }
            
            self.getAlbums(forArtists: artists)
        }
    }
    
    func getAlbums(forArtists artists: [Artist]) {
        
        for artist in artists {
            client.getAlbums(forArtist: artist.id!) { result, error in
                
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
                
                self.getAlbums(searchString: albumSearchString, artist: artist)
            }
        }
    }
    
    func getAlbums(searchString: String, artist: Artist) {
        
        client.getAlbums(ids: searchString) { result, error in
            
            guard let albumsData = result as? [[String : AnyObject]] else {
                print("bad data structure")
                return
            }
            
            //unpack albums
            var albumsArray = [Album]()
            for album in albumsData {
                guard let id = album["id"] as? String,
                      let name = album["name"] as? String,
                      let popularity = album["popularity"] as? Int,
                      let images = album["images"] as? [[String : AnyObject]],
                      let largeImage = images[0]["url"] as? String,
                      let smallImage = images[2]["url"]  as? String else {

                    print("incomplete album data for album \(album["name"] as? String ?? "")")
                    continue
                }
                
                if self.titleContainsDissallowedKeywords(title: name) {
                    continue
                }
                
                let album = Album(id: id, name: name, popularity: Int16(popularity), largeImage: largeImage, smallImage: smallImage, context: self.stack.persistingContext)
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
            
            for (index, album) in albumsArray.enumerated() {
                if index != 0 {
                    if album.name!.cleanAlbumName().localizedCaseInsensitiveCompare(albumsArray[index - 1].name!.cleanAlbumName()) == ComparisonResult.orderedSame {
                        self.stack.persistingContext.delete(album as NSManagedObject)
                    }
                }
            }
            
            do {
                try self.stack.persistingContext.save()
            } catch {
                print("Could not save context")
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


