//
//  SortOptionsTableViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 5/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

enum AlbumSortType: Int {
    case dateAdded = 0
    case albumName = 1
    case artist = 2
}

class SortOptionsTableViewController: UITableViewController {

    @IBOutlet var check1: UILabel!
    @IBOutlet var check2: UILabel!
    @IBOutlet var check3: UILabel!
    
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sort Albums By"
        
        guard let sortType = AlbumSortType(rawValue: appDelegate.userSettings.albumSortType) else {
            return
        }
        
        switch sortType {
        case .dateAdded:
            setCheck(.dateAdded)
        case .albumName:
            setCheck(.albumName)
        case .artist:
            setCheck(.artist)
        }
        
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            setCheck(.dateAdded)
            appDelegate.userSettings.albumSortType = AlbumSortType.dateAdded.rawValue
        case 1:
            setCheck(.albumName)
            appDelegate.userSettings.albumSortType = AlbumSortType.albumName.rawValue
        case 2:
            setCheck(.artist)
            appDelegate.userSettings.albumSortType = AlbumSortType.artist.rawValue
        default:
            break
        }
        
        appDelegate.saveUserSettings()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setCheck(_ item: AlbumSortType) {
        
        switch item {
        case .dateAdded:
            check1.text = "✓"
            check2.text = ""
            check3.text = ""
        case .albumName:
            check1.text = ""
            check2.text = "✓"
            check3.text = ""
        case .artist:
            check1.text = ""
            check2.text = ""
            check3.text = "✓"
        }
        
    }

}
