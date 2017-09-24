//
//  UserInfo.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/24/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

struct UserInfo {
    let userMarket: String
    
    //Initialize from json
    init?(dictionary: [String: Any]) {
        guard let userMarket = dictionary["country"] as? String else {
            return nil
        }
        
        self.userMarket = userMarket
    }
}
