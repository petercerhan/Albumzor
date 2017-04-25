//
//  InstructionsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol InstructionsViewControllerDelegate {
    func instructionsSceneComplete()
}

class InstructionsViewController: UIViewController {

    var delegate: InstructionsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func getStarted() {
        delegate?.instructionsSceneComplete()
    }
}
