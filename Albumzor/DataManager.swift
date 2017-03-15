//
//  DataManager.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class DataManager {
    
    let client = SpotifyClient.sharedInstance()
    
    func getInitialData() {
        
        let parameters = [SpotifyClient.ParameterKeys.searchQuery : "Red hot chili peppers", SpotifyClient.ParameterKeys.searchType : "artist"]

        _ = client.task(getMethod: SpotifyClient.Methods.search, parameters: parameters) { result, error in

            if let error = error {
                print("error: \(error)")
                return
            }

            //check against empty array?
            guard let result = result as? [String : AnyObject], let artists = result["artists"] as? [String : AnyObject], let items = artists["items"] as? [[String : AnyObject]] else {
                print("Data not formatted correctly")
                return
            }

            let artist = items[0]
            
            //get related artists
            print("artist: \(artist["id"] as? String ?? "")")
            
            self.getRelatedArtists(artist: artist["id"] as! String)
        }
        
    }
    
    func getRelatedArtists(artist artistID: String) {
        
        client.getRelatedArtists(forArtist: artistID) { result, error in
            
            if let error = error {
                print("error: \(error)")
                return
            }
            
            guard let result = result as? [String : AnyObject], let artistsData = result["artists"] as? [[String : AnyObject]] else {
                print("Data not formatted correctly")
                return
            }
     
            var artists = [Artist]()
            
            for artist in artistsData {
                guard let name = artist["name"] as? String, let id = artist["id"] as? String else {
                    continue
                }
                artists.append(Artist(id: id, name: name))
            }
            
            self.getAlbums(forArtists: artists)
        }
        
    }
    
    
    func getAlbums(forArtists artists: [Artist]) {
        let artistID = artists[0].id
        
        for artist in artists {
            client.getAlbums(forArtist: artist.id) { result, error in
                
                if let error = error {
                    print("error: \(error)")
                    return
                }
                
                guard let result = result as? [String : AnyObject], let items = result["items"] as? [[String : AnyObject]] else {
                    print("Bad return data")
                    return
                }
                
                var albumString = ""
                
                for (index, album) in items.enumerated() {
                    albumString += (album["id"] as? String ?? "")
                    
                    if index != items.count - 1 {
                        albumString += ","
                    }
                    
                }
                
                self.getAlbums(searchString: albumString)
                
            }
        }
    }
    
    func getAlbums(searchString: String) {
        client.getAlbums(ids: searchString) { result, error in
            
            guard let result = result as? [String : AnyObject], let albums = result["albums"] as? [[String : AnyObject]] else {
                print("bad data structure")
                return
            }
            
            for album in albums {
                print("Album: \(album["name"] as? String ?? ""), popularity: \(album["popularity"] as? Int ?? 0)")
            }
        }
        
    }
}
