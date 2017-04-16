//
//  SuggestAlbumsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/1/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import AVFoundation

typealias AlbumUsage = (seen: Bool, liked: Bool, relatedAdded: Bool)

//error - tried and failed to retrieve sample audio; noTrack - autoplay presumably disabled, no track has been retrieved
enum AudioState {
    case loading, playing, paused, error, noTrack
}

protocol SuggestAlbumsViewControllerDelegate {
    func quit()
    func batteryComplete(liked: Int)
}

class SuggestAlbumsViewController: UIViewController {
    
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var defaultView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    
    @IBOutlet var quitButton: UIButton!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var audioButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var currentAlbumView: CGDraggableView!
    var nextAlbumView: CGDraggableView!
    
    var delegate: SuggestAlbumsViewControllerDelegate!
    
    var albumArt: [UIImage]!
    var albums: [Album]!
    var usage: [AlbumUsage]!
    var likedAlbums = 0
    
    var currentAlbumTracks: [Track]?
    var nextAlbumTracks: [Track]?
    
    var currentIndex: Int = 0
    
    var trackPlaying: Int?
    
    var audioState: AudioState = .noTrack
    
    var initialLayoutCongifured = false
    
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    
    var audioPlayer = AudioPlayer()
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if !initialLayoutCongifured {
            //ConfigureAlbumViews
            currentAlbumView = CGDraggableView(frame: defaultView.frame)
            currentAlbumView.imageView.image = albumArt[0]
            currentAlbumView.delegate = self
            currentAlbumView.addShadow()
            view.addSubview(currentAlbumView)
            
            dataManager.seen(album: albums[0].objectID)
            usage[0].seen = true
            
            nextAlbumView = CGDraggableView(frame: defaultView.frame)
            nextAlbumView.imageView.image = albumArt[1]
            nextAlbumView.delegate = self
            nextAlbumView.addShadow()
            view.insertSubview(nextAlbumView, belowSubview: currentAlbumView)
            
            currentAlbumTracks = dataManager.getTracks(forAlbum: albums[0].objectID)
            nextAlbumTracks = dataManager.getTracks(forAlbum: albums[1].objectID)
            autoPlay()
            
            titleLabel.text = albums[0].name!.cleanAlbumName()
            artistLabel.text = albums[0].artist!.name!
            
            audioButton.imageEdgeInsets = UIEdgeInsetsMake(11.0, 11.0, 11.0, 11.0)
            audioButton.contentMode = .center
            
            initialLayoutCongifured = true
        }
    }
    
    func animateOut() {
        
        titleLabel.alpha = 0.0
        artistLabel.alpha = 0.0
        activityIndicator.stopAnimating()
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.quitButton.alpha = 0.0
                        self.dislikeButton.alpha = 0.0
                        self.likeButton.alpha = 0.0
                        self.audioButton.alpha = 0.0
                    },
                       completion: {
                        _ in
                        self.delegate.batteryComplete(liked: self.likedAlbums)
                    })
        
    }
    
    //MARK:- User Actions
    
    @IBAction func like() {
        currentAlbumView.overlayView.imageView.image = UIImage(named: "Check_white")
        currentAlbumView.overlayView.backgroundColor = Styles.likeGreen
        currentAlbumView.overlayView.alpha = 0.4
        
        let rotationAngle = 2 * CGFloat(M_PI) / 16.0
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
        let finalTransform = transform.scaledBy(x: 0.93, y: 0.93)
        
        let exitDistance = view.frame.size.width
        
        UIView.animate(withDuration: 0.25,
                       animations: {
                        self.currentAlbumView.center.x += exitDistance
                        self.currentAlbumView.center.y -= 20
                        self.currentAlbumView.transform = finalTransform
                        
                    },
                       completion: {
                        _ in
                        self.currentAlbumView.removeFromSuperview()
                        self.album(liked: true)
                    })
        
    }
    
    @IBAction func dislike() {
        currentAlbumView.overlayView.imageView.image = UIImage(named: "X_white")
        currentAlbumView.overlayView.backgroundColor = Styles.xRed
        currentAlbumView.overlayView.alpha = 0.4
        
        let rotationAngle = -2 * CGFloat(M_PI) / 16.0
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
        let finalTransform = transform.scaledBy(x: 0.93, y: 0.93)
        
        let exitDistance = view.frame.size.width
        
        UIView.animate(withDuration: 0.25,
                       animations: {
                        self.currentAlbumView.center.x -= exitDistance
                        self.currentAlbumView.center.y -= 20
                        self.currentAlbumView.transform = finalTransform
                        
        },
                       completion: { _ in
                        self.currentAlbumView.removeFromSuperview()
                        self.album(liked: false)
        })
    }

    @IBAction func quit() {
        audioPlayer.stop()
        delegate.quit()
    }
    
    @IBAction func togglePause() {
        
        switch audioState {
        case .playing:
            pauseAudio()
        case .paused:
            resumeAudio()
        case .noTrack:
            autoPlay()
        default:
            break
        }
        
    }

    //MARK:- Manage likes
    
    func album(liked: Bool) {
        audioPlayer.stop()
        
        //potentially move "seen" code to here
        dataManager.seen(album: albums[currentIndex].objectID)
        usage[currentIndex].seen = true
        
        if liked {
            likedAlbums += 1
            dataManager.like(album: albums[currentIndex].objectID, addRelatedArtists: !usage[currentIndex].relatedAdded)
            usage[currentIndex].relatedAdded = true
        } else {
        }
        
        //if last album has been reviewed, go to next steps view
        if currentIndex == albums.count - 1 {
            audioPlayer.currentAlbum = -1
            audioPlayer.currentTrack = -1
            animateOut()
            return
        }
        
        currentIndex += 1
        
        //update title
        if currentIndex < albums.count {
            titleLabel.text = albums[currentIndex].name!.cleanAlbumName()
            artistLabel.text = albums[currentIndex].artist!.name!
            titleLabel.alpha = 1.0
            artistLabel.alpha = 1.0
        }
        
        currentAlbumView = nextAlbumView
        
        //add bottom album unless we are on the final album of the battery
        if currentIndex < albums.count - 1 {
            nextAlbumView = CGDraggableView(frame: defaultView.frame)
            nextAlbumView.imageView.image = albumArt[currentIndex + 1]
            nextAlbumView.addShadow()
            nextAlbumView.delegate = self
            view.insertSubview(nextAlbumView, belowSubview: currentAlbumView)
            
            titleLabel.text = albums[currentIndex].name!.cleanAlbumName()
            artistLabel.text = albums[currentIndex].artist!.name!
            titleLabel.alpha = 1.0
            artistLabel.alpha = 1.0
        }
        
        //get tracks
        currentAlbumTracks = nextAlbumTracks
        autoPlay()
        
        if currentIndex == albums.count - 1 {
            nextAlbumTracks = nil
        } else {
            nextAlbumTracks = dataManager.getTracks(forAlbum: albums[currentIndex + 1].objectID)
        }
        
        
    }
    
    
}

//MARK:- CGDraggableViewDelegate

extension SuggestAlbumsViewController: CGDraggableViewDelegate {
    func swipeComplete(direction: SwipeDirection) {

        if direction == .right {
            album(liked: true)
        } else {
            album(liked: false)
        }
        
    }

    func tapped() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "AlbumDetailsViewController") as! AlbumDetailsViewController
        vc.albumImage = albumArt[currentIndex]
        vc.tracks = currentAlbumTracks
        vc.album = albums[currentIndex]
        
        vc.trackPlaying = trackPlaying
        vc.audioState = audioState
        
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func swipeBegan() {
        titleLabel.alpha = 0.4
        artistLabel.alpha = 0.4
    }
    
    func swipeCanceled() {
        titleLabel.alpha = 1.0
        artistLabel.alpha = 1.0
    }
}

//MARK:- Handle Audio / AlbumDetailsViewControllerDelegate
//playTrack(atIndex:), pauseAudio(), stopAudio(), and resumeAudio() called internally by SuggestAlbumsViewController, and are also AlbumDetailsViewController Delegate functions

extension SuggestAlbumsViewController: AlbumDetailsViewControllerDelegate {
    
    func playTrack(atIndex index: Int) {
        //update button
        trackPlaying = index
        audioState = .loading
        audioButton.isHidden = true
        activityIndicator.startAnimating()
        
        guard let urlString = currentAlbumTracks?[index].previewURL else {
            //could not play track
            activityIndicator.stopAnimating()
            audioButton.isHidden = false
            audioButton.setTitle("!", for: .normal)
            audioButton.setImage(nil, for: .normal)
            audioState = .error
            return
        }
        
        guard let url = URL(string: urlString) else {
            activityIndicator.stopAnimating()
            audioButton.isHidden = false
            audioButton.setTitle("!", for: .normal)
            audioButton.setImage(nil, for: .normal)
            audioState = .error
            return
        }

        self.audioPlayer.playTrack(url: url, albumIndex: currentIndex, trackIndex: index)
    }
    
    //Automatically play the sample of the most popular track on the album
    func autoPlay() {
        //get most popular track ..
        var mostPopularTrackIndex = 0
        var maxPopularity = 0
        
        guard let currentAlbumTracks = currentAlbumTracks, currentAlbumTracks.count > 0 else {
            couldNotPlay()
            return
        }
        
        for (index, track) in currentAlbumTracks.enumerated() {
            if Int(track.popularity) > maxPopularity {
                maxPopularity = Int(track.popularity)
                mostPopularTrackIndex = index
            }
        }
        
        //play track
        playTrack(atIndex: mostPopularTrackIndex)
    }
    
    func pauseAudio() {
        audioButton.setTitle("", for: .normal)
        audioButton.setImage(UIImage(named: "Play"), for: .normal)
        audioButton.isHidden = false
        audioButton.isUserInteractionEnabled = false
        audioState = .paused
        audioPlayer.pause()
    }
    
    func resumeAudio() {
        audioButton.setTitle("", for: .normal)
        audioButton.setImage(UIImage(named: "Pause"), for: .normal)
        audioButton.isHidden = false
        audioButton.isUserInteractionEnabled = false
        audioState = .playing
        audioPlayer.play()
    }
    
    func stopAudio() {
        audioPlayer.stop()
    }
    
}

//MARK:- AudioPlayerDelegate

extension SuggestAlbumsViewController: AudioPlayerDelegate {
    
    func beganLoading() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioBeganLoading()
        }
        //no action needed
    }
    
    func beganPlaying() {
        activityIndicator.stopAnimating()
        audioButton.setTitle("", for: .normal)
        audioButton.setImage(UIImage(named: "Pause"), for: .normal)
        audioState = .playing
        audioButton.isHidden = false
        audioButton.isUserInteractionEnabled = true
        
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioBeganPlaying()
        }
    }
    
    func paused() {
        audioButton.isHidden = false
        audioButton.isUserInteractionEnabled = true
        audioButton.setTitle("", for: .normal)
        audioButton.setImage(UIImage(named: "Play"), for: .normal)
        audioState = .paused
        
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioPaused()
        }
    }
    
    func stopped() {
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioStopped()
        }
        //no action needed
    }
    
    func couldNotPlay() {
        activityIndicator.stopAnimating()
        audioButton.isHidden = false
        audioButton.setTitle("!", for: .normal)
        audioButton.setImage(nil, for: .normal)
        audioState = .error
        
        if let vc = presentedViewController as? AlbumDetailsViewController {
            vc.audioCouldNotPlay()
        }
    }

}








