//
//  AbbreviatedTrackData.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/28/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

struct AbbreviatedTrackData {
    
    let id: String
    
    init?(jsonDictionary: [String: Any]) {
        guard let id = jsonDictionary["id"] as? String else {
            return nil
        }
        
        self.id = id
    }
    
}
