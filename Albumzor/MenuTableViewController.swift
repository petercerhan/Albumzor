//
//  MenuTableViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/24/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MenuTableViewControllerDelegate: NSObjectProtocol {
    func resetData(action: ResetDataAction)
    func spotifyDisconnected()
}

class MenuTableViewController: UITableViewController {
    
    //MARK: - Dependencies
    
    private var viewModel: MenuViewModel!
    
    //MARK: - Interface Components
    
    @IBOutlet var autoPlaySwitch: UISwitch!
    @IBOutlet var sortAlbumsLabel: UILabel!
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: MenuViewModel) -> MenuTableViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "MenuTableViewController") as! MenuTableViewController
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Options"
        bindUI()
    }
    
    private func bindUI() {
        
        //autoplay switch initial value
        viewModel.isAutoplayEnabled
            .observeOn(MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { [unowned self] enabled in
                self.autoPlaySwitch.isOn = enabled
            })
            .disposed(by: disposeBag)
        
        //sortAlbumsLabel
        viewModel.albumSortType
            .map { sortType -> String in
                switch sortType {
                case .dateAdded:
                    return "Date Added"
                case .albumName:
                    return "Album Name"
                case .artist:
                    return "Artist"
                }
            }
            .observeOn(MainScheduler.instance)
            .bind(to: sortAlbumsLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    //MARK: - User Actions
    
    @IBAction func resetInfo() {
        alert(title: "Reset Data", message: "All data will be erased.\n\nThis includes your saved albums.", buttonTitle: "Done")
    }
    
    @IBAction func disconnectSpotifyInfo() {
        alert(title: "Disconnect Spotify", message: "Disconnect your Spotify account from LPSwipe", buttonTitle: "Done")
    }

    @IBAction func updateAutoplay(_ sender: UISwitch) {
        viewModel.dispatch(action: .setAutoplayIsEnabled(sender.isOn))
    }
    
    //MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    //MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            resetDataAlert()
        } else if indexPath.section == 0 && indexPath.row == 1 {
            disconnectSpotifyAlert()
        } else if indexPath.section == 1 && indexPath.row == 1 {
            viewModel.dispatch(action: .requestSortOptionsScene)
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
    
    
    func resetDataAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you would like to reset LPSwipe?\n\nAll data will be erased.", preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            self?.viewModel.dispatch(action: .requestResetDataScene)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func disconnectSpotifyAlert() {
        let alert = UIAlertController(title: nil, message: "Are you sure you would like to disconnect Spotify? You will need to connect another account to use LPSwipe.", preferredStyle: .alert)
        
        let disconnectAction = UIAlertAction(title: "Disconnect", style: .default) { [weak self] _ in
            self?.viewModel.dispatch(action: .disconnectSpotify)
        }
         
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(disconnectAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}



