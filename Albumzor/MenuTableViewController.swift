//
//  MenuTableViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/24/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate: NSObjectProtocol {
    func resetData(action: ResetDataAction)
    func spotifyDisconnected()
}

protocol MenuDelegate: NSObjectProtocol {
    func refreshAlbumDisplay()
}

class MenuTableViewController: UITableViewController {
    
    @IBOutlet var autoPlaySwitch: UISwitch!
    @IBOutlet var sortAlbumsLabel: UILabel!
    
    weak var delegate = (UIApplication.shared.delegate as! AppDelegate).mainContainerViewController!
    weak var menuDelegate: MenuDelegate?
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    var shouldReloadAlbums = false
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Options"
        autoPlaySwitch.isOn = appDelegate.userSettings.autoplay
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let albumSortType = AlbumSortType(rawValue: appDelegate.userSettings.albumSortType) else {
            return
        }
        
        switch albumSortType {
        case .dateAdded:
            sortAlbumsLabel.text = "Date Added"
        case .albumName:
            sortAlbumsLabel.text = "Album Name"
        case .artist:
            sortAlbumsLabel.text = "Artist"
        }
     
        if shouldReloadAlbums {
            menuDelegate?.refreshAlbumDisplay()
        }
    }
    
    //MARK: - User Actions
    
    @IBAction func reseedInfo() {
        alert(title: "Re-Seed", message: "Choose new seed artists. \n\nThe current data used for suggesting albums will be erased, and you can choose a new set of seed artists.\n\nYour liked albums will not be erased.", buttonTitle: "Done")
    }
    
    @IBAction func resetInfo() {
        alert(title: "Reset Data", message: "All data will be erased.\n\nThis includes your saved albums.", buttonTitle: "Done")
    }
    
    @IBAction func disconnectSpotifyInfo() {
        alert(title: "Disconnect Spotify", message: "Disconnect your Spotify account from LPSwipe", buttonTitle: "Done")
    }

    @IBAction func updateAutoplay(_ sender: UISwitch) {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.userSettings.autoplay = sender.isOn
        appDelegate.saveUserSettings()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            reseedDataAlert()
        } else if indexPath.section == 0 && indexPath.row == 1 {
            resetDataAlert()
        } else if indexPath.section == 0 && indexPath.row == 2 {
            disconnectSpotifyAlert()
        } else if indexPath.section == 1 && indexPath.row == 1 {
            shouldReloadAlbums = true
            let vc = storyboard!.instantiateViewController(withIdentifier: "SortOptionsTableViewController")
            navigationController?.pushViewController(vc, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row == 0 {
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
    
    func disconnectSpotifyAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you would like to disconnect Spotify? You will need to connect another account to use LPSwipe.", preferredStyle: .alert)
        
        let disconnectAction = UIAlertAction(title: "Disconnect", style: .default) { action in
            self.appDelegate.disconnectSpotify()
            self.delegate?.spotifyDisconnected()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(disconnectAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
}

extension MenuTableViewController: ConfirmResetViewControllerDelegate {
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}





