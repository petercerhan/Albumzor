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
    
    var albumImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = albumImage
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }

}
