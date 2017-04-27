//
//  ResetDataViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/26/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

enum ResetDataAction {
    case reset, reseed
}

protocol ResetDataViewControllerDelegate {
    func resetSucceeded()
    func resetFailed()
}

class ResetDataViewController: UIViewController {

    var delegate: ResetDataViewControllerDelegate?
    var action: ResetDataAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if action == .reset {
            print("reset")
        } else if action == .reseed {
            print("reseed")
        }
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func tempAction() {
        delegate?.resetFailed()
    }
    
}
