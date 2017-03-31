//
//  ConfirmArtistViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/30/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol ConfirmArtistViewControllerDelegate {
    func artistChosen()
    func artistCanceled()
}

class ConfirmArtistViewController: UIViewController {

    var delegate: ConfirmArtistViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func back() {
        delegate.artistChosen()
    }

}

