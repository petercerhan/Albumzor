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
}

class AlbumDetailsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var album: Album!
    var tracks: [Track]?
    
    var albumImage: UIImage!
    
    //Index of currently playing track
    var trackPlaying: Int?
    
    var audioState: AudioState = .noTrack
    
    var delegate: AlbumDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        configureAudioButton()
    }
    
    func configureAudioButton() {
        audioButton.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        audioButton.contentMode = .center
        
        switch audioState {
        case .loading:
            activityIndicator.startAnimating()
            audioButton.isHidden = true
        case .playing:
            activityIndicator.stopAnimating()
            audioButton.isHidden = false
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Pause"), for: .normal)
        case .paused:
            activityIndicator.stopAnimating()
            audioButton.isHidden = false
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Play"), for: .normal)
        case .error:
            activityIndicator.stopAnimating()
            audioButton.isHidden = false
            audioButton.setTitle("!", for: .normal)
            audioButton.setImage(nil, for: .normal)
        case .noTrack:
            activityIndicator.stopAnimating()
            audioButton.isHidden = false
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Play"), for: .normal)
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
        switch audioState {
        case .playing:
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Play"), for: .normal)
            audioButton.isUserInteractionEnabled = false
            audioState = .paused
            delegate?.pauseAudio()
        case .paused:
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Pause"), for: .normal)
            audioButton.isUserInteractionEnabled = false
            audioState = .playing
            delegate?.resumeAudio()
        default:
            break
        }
    }
    
}

//MARK:- Audio messages forwarded from parent

extension AlbumDetailsViewController {
    
    func audioBeganLoading() {
        // do nothing
    }
    
    func audioBeganPlaying() {
        activityIndicator.stopAnimating()
        audioButton.setTitle("", for: .normal)
        audioButton.setImage(UIImage(named: "Pause"), for: .normal)
        audioButton.isUserInteractionEnabled = true
        audioButton.isHidden = false
        audioState = .playing
    }
    
    func audioPaused() {
        audioButton.setTitle("", for: .normal)
        audioButton.setImage(UIImage(named: "Play"), for: .normal)
        audioButton.isUserInteractionEnabled = true
        audioState = .paused
    }
    
    func audioStopped() {
        // do nothing
    }
    
    func audioCouldNotPlay() {
        activityIndicator.stopAnimating()
        audioButton.setTitle("!", for: .normal)
        audioButton.setImage(nil, for: .normal)
        audioButton.isUserInteractionEnabled = false
        audioState = .error
    }
    
    
}

//MARK:- TableViewDelegate

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
            
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Pause"), for: .normal)
            audioButton.isUserInteractionEnabled = false
            audioButton.isHidden = true
            audioState = .playing
            activityIndicator.startAnimating()
            
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

//MARK:- TableViewDataSource

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

