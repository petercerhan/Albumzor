//
//  SpotifyMethods.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//


import Foundation

extension SpotifyClient {
    
    func getAlbums(forArtist artistID: String, completion: @escaping SpotifyCompletionHandler) {
        
        let parameters = ["album_type" : "album", "market" : "US"]
        
        let method = replace(placeholder: "id", inMethod: Methods.getArtistAlbums, value: artistID)
        
        _ = task(getMethod: method, parameters: parameters) { result, error in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let result = result as? [String : AnyObject], let items = result["items"] as? [[String : AnyObject]] else {
                print("Bad return data")
                return
            }
            
            for album in items {
                print("Album: \(album["name"] as? String ?? "unfound") Album_type: \(album["album_type"] as? String ?? "unfound")")
            }
        }
    }
    
    func getRelatedArtists(forArtist artistID: String, completion: @escaping SpotifyCompletionHandler) {
        let parameters = [String : String]()
        
        let method = replace(placeholder: "id", inMethod: Methods.getRelatedArtists, value: artistID)
        
        _ = task(getMethod: method, parameters: parameters) { result, error in
            
            if let error = error {
                completion(nil, error)
                return
            } else {
                completion(result, nil)
                return
            }
        }
    }
    
}
