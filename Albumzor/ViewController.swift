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
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).coreDataStack
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addArtist() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchArtistViewController") as! SearchArtistViewController
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func discoverAlbums() {
        let vc = AlbumsContainerViewController()
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func testData() {
        testArtistData()
    }
    
    func testAlbumData() {
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        do {
            let albumsTry = try self.stack.context.fetch(request)
            for album in albumsTry {
                print("Album \(album.name!), popularity: \(album.seen)")
            }
        } catch {
            
        }
    }
    
    func testArtistData() {
        let request = NSFetchRequest<Artist>(entityName: "Artist")
        request.sortDescriptors = [NSSortDescriptor(key: "references", ascending: false)]
        do {
            let artists = try self.stack.context.fetch(request)
            for artist in artists {
                print("Artist \(artist.name!), References: \(artist.references)")
            }
        } catch {
            
        }
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
