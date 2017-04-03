//
//  SuggestAlbumsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/1/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

typealias AlbumUsage = (seen: Bool, liked: Bool, relatedAdded: Bool)

protocol SuggestAlbumsViewControllerDelegate {
    func quit()
    func batteryComplete()
}

class SuggestAlbumsViewController: UIViewController {
    
    @IBOutlet var defaultView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!

    var currentAlbumView: CGDraggableView!
    var nextAlbumView: CGDraggableView!
    
    var delegate: SuggestAlbumsViewControllerDelegate!
    
    var albumArt: [UIImage]!
    var albums: [Album]!
    var usage: [AlbumUsage]!
    
    var currentAlbumTracks: [Track]?
    var nextAlbumTracks: [Track]?
    
    var currentIndex: Int = 0
    
    var initialLayoutCongifured = false
    
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        if !initialLayoutCongifured {
            //ConfigureAlbumViews
            currentAlbumView = CGDraggableView(frame: defaultView.frame)
            currentAlbumView.imageView.image = albumArt[0]
            currentAlbumView.delegate = self
            currentAlbumView.addShadow()
            view.addSubview(currentAlbumView)
            
            print("frame \(defaultView.frame)")
            
            dataManager.seen(album: albums[0].objectID)
            usage[0].seen = true
            
            nextAlbumView = CGDraggableView(frame: defaultView.frame)
            nextAlbumView.imageView.image = albumArt[1]
            nextAlbumView.delegate = self
            nextAlbumView.addShadow()
            view.insertSubview(nextAlbumView, belowSubview: currentAlbumView)
            
            currentAlbumTracks = dataManager.getTracks(forAlbum: albums[0].objectID)
            nextAlbumTracks = dataManager.getTracks(forAlbum: albums[1].objectID)
            
            titleLabel.text = albums[0].name!.cleanAlbumName()
            artistLabel.text = albums[0].artist!.name!
            
            initialLayoutCongifured = true
        }
    }

    @IBAction func quit() {
        delegate.quit()
    }

}

extension SuggestAlbumsViewController: CGDraggableViewDelegate {
    func swipeComplete(direction: SwipeDirection) {

        //potentially move "seen" code to here
        
        if direction == .right {
            dataManager.like(album: albums[currentIndex].objectID, addRelatedArtists: !usage[currentIndex].relatedAdded)
            usage[currentIndex].relatedAdded = true
        } else {
        }
        
        //if last album has been swiped, go to next steps view
        if currentIndex == albums.count - 1 {
            delegate.batteryComplete()
            return
        }
        
        currentIndex += 1
        
        //update title
        if currentIndex < albums.count {
            titleLabel.text = albums[currentIndex].name!.cleanAlbumName()
            artistLabel.text = albums[currentIndex].artist!.name!
            titleLabel.alpha = 1.0
            artistLabel.alpha = 1.0
        } else {
            titleLabel.removeFromSuperview()
            artistLabel.removeFromSuperview()
            
        }
        
        //add bottom album unless we are on the final album of the battery
        if currentIndex < albums.count - 1 {
            currentAlbumView = nextAlbumView
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
        
        if currentIndex == albums.count - 1 {
            nextAlbumTracks = nil
        } else {
            nextAlbumTracks = dataManager.getTracks(forAlbum: albums[currentIndex + 1].objectID)
        }
        
        dataManager.seen(album: albums[currentIndex].objectID)
        usage[currentIndex].seen = true
    }

    func tapped() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "AlbumDetailsViewController") as! AlbumDetailsViewController
        vc.albumImage = albumArt[currentIndex]
        vc.tracks = currentAlbumTracks
        vc.album = albums[currentIndex]
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


