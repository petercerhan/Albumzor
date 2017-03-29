//
//  AlbumDetailsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class AlbumDetailsViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var tracks: [Track]?
    
    var albumImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = albumImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tracks = tracks {
            for track in tracks {
                print("track \(track.track): \(track.name)")
            }
        }
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }

}
