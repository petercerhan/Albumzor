//
//  ArtistData.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/30/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

struct ArtistData {
    let id: String
    let name: String
    let imageURL: String?
    let priorSeed: Bool = false
    let references: Int = 1
    let relatedAdded: Bool = false
    let score: Int = 1
    let seenAlbums: Int = 0
    let totalAlbums: Int = 0
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        imageURL = nil
    }
    
    init?(dictionary: [String : Any]) {
        
        guard let name = dictionary["name"] as? String,
            let id = dictionary["id"] as? String else {
                return nil
        }
        
        self.id = id
        self.name = name
        
        if let images = dictionary["images"] as? [[String : Any]],
                images.count >= 3,
                let largeImageURL = images[0]["url"] as? String {
            imageURL = largeImageURL
        } else {
            imageURL = nil
        }
    }
    
}
