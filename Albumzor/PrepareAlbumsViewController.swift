//
//  PrepareAlbumsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import CoreData

class PrepareAlbumsViewController: UIViewController {
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Prepare Albums VC Did Load")
    }
    
    override func viewDidAppear(_ animated: Bool) {
                
        //prepareAlbums()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareAlbums() {
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        request.fetchLimit = 10
        
        var albumArt = [UIImage]()
        var albums = [Album]()
        
        do {
            let albumsTry = try stack.context.fetch(request)
            albums = albumsTry
            for album in albums {
                //print("Album \(album.name!), popularity: \(album.popularity)")
                
                if let imageData = try? Data(contentsOf: URL(string: album.largeImage!)!) {
                    albumArt.append(UIImage(data: imageData)!)
                }
                
            }
        } catch {
            
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AlbumsViewController") as! AlbumsViewController
        vc.albumArt = albumArt
        vc.albums = albums
        present(vc, animated: true, completion: nil)
    }
    
}


