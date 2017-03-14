//
//  DataManager.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class DataManager {
    
    func getInitialData() {
        
        let client = SpotifyClient.sharedInstance()
        
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
            
        }
        
    }
    
    func getRelatedArtists() {
        
    }
    
    
    
    
    
}
