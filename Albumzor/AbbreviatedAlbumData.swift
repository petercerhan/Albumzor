//
//  AbbreviatedAlbumData.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/14/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

struct AbbreviatedAlbumData {
    
    let id: String
    let name: String
    
    init?(jsonDictionary: [String: Any]) {
        guard let name = jsonDictionary["name"] as? String,
            let id = jsonDictionary["id"] as? String,
            !(AlbumData.AlbumDisallowedKeywords().containsDisallowedKeywords(name)) else
        {
            return nil
        }
        
        self.id = id
        self.name = name
    }
    
}

