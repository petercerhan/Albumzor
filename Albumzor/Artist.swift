//
//  Artist.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/15/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import CoreData

extension Artist {
    
    convenience init(id: String, name: String, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Artist", in: context) {
            self.init(entity: entity, insertInto: context)
            self.id = id
            self.name = name
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
