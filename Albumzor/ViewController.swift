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
    
    @IBAction func artistChooser() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChooseArtistViewController") as! ChooseArtistViewController
        present(vc, animated: true, completion: nil)
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
        do {
            try stack.dropAllData()
        } catch {
            print("Could not reset data model")
        }
    }
    
    func testAlbumChoice() {
        let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
        let albums = dataManager.getAlbums()
        for album in albums {
            print("album \(album.name!) artist \(album.artist!.name!)")
        }
    }
    
    func testAlbumData() {
        let request = NSFetchRequest<Album>(entityName: "Album")
        request.sortDescriptors = [NSSortDescriptor(key: "seen", ascending: false)]
        
        do {
            let albumsTry = try self.stack.context.fetch(request)
            for album in albumsTry {
                print("Album \(album.name!), seen: \(album.seen)")
            }
        } catch {
            
        }
    }
    
    func testArtistData() {
        let request = NSFetchRequest<Artist>(entityName: "Artist")
        request.sortDescriptors = [NSSortDescriptor(key: "seenAlbums", ascending: false)]
        do {
            let artists = try self.stack.context.fetch(request)
            for artist in artists {
                print("Artist \(artist.name!), Score: \(artist.score)")
            }
        } catch {
            
        }
        print("-")
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
