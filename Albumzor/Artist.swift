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
    
    //MARK: - Initialization
    
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
            self.totalAlbums = Int16(artistData.totalAlbums)
            self.seenAlbums = Int16(artistData.seenAlbums)
            self.references = Int16(artistData.references)
            self.score = Int16(artistData.score)
            self.relatedAdded = artistData.relatedAdded
            self.priorSeed = artistData.priorSeed
        } else {
            fatalError("Unable to find 'Artist' Entity name!")
        }
        
    }
    
    //MARK: - Convert to/from ArtistData Structure
    
    var artistDataRepresentation: ArtistData {
        return ArtistData(id: id!,
                          name: name!,
                          imageURL: nil,
                          totalAlbums: Int(totalAlbums),
                          seenAlbums: Int(seenAlbums),
                          references: Int(references),
                          relatedAdded: relatedAdded,
                          priorSeed: priorSeed)
    }
    
    func syncWithArtistData(_ artistData: ArtistData) {
        id = artistData.id
        name = artistData.name
        totalAlbums = Int16(artistData.totalAlbums)
        seenAlbums = Int16(artistData.seenAlbums)
        references = Int16(artistData.references)
        score = Int16(artistData.score)
        relatedAdded = artistData.relatedAdded
        priorSeed = artistData.priorSeed
    }
    
}






