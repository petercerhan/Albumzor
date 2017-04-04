//
//  AlbumDetailsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class AlbumDetailsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var album: Album!
    var tracks: [Track]?
    
    var albumImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")
        
//        let albumLabel = album.name!.cleanAlbumName()
//        let artistLabel = album.artist!.name!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }

}

extension AlbumDetailsViewController: UITableViewDelegate {
    
    
    
}

extension AlbumDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tracks = tracks {
            return tracks.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumDetailsCell") as! AlbumDetailsTableViewCell
            
            cell.albumImageView.image = albumImage
            cell.titleLabel.text = album.name!.cleanAlbumName()
            cell.artistLabel.text = album.artist!.name!
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackTableViewCell
            
            cell.titleLabel.text = tracks?[indexPath.row - 1].name
            cell.numberLabel.text = "\(tracks![indexPath.row - 1].track)"
            
            return cell
        }
    }
    
}

