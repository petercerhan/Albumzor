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
    
    //MARK: - Initialization
    
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
    
    convenience init(albumData: AlbumData, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Album", in: context) {
            self.init(entity: entity, insertInto: context)
            self.id = albumData.id
            self.name = albumData.name
            self.popularity = Int16(albumData.popularity)
            self.largeImage = albumData.largeImage
            self.smallImage = albumData.smallImage
            self.seen = albumData.seen
            self.liked = albumData.liked
            self.likedDateTime = albumData.likedDateTime
            if let imageData = albumData.imageData {
                self.imageData = NSData(data: imageData)
            }
            if let smallImageData = albumData.smallImageData {
                self.smallImageData = NSData(data: smallImageData)
            }
            self.priorSeed = albumData.priorSeed
            
        } else {
            fatalError("Unable to find 'Album' Entity name!")
        }
    }
    
    //MARK: - Convert to/from AlbumData Structure
    
    var albumDataRepresentation: AlbumData {
        return AlbumData(id: id!,
                         name: name!,
                         popularity: Int(popularity),
                         largeImage: largeImage!,
                         smallImage: smallImage!,
                         seen: seen,
                         liked: liked,
                         likedDateTime: likedDateTime!,
                         imageData: imageData as Data?,
                         smallImageData: smallImageData as Data?,
                         priorSeed: priorSeed)
    }
    
    func syncWithAlbumData(_ albumData: AlbumData) {
        id = albumData.id
        name = albumData.name
        popularity = Int16(albumData.popularity)
        largeImage = albumData.largeImage
        smallImage = albumData.smallImage
        seen = albumData.seen
        liked = albumData.liked
        likedDateTime = albumData.likedDateTime
        imageData = albumData.imageData as NSData?
        smallImageData = albumData.smallImageData as NSData?
        priorSeed = albumData.priorSeed
    }
    
}
