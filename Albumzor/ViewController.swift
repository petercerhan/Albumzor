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
        
      //  let request = NSFetchRequest<Artist>(entityName: "Artist")
        
        
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.sortDescriptors = [NSSortDescriptor(key: "popularity", ascending: false)]
        
//        do {
//            let artists = try stack.context.fetch(request)
//            
//            for artist in artists {
//                print("Artist \(artist.name!), id: \(artist.id!)")
//            }
//            
//        } catch {
//            //Could not get data
//        }
        
        do {
            let albums = try stack.context.fetch(request)
            
            
            for album in albums {
                print("Album \(album.name!), popularity: \(album.popularity)")
            }
        } catch {
            
        }
        
        
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
