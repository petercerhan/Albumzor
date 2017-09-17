//
//  UserProfileStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/17/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class UserProfileStateController {
    
    //MARK: - State
    
    let userProfile: UserProfile
    
    //MARK: - Initialization
    
    init() {
        if let data = UserDefaults.standard.object(forKey: "userProfile") as? Data,
            let userProfile = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserProfile {
                self.userProfile = userProfile
        } else {
            userProfile = UserProfile(userMarket: "None", spotifyConnected: false)
        }
    }
    
}

