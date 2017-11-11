//
//  ArchivingService.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/25/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol ArchivingServiceProtocol {
    func unarchiveObject(forKey key: String) -> Any?
    func archive(object: NSCoding, forKey key: String)
    func removeObject(forKey key: String)
}

class UserDefaultsArchivingService: ArchivingServiceProtocol {
    func unarchiveObject(forKey key: String) -> Any? {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data,
            let object = NSKeyedUnarchiver.unarchiveObject(with: data) else {
                return nil
        }
        
        return object
    }
    
    func archive(object: NSCoding, forKey key: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func removeObject(forKey key: String) {
        
    }
}
