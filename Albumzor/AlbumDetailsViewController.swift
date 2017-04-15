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
    func pauseAudio()
    func resumeAudio()
    //func audioPaused() -> Bool
}

class AlbumDetailsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var audioButton: UIButton!
    
    var album: Album!
    var tracks: [Track]?
    
    var albumImage: UIImage!
    
    //Index of currently playing track
    var trackPlaying: Int?
    
    //loading - trackPlaying is currently loading; play - trackPlaying is paused; pause - trackPlaying is playing; error - trackPlaying failed to load; noTrack - autoPlay is presumably disabled, no track has been loaded
    enum InitialAudioButtonState {
        case loading, play, pause, error, noTrack
    }
    var initialButtonAppearance: InitialAudioButtonState = .noTrack
    
    var delegate: AlbumDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        configureAudioButton()
    }
    
    func configureAudioButton() {
        switch initialButtonAppearance {
        case .loading:
            audioButton.setTitle("L", for: .normal)
        case .play:
            audioButton.setTitle("G", for: .normal)
        case .pause:
            audioButton.setTitle("P", for: .normal)
        case .error:
            audioButton.setTitle("!", for: .normal)
        case .noTrack:
            audioButton.setTitle("G", for: .normal)
            audioButton.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func togglePause() {
//        if delegate!.audioPaused() {
//            
//        }
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
        print("did select")
        if indexPath.item == 0 {
            dismiss(animated: true, completion: nil)
        } else {
            if let trackPlaying = trackPlaying, let priorCell = tableView.cellForRow(at: IndexPath(item: trackPlaying + 1, section: 0)) as? TrackTableViewCell {
                priorCell.titleLabel.font = UIFont.systemFont(ofSize: priorCell.titleLabel.font.pointSize)
            }
            
            trackPlaying = indexPath.item - 1
            
            let cell = tableView.cellForRow(at: indexPath) as! TrackTableViewCell
            cell.titleLabel.font = UIFont.boldSystemFont(ofSize: cell.titleLabel.font.pointSize)
            delegate?.playTrack(atIndex: indexPath.item - 1)
        }
        
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
            cell.albumImageView.addShadow()
            cell.titleLabel.text = album.name!.cleanAlbumName()
            cell.artistLabel.text = album.artist!.name!
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackTableViewCell
            
            cell.titleLabel.font = UIFont.systemFont(ofSize: cell.titleLabel.font.pointSize)
            cell.titleLabel.text = tracks?[indexPath.row - 1].name
            cell.numberLabel.text = "\(tracks![indexPath.row - 1].track)"
            
            cell.selectionStyle = .none
            
            if let trackPlaying = trackPlaying, trackPlaying == indexPath.row - 1 {
                cell.titleLabel.font = UIFont.boldSystemFont(ofSize: cell.titleLabel.font.pointSize)
            }
            
            return cell
        }
    }
    
}

