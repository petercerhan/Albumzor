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

protocol ResetDataViewControllerDelegate: NSObjectProtocol {
    func resetSucceeded()
    func resetFailed()
}

class ResetDataViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    weak var delegate: ResetDataViewControllerDelegate?
    var action: ResetDataAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if action == .reset {
            resetData()
        } else if action == .reseed {
            reseedData()
        }
        
    }
    
    func resetData() {
        dataManager.reset() { error in
            if let _ = error {
                //unexpected error state - core data updates should succeed
                self.delegate?.resetFailed()
            } else {
                DispatchQueue.main.async {
                    self.appDelegate.userSettings = UserSettings(instructionsSeen: false, isSeeded: false, autoplay: true)
                    self.appDelegate.saveUserSettings()
                    self.delegate?.resetSucceeded()
                }
            }
        }
    }
    
    func reseedData() {
        dataManager.reseed() { error in
            if let _ = error {
                //unexpected error state - core data updates should succeed
                self.delegate?.resetFailed()
            } else {
                DispatchQueue.main.async {
                    self.appDelegate.userSettings.isSeeded = false
                    self.appDelegate.saveUserSettings()
                    self.delegate?.resetSucceeded()
                }
            }
        }
    }
    
}

