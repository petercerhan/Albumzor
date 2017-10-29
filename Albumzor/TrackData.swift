//
//  TrackData.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/28/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

struct TrackData {
    
    let id: String
    let name: String
    let popularity: Int
    let trackNumber: Int
    let discNumber: Int
    let previewURL: String?
    
    init(id: String,
         name: String,
         popularity: Int?,
         trackNumber: Int = 0,
         discNumber: Int = 0,
         previewURL: String?)
    {
        self.id = id
        self.name = name
        self.popularity = popularity ?? 0
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.previewURL = previewURL
    }
    
    init?(jsonDictionary: [String: Any]) {
        guard
            let id = jsonDictionary["id"] as? String,
            let name = jsonDictionary["name"] as? String,
            let trackNumber = jsonDictionary["track_number"] as? Int,
            let discNumber = jsonDictionary["disc_number"] as? Int else
        {
            return nil
        }
        
        let popularity = jsonDictionary["popularity"] as? Int
        let previewURL = jsonDictionary["preview_url"] as? String
        
        self.init(id: id, name: name, popularity: popularity, trackNumber: trackNumber, discNumber: discNumber, previewURL: previewURL)
    }
    
}

extension TrackData: Equatable {
    static func == (lhs: TrackData, rhs: TrackData) -> Bool {
        return lhs.id == rhs.id
    }
}
