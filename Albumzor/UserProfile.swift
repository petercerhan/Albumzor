//
//  UserProfile.swift
//  Albumzor
//
//  Created by Peter Cerhan on 5/10/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class UserProfile: NSObject, NSCoding {
    
    var userMarket: String
    var spotifyConnected: Bool
    
    init(userMarket: String, spotifyConnected: Bool) {
        self.userMarket = userMarket
        self.spotifyConnected = spotifyConnected
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let userMarket = decoder.decodeObject(forKey: "userMarket") as? String else {
            return nil
        }
        let spotifyConnected = decoder.decodeBool(forKey: "spotifyConnected")
        
        self.init(userMarket: userMarket, spotifyConnected: spotifyConnected)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userMarket, forKey: "userMarket")
        aCoder.encode(spotifyConnected, forKey: "spotifyConnected")
    }
    
}


