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
    func launchAlbumView(albums: [Album], albumArt: [UIImage])
    func cancelPrepareAlbums()
}

class PrepareAlbumsViewController: UIViewController {
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    
    var delegate: PrepareAlbumsViewControllerDelegate!
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        prepareAlbums()
    }
    
    //MARK:- User Actions
    
    @IBAction func cancel() {
        delegate.cancelPrepareAlbums()
    }
    
    func prepareAlbums() {
        
        let albums = dataManager.getAlbums()
        
        var outputAlbums = [Album]()
        var imageLinks = [String]()
        var albumIDs = [(spotifyID: String, managedObjectID: NSManagedObjectID)]()
        
        for album in albums {
            imageLinks.append(album.largeImage!)
            albumIDs.append((spotifyID: album.id!, managedObjectID: album.objectID))
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var albumArt = [UIImage]()
            for (index, imageLink) in imageLinks.enumerated() {
                
                //stop adding albums after 10 images successfully downloaded
                guard outputAlbums.count < 11 else {
                    continue
                }
                
                guard let url = URL(string: imageLink) else {
                    continue
                }
                
                if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                    albumArt.append(image)
                    outputAlbums.append(albums[index])
                    self.dataManager.addTracks(forAlbumID: albumIDs[index].spotifyID, albumManagedObjectID: albumIDs[index].managedObjectID)
                }
                
            }
            
            guard albumArt.count > 5 else {
                
                //try to get more albums
                
                
                DispatchQueue.main.async {
                    self.couldNotLoadAlbums()
                }
                return
            }

            DispatchQueue.main.async {
                self.delegate.launchAlbumView(albums: outputAlbums, albumArt: albumArt)
            }
        }
    }
    
    func couldNotLoadAlbums() {
        let alert = UIAlertController(title: "Download Error", message: "Could not download albums. Make sure you are connected to the internet.", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { action in
            self.delegate.cancelPrepareAlbums()
        }
        
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
}


