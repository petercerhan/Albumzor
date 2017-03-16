//
//  DataManager.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class DataManager {
    
    let client = SpotifyClient.sharedInstance()
    
    func getInitialData() {
        
        //start with artist search
        client.searchArtist(searchString: "Bad Bad Not Good") { result, error in
            
            if let error = error {
                print("Networking Error \(error)")
                return
            }
            
            guard let artistData = result as? [String : AnyObject] else {
                print("Networking Error \(error)")
                return
            }
            
            //Check that artist data is correct/exists; create and store artist object in core data
            
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
                
                var albumString = ""
                
                for (index, album) in albumsData.enumerated() {
                    albumString += (album["id"] as? String ?? "")
                    
                    if index != albumsData.count - 1 {
                        albumString += ","
                    }
                    
                }
                
                self.getAlbums(searchString: albumString, artist: artist)
            }
        }
    }
    
    func getAlbums(searchString: String, artist: Artist) {
        let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
        
        client.getAlbums(ids: searchString) { result, error in
            
            guard let albumsData = result as? [[String : AnyObject]] else {
                print("bad data structure")
                return
            }
            
            for album in albumsData {
                guard let id = album["id"] as? String, let name = album["name"] as? String, let popularity = album["popularity"] as? Int, let images = album["images"] as? [[String : AnyObject]], let largeImage = images[0]["url"] as? String, let smallImage = images[2]["url"]  as? String else {
                    print("incomplete album data for album \(album["name"] as? String ?? "")")
                    return
                }
                
                let album = Album(id: id, name: name, popularity: Int16(popularity), largeImage: largeImage, smallImage: smallImage, context: stack.persistingContext)
                album.artist = artist
            }
            
            do {
                try stack.persistingContext.save()
            } catch {
                print("Could not save context")
            }
        }
        
    }
}



