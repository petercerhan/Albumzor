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
            fatalError("Unable to find 'Artist' Entity name!")
        }
    }
    
    convenience init(artistData: ArtistData, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Artist", in: context) {
            self.init(entity: entity, insertInto: context)
            self.id = artistData.id
            self.name = artistData.name
            self.priorSeed = artistData.priorSeed
            self.references = Int16(artistData.references)
            self.relatedAdded = artistData.relatedAdded
            self.score = Int16(artistData.score)
            self.seenAlbums = Int16(artistData.seenAlbums)
            self.totalAlbums = Int16(artistData.totalAlbums)
        } else {
            fatalError("Unable to find 'Artist' Entity name!")
        }
        
    }
    
    var artistDataRepresentation: ArtistData {
        return ArtistData(id: id!, name: name!)
    }
    
}





