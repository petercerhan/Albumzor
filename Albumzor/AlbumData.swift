//
//  AlbumData.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/14/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

struct AlbumData {
    
    let id: String
    let name: String
    let popularity: Int
    var largeImage: String?
    var smallImage: String?
    
    var liked = false
    var likedDateTime = NSDate()
    var seen = false
    
    var priorSeed = false
    
    let imageData: Data? = nil
    let smallImageData: Data? = nil
    
    init?(jsonDictionary: [String: Any]) {
        guard
            let name = jsonDictionary["name"] as? String,
            let id = jsonDictionary["id"] as? String,
            !(AlbumDisallowedKeywords().containsDisallowedKeywords(name)),
            let popularity = jsonDictionary["popularity"] as? Int,
            let images = jsonDictionary["images"] as? [[String: Any]],
            images.count >= 3, let largeImage = images[0]["url"] as? String,
            let smallImage = images[1]["url"] as? String else
        {
            return nil
        }
        
        self.id = id
        self.name = name
        self.popularity = popularity
        self.largeImage = largeImage
        self.smallImage = smallImage
        
    }
    
    struct AlbumDisallowedKeywords {
        let allKeywords = ["Live",
                           "Collection",
                           "Duets",
                           "Anthology",
                           "Greatest Hits",
                           "20th Century Masters",
                           "Concert",
                           "Spotify",
                           "Best of",
                           "Essential"]
        
        func containsDisallowedKeywords(_ title: String) -> Bool {
            for keyword in allKeywords {
                if title.localizedCaseInsensitiveContains(keyword) {
                    return true
                }
            }
            return false
        }
    
    }
    
}


