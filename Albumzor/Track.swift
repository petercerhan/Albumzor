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
    
    convenience init(trackData: TrackData, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Track", in: context) {
            self.init(entity: entity, insertInto: context)
            self.id = trackData.id
            self.name = trackData.name
            self.popularity = Int16(trackData.popularity)
            self.track = Int16(trackData.trackNumber)
            self.disc = Int16(trackData.discNumber)
            self.previewURL = trackData.previewURL
            
        } else {
            fatalError("Unable to find 'Track' Entity name")
        }
    }
    
    //MARK: - Convert to/from TrackData Structure
    
    var trackDataRepresentation: TrackData {
        return TrackData(id: id!,
                         name: name!,
                         popularity: Int(popularity),
                         trackNumber: Int(track),
                         discNumber: Int(disc),
                         previewURL: previewURL)
    }
    
    
}
