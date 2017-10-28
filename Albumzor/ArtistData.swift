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
    var totalAlbums: Int
    var seenAlbums: Int
    var references: Int
    var score: Int {
        return references - seenAlbums
    }
    var relatedAdded: Bool
    let priorSeed: Bool
    
    init(id: String,
         name: String,
         imageURL: String? = nil,
         totalAlbums: Int = 0,
         seenAlbums: Int = 0,
         references: Int = 1,
         relatedAdded: Bool = false,
         priorSeed: Bool = false)
    {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.totalAlbums = totalAlbums
        self.seenAlbums = seenAlbums
        self.references = references
        self.relatedAdded = relatedAdded
        self.priorSeed = priorSeed
    }
    
    //MARK: - Initialize from json
    
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
            let id = dictionary["id"] as? String else {
                return nil
        }
        
        var imageURL: String?
        
        if let images = dictionary["images"] as? [[String : Any]],
                images.count >= 1,
                let largeImageURL = images[0]["url"] as? String
        {
            imageURL = largeImageURL
        }
        
        self.init(id: id, name: name, imageURL: imageURL)
    }
    
    //MARK: - Interface
    
    mutating func albumReviewed(liked: Bool) {
        seenAlbums += 1
        if liked { references += 1 }
    }
    
    mutating func referenced() {
        references += 1
    }
    
}

extension ArtistData: Equatable {
    static func == (lhs: ArtistData, rhs: ArtistData) -> Bool {
        return lhs.id == rhs.id
    }
}


