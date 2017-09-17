//
//  UserSettingsStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/17/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class UserSettingsStateController {
    
    //MARK: - State
    
    private let userSettings: UserSettings
    
    //MARK: - Initialization
    
    init() {
        if let data = UserDefaults.standard.object(forKey: "userSettings") as? Data,
            let userSettings = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserSettings {
            
            self.userSettings = userSettings
        } else {
            userSettings = UserSettings(instructionsSeen: false, isSeeded: false, autoplay: true, albumSortType: 0)
        }
    }
    
    //MARK: - State getters
    
    func instructionsSeen() -> Bool {
        return userSettings.instructionsSeen
    }
    
    func isSeeded() -> Bool {
        return userSettings.isSeeded
    }
    
    func isAutoplayEnabled() -> Bool {
        return userSettings.autoplay
    }
    
    func getAlbumSortType() -> Int {
        return userSettings.albumSortType
    }
}
