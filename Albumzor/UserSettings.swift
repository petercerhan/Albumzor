//
//  UserSettings.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/24/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class UserSettings: NSObject, NSCoding {
    
    var instructionsSeen: Bool
    var isSeeded: Bool
    var autoplay: Bool
    var albumSortType: Int
    
    init(instructionsSeen: Bool = false,
         isSeeded: Bool = false,
         autoplay: Bool = true,
         albumSortType: Int = 0)
    {
        self.instructionsSeen = instructionsSeen
        self.isSeeded = isSeeded
        self.autoplay = autoplay
        self.albumSortType = albumSortType
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let instructionsSeen = decoder.decodeBool(forKey: "instructionsSeen")
        let isSeeded = decoder.decodeBool(forKey: "isSeeded")
        let autoplay = decoder.decodeBool(forKey: "autoplay")
        let albumSortType = Int(decoder.decodeInt32(forKey: "albumSortType"))
        
        self.init(instructionsSeen: instructionsSeen, isSeeded: isSeeded, autoplay: autoplay, albumSortType: albumSortType)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(instructionsSeen, forKey: "instructionsSeen")
        aCoder.encode(isSeeded, forKey: "isSeeded")
        aCoder.encode(autoplay, forKey: "autoplay")
        aCoder.encode(Int32(albumSortType), forKey: "albumSortType")
    }
    
}



