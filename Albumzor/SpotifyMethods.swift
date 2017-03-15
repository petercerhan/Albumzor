//
//  SpotifyMethods.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//


import Foundation

extension SpotifyClient {
    
    //Sends the top result as [String : AnyObject] to the completion handler
    func searchArtist(searchString: String, completion: @escaping SpotifyCompletionHandler) {
        let parameters = [SpotifyClient.ParameterKeys.searchQuery : searchString, SpotifyClient.ParameterKeys.searchType : "artist"]
        
        _ = task(getMethod: SpotifyClient.Methods.search, parameters: parameters) { result, error in
            
            if let error = error {
                print("error: \(error)")
                return
            }
            
            //check against empty array?
            guard let result = result as? [String : AnyObject], let artists = result["artists"] as? [String : AnyObject], let items = artists["items"] as? [[String : AnyObject]], items.count != 0 else {
                print("Data not formatted correctly")
                return
            }
            
            completion(items[0] as AnyObject?,nil)

        }

        
        
    }
    
    func getAlbums(forArtist artistID: String, completion: @escaping SpotifyCompletionHandler) {
        
        let parameters = ["album_type" : "album", "market" : "US"]
        
        let method = replace(placeholder: "id", inMethod: Methods.getArtistAlbums, value: artistID)
        
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
    
    func getAlbums(ids: String, completion: @escaping SpotifyCompletionHandler) {
        let parameters = ["ids" : ids]
        
        _ = task(getMethod: Methods.getAlbums, parameters: parameters) { result, error in
            
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
