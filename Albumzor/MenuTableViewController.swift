//
//  MenuTableViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/24/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate {
    func resetData(action: ResetDataAction)
}

class MenuTableViewController: UITableViewController {
    
    @IBOutlet var autoPlaySwitch: UISwitch!
    
    var delegate = (UIApplication.shared.delegate as! AppDelegate).mainContainerViewController!
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Menu"
        autoPlaySwitch.isOn = appDelegate.userSettings.autoplay
    }
    
    @IBAction func reseedInfo() {
        alert(title: "Re-Seed", message: "Choose new seed artists. \n\nThe current data used for suggesting albums will be erased, and you can choose a new set of seed artists.\n\nYour liked ablums will not be erased.", buttonTitle: "Done")
    }
    
    @IBAction func resetInfo() {
        alert(title: "Reset Data", message: "All data will be erased.\n\nThis includes your saved albums.", buttonTitle: "Done")
    }

    @IBAction func updateAutoplay(_ sender: UISwitch) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.userSettings.autoplay = sender.isOn
        appDelegate.saveUserSettings()
        print("Set autoplay \(sender.isOn)")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            reseedDataAlert()
        } else if indexPath.section == 0 && indexPath.row == 1 {
            resetDataAlert()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return false
        }
        return true
    }

    //MARK: - Alerts
    
    func reseedDataAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you would like to re-seed LPSwipe?\n\nYour saved albums will not be erased. You will need to choose new seed artists.", preferredStyle: .alert)
        
        let reseedAction = UIAlertAction(title: "Re-Seed", style: .default) { action in
            self.appDelegate.mainContainerViewController!.resetData(action: .reseed)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(reseedAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func resetDataAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you would like to reset LPSwipe?\n\nAll data will be erased.", preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { action in
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmResetViewController") as! ConfirmResetViewController
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension MenuTableViewController: ConfirmResetViewControllerDelegate {
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}





