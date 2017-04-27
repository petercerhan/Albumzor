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
    
    
    var delegate = (UIApplication.shared.delegate as! AppDelegate).mainContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Menu"
    }
    
    @IBAction func reseedInfo() {
        alert(title: "Re-Seed", message: "Choose new seed artists. \n\nThe current data used for suggesting albums will be erased, and you can choose a new set of seed artists.\n\nYour liked ablums will not be erased.", buttonTitle: "Done")
    }
    
    @IBAction func resetInfo() {
        alert(title: "Reset Data", message: "All data will be erased.\n\nThis includes your saved albums.", buttonTitle: "Done")
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
    }

    //MARK: - Alerts
    
    func reseedDataAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you would like to re-seed LPSwipe?\n\nYour saved albums will not be erased. You will need to choose new seed artists.", preferredStyle: .alert)
        
        let reseedAction = UIAlertAction(title: "Re-Seed", style: .default) { action in
            (UIApplication.shared.delegate as! AppDelegate).mainContainerViewController!.resetData(action: .reseed)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(reseedAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func resetDataAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you would like to reset LPSwipe?\n\nAll data will be erased.", preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { action in
            (UIApplication.shared.delegate as! AppDelegate).mainContainerViewController!.resetData(action: .reset)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}







