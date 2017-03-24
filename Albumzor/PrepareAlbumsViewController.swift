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
}

class PrepareAlbumsViewController: UIViewController {
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
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
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        request.fetchLimit = 10
        
        var albums = [Album]()
        
        do {
            let albumsTry = try self.stack.context.fetch(request)
            albums = albumsTry

        } catch {
            
        }
        
        var albumArt = [UIImage]()
        for album in albums {
            //print("Album \(album.name!), popularity: \(album.popularity)")
            
            if let imageData = try? Data(contentsOf: URL(string: album.largeImage!)!) {
                albumArt.append(UIImage(data: imageData)!)
            }
            
        }
    
        self.delegate.launchAlbumView(albums: albums, albumArt: albumArt)
            
    }
}


