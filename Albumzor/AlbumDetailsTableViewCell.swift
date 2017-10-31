//
//  AlbumDetailsTableViewCell.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/3/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AlbumDetailsTableViewCell: UITableViewCell {

    @IBOutlet var albumImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    var spotifyButtonCallback: ( () -> () )?
    
    @IBAction func spotifyButtonPressed() {
        if let callback = spotifyButtonCallback {
            callback()
        }
    }
    
}
