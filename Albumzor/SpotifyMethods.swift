//
//  SpotifyMethods.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//


import Foundation

extension SpotifyClient {
    
    func getAlbums(forArtist artistID: String,completion: @escaping SpotifyCompletionHandler) {
        
        let finalMethod = replace(placeholder: "id", inMethod: Methods.getArtistAlbums, value: artistID)
        
        _ = task(getMethod: finalMethod, parameters: [String : AnyObject]()) { result, error in
            print("this this")
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
            
            print("first album \(items[0])")
            
        }
        
        
    }
    
    
    
    
}
