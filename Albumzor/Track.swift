//
//  Track.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/28/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import CoreData

extension Track {
    
    convenience init(id: String, name: String, trackNo: Int, discNo: Int, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Track", in: context) {
            self.init(entity: entity, insertInto: context)
            self.id = id
            self.name = name
            self.track = Int16(trackNo)
            self.disc = Int16(discNo)
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
}
