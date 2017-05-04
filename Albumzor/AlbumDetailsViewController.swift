//
//  AlbumDetailsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol AlbumDetailsViewControllerDelegate: NSObjectProtocol {
    func playTrack(atIndex index: Int)
    func pauseAudio()
    func resumeAudio()
    func stopAudio()
    func dismiss()
}

class AlbumDetailsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    weak var album: Album!
    var tracks: [Track]?
    
    var albumImage: UIImage!
    
    //Index of currently playing track
    var trackPlaying: Int?
    
    var audioState: AudioState = .noTrack
    
    var delegate: AlbumDetailsViewControllerDelegate?

    //MARK: - Life Cycle
    
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
            set(audioState: .loading, controlEnabled: false)
        case .playing:
            set(audioState: .playing, controlEnabled: true)
        case .paused:
            set(audioState: .paused, controlEnabled: true)
        case .error:
            set(audioState: .error, controlEnabled: false)
        case .noTrack:
            set(audioState: .noTrack, controlEnabled: false)
        }
    }
    
    func set(audioState: AudioState, controlEnabled: Bool) {
        self.audioState = audioState
        audioButton.isUserInteractionEnabled = controlEnabled
        
        activityIndicator.stopAnimating()
        
        switch audioState {
        case .noTrack:
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Play"), for: .normal)
            audioButton.isHidden = false
        case .loading:
            activityIndicator.startAnimating()
            audioButton.isHidden = true
        case .playing:
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Pause"), for: .normal)
            audioButton.isHidden = false
        case .paused:
            audioButton.setTitle("", for: .normal)
            audioButton.setImage(UIImage(named: "Play"), for: .normal)
            audioButton.isHidden = false
        case .error:
            audioButton.isHidden = false
            audioButton.setTitle("!", for: .normal)
            audioButton.setImage(nil, for: .normal)
        }
    }
    
    //MARK: - User Actions
    
    @IBAction func back() {
        delegate?.dismiss()
    }
    
    @IBAction func audioControl() {
        switch audioState {
        case .playing:
            set(audioState: .paused, controlEnabled: false)
            delegate?.pauseAudio()
        case .paused:
            set(audioState: .playing, controlEnabled: false)
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
        set(audioState: .playing, controlEnabled: true)
    }
    
    func audioPaused() {
        set(audioState: .paused, controlEnabled: true)
    }
    
    func audioStopped() {
        // do nothing
    }
    
    func audioCouldNotPlay() {
        set(audioState: .error, controlEnabled: false)
    }
    
    
}

//MARK:- TableViewDelegate

extension AlbumDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            delegate?.dismiss()
        } else {
            if let trackPlaying = trackPlaying, let priorCell = tableView.cellForRow(at: IndexPath(item: trackPlaying + 1, section: 0)) as? TrackTableViewCell {
                priorCell.titleLabel.font = UIFont.systemFont(ofSize: priorCell.titleLabel.font.pointSize)
            }
            
            trackPlaying = indexPath.item - 1
            
            let cell = tableView.cellForRow(at: indexPath) as! TrackTableViewCell
            cell.titleLabel.font = UIFont.boldSystemFont(ofSize: cell.titleLabel.font.pointSize)
            
            set(audioState: .playing, controlEnabled: false)
            
            delegate?.stopAudio()
            delegate?.playTrack(atIndex: indexPath.item - 1)
        }
        
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.item == 0 {
            delegate?.dismiss()
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

