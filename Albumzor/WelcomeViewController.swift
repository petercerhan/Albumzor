//
//  WelcomeViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import MediaPlayer

protocol WelcomeViewControllerDelegate {
    func chooseArtists()
}

class WelcomeViewController: UIViewController {

    var delegate: WelcomeViewControllerDelegate?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prompt app to ask for permission to use iTunes library
        _ = MPMediaQuery.artists()
    }

    @IBAction func chooseArtists() {
        animateOut()
        delegate?.chooseArtists()
    }
    
    func animateOut() {
        activityIndicator.startAnimating()
        titleLabel.alpha = 0.6
        messageLabel.alpha = 0.6
        doneButton.alpha = 0.6
        doneButton.isEnabled = false
    }
    
}
