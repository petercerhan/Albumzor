//
//  Album.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/15/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import CoreData

extension Album {
    
    convenience init(id: String, name: String, popularity: Int16, largeImage: String, smallImage: String, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Album", in: context) {
            self.init(entity: entity, insertInto: context)
            self.id = id
            self.name = name
            self.popularity = popularity
            self.largeImage = largeImage
            self.smallImage = smallImage
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
