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
    let largeImage: String
    let smallImage: String
    var seen: Bool
    var liked: Bool
    var likedDateTime: NSDate
    var imageData: Data?
    var smallImageData: Data?
    let priorSeed: Bool
    
    var artistName: String?
    
    var cleanName: String {
        if let index = name.index(of: "(") {
            return name.substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else if let index = name.index(of: "[") {
            return name.substring(to: index).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            return name
        }
    }
    
    init(id: String,
         name: String,
         popularity: Int,
         largeImage: String,
         smallImage: String,
         seen: Bool = false,
         liked: Bool = false,
         likedDateTime: NSDate = NSDate(),
         imageData: Data? = nil,
         smallImageData: Data? = nil,
         priorSeed: Bool = false)
    {
        self.id = id
        self.name = name
        self.popularity = popularity
        self.largeImage = largeImage
        self.smallImage = smallImage
        self.seen = seen
        self.liked = liked
        self.likedDateTime = likedDateTime
        self.imageData = imageData
        self.smallImageData = smallImageData
        self.priorSeed = priorSeed
    }
    
    //MARK: - Initialize from json
    
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
        
        self.init(id: id, name: name, popularity: popularity, largeImage: largeImage, smallImage: smallImage)
    }
    
    //MARK: - Review Album
    
    mutating func review(liked albumLiked: Bool) {
        seen = true
        if albumLiked {
            liked = true
            likedDateTime = NSDate()
        }
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
                           "Essential",
                           "Hits",
                           "Music From"]
        
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

extension AlbumData: Equatable {
    static func == (lhs: AlbumData, rhs: AlbumData) -> Bool {
        return lhs.id == rhs.id
    }
}

