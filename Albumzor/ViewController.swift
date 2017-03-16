//
//  ViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var chilisID = "0L8ExT028jH3ddEcZwqJJ5"
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        DataManager().getInitialData()
        
        
    }
    
    @IBAction func getInfo() {
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
        
        print("images \(albumArt.count)")
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "AlbumsViewController") as! AlbumsViewController
        vc.albumArt = albumArt
        vc.albums = albums
        present(vc, animated: true, completion: nil)
        
        
        
      //  let request = NSFetchRequest<Artist>(entityName: "Artist")
        
        

//        
////        do {
////            let artists = try stack.context.fetch(request)
////            
////            for artist in artists {
////                print("Artist \(artist.name!), id: \(artist.id!)")
////            }
////            
////        } catch {
////            //Could not get data
////        }
//
        
        
        //        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        
        
        
    }
    
    
    func getSpotifyAPIKey() -> String? {
        
        let filePath = Bundle.main.path(forResource: "SpotifyApiKey", ofType: "txt")

        print("file path: \(filePath)")
        
        do {
            let textString = try String(contentsOfFile: filePath!)
            return textString
        } catch {
            print("error reading file to string")
        }
        
        return nil
    }
    

}
