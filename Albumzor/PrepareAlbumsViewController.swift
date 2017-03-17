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

        // Do any additional setup after loading the view.
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
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
