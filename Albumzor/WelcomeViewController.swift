//
//  WelcomeViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

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
    }
    
}
