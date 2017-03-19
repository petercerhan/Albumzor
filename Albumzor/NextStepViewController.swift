//
//  NextStepViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/18/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol NextStepViewControllerDelegate {
    func quit()
    func nextBattery()
}

class NextStepViewController: UIViewController {

    var delegate: NextStepViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func home() {
        delegate.quit()
    }
    
    @IBAction func continueBrowsing() {
        delegate.nextBattery()
    }

}
