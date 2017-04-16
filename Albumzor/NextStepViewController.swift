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
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var symbolLabel1: UILabel!
    @IBOutlet var symbolLabel2: UILabel!
    
    @IBOutlet var moreAlbumsButton: UIButton!
    @IBOutlet var viewAlbumsButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        symbolLabel1.text = "\u{1F3B5}"
        symbolLabel2.text = "\u{1F3B5}"
        
        countLabel.alpha = 0.0
        label3.alpha = 0.0
        symbolLabel1.alpha = 0.0
        symbolLabel2.alpha = 0.0
        moreAlbumsButton.alpha = 0.0
        viewAlbumsButton.alpha = 0.0
        homeButton.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    @IBAction func home() {
        delegate.quit()
    }
    
    @IBAction func continueBrowsing() {
        delegate.nextBattery()
    }
    
    func animateIn() {
        
        //1) Line 1
//        UIView.animate(withDuration: 0.4,
//                       delay: 0.6,
//                       options: .curveLinear,
//                       animations: {
//                            self.messageLabel.alpha = 1.0
//                        },
//                       completion: nil)
        var delay = 0.7
        
        //2) Line 2
        UIView.animate(withDuration: 0.4,
                       delay: delay,
                       options: .curveLinear,
                       animations: {
                        self.countLabel.alpha = 1.0
                        self.symbolLabel1.alpha = 1.0
                        self.symbolLabel2.alpha = 1.0
        },
                       completion: nil)
        
        delay += 1.0
        //2) Line 3
        UIView.animate(withDuration: 0.4,
                       delay: delay,
                       options: .curveLinear,
                       animations: {
                        self.label3.alpha = 1.0
        },
                       completion: nil)
        
        
        delay += 0.6
        //2) 1st Button
        UIView.animate(withDuration: 0.4,
                       delay: delay,
                       options: .curveLinear,
                       animations: {
                        self.moreAlbumsButton.alpha = 1.0
        },
                       completion: nil)
        
        
        delay += 0.1
        //2) 2nd Button
        UIView.animate(withDuration: 0.4,
                       delay: delay,
                       options: .curveLinear,
                       animations: {
                        self.viewAlbumsButton.alpha = 1.0
        },
                       completion: nil)
        
        delay += 0.1
        //2) 3rd Button
        UIView.animate(withDuration: 0.4,
                       delay: delay,
                       options: .curveLinear,
                       animations: {
                        self.homeButton.alpha = 1.0
        },
                       completion: nil)
        
        
    }

}
