//
//  WelcomeViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import MediaPlayer
import GameplayKit

protocol WelcomeViewControllerDelegate {
    func chooseArtists()
}

class WelcomeViewController: UIViewController {

    var delegate: WelcomeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func chooseArtists() {
        delegate?.chooseArtists()
        //let _ = getAlbumsFromItunes()
    }
    
    func getAlbumsFromItunes() -> [String]? {
        let artistQuery = MPMediaQuery.artists()
        
        guard let mediaItemsArray = artistQuery.items else {
            return nil
        }
        
        let rawArtistNames = mediaItemsArray.map { mediaItem in return mediaItem.albumArtist ?? "" }
        var artistSet = Set(rawArtistNames)
        let emptyStringSet: Set = ["", " "]
        artistSet = artistSet.subtracting(emptyStringSet)
        
        var namesArray = Array(artistSet)
        namesArray = namesArray.map { artistName in return artistName.cleanArtistName() }
        namesArray = namesArray.map { artistName in return artistName.truncated(maxLength: 30) }
        
        //Remove any new duplicates after cleaning up artist names
        namesArray = Array(Set(namesArray))
        namesArray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: namesArray) as! Array<String>
        
        for object in namesArray {
            print("Artist: \(object)")
        }
        
        if namesArray.count < 15 {
            return nil
        } else {
            return namesArray
        }
    }
    
}
