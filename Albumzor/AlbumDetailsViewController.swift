//
//  AlbumDetailsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class AlbumDetailsViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    var album: Album!
    var tracks: [Track]?
    
    var albumImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")
        
        imageView.image = albumImage
        albumLabel.text = album.name!.cleanAlbumName()
        artistLabel.text = album.artist!.name!
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
            return tracks.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Default")!
        
        cell.textLabel!.text = tracks![indexPath.item].name!

        return cell
    }
    
}

