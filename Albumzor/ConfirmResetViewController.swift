//
//  ConfirmResetViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol ConfirmResetViewControllerDelegate {
    func dismiss()
}

class ConfirmResetViewController: UIViewController {

    var delegate: ConfirmResetViewControllerDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func reset() {
        self.appDelegate.mainContainerViewController!.resetData(action: .reset)
        dismiss(animated: false)
    }
    
    @IBAction func cancel() {
        delegate?.dismiss()
    }
    
}
