//
//  PrepareAlbumsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import CoreData

protocol PrepareAlbumsViewControllerDelegate {
    func launchAlbumView(albums: [Album], albumArt: [UIImage], albumUsage: [AlbumUsage])
}

class PrepareAlbumsViewController: UIViewController {
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    
    var delegate: PrepareAlbumsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
                
        prepareAlbums()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareAlbums() {
        
        let albums = dataManager.getAlbums()
        var imageLinks = [String]()
        var albumsUsage = [AlbumUsage]()
        var albumIDs = [(spotifyID: String, managedObjectID: NSManagedObjectID)]()
        
        for album in albums {
            imageLinks.append(album.largeImage!)
            albumIDs.append((spotifyID: album.id!, managedObjectID: album.objectID))
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var albumArt = [UIImage]()
            for (index, imageLink) in imageLinks.enumerated() {
                
                if let imageData = try? Data(contentsOf: URL(string: imageLink)!) {
                    albumArt.append(UIImage(data: imageData)!)
                    albumsUsage.append( (seen: false, liked: false, starred: false, relatedAdded: false) )
                    self.dataManager.addTracks(forAlbumID: albumIDs[index].spotifyID, albumManagedObjectID: albumIDs[index].managedObjectID)
                }
                
            }

            DispatchQueue.main.async {
                self.delegate.launchAlbumView(albums: albums, albumArt: albumArt, albumUsage: albumsUsage)
            }
        }
    }
}


