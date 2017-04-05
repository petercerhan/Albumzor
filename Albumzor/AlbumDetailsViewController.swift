//
//  AlbumDetailsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import AVFoundation

protocol AlbumDetailsViewControllerDelegate {
    func playTrack(atIndex index: Int)
}

class AlbumDetailsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var album: Album!
    var tracks: [Track]?
    
    var albumImage: UIImage!
    
    var delegate: AlbumDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func setTrackPlaying(track: Int) {
        print("setTrackPlaying \(track)")
        //highlight table view row that is playing, indicate that track is playing
    }
    
    func couldNotGetTrack(track: Int) {
        print("couldNotGetTrack \(track)")
        //Indicate track could not be played
    }
    
}

extension AlbumDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            return
        }
        
        delegate?.playTrack(atIndex: indexPath.item - 1)
        
        //let audioURL = self.tracks![indexPath.item - 1].previewURL
        //self.playAudio(url: audioURL!)
        
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.item == 0 {
            dismiss(animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
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

