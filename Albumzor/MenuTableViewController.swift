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

            (UIApplication.shared.delegate as! AppDelegate).mainContainerViewController!.resetData(action: .reseed)
            

        }
    }

}
