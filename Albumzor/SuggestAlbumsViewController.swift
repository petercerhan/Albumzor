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
    
    @IBOutlet var initialAlbumView: CGDraggableView!

    var currentAlbumView: CGDraggableView!
    var nextAlbumView: CGDraggableView!
    
    var delegate: SuggestAlbumsViewControllerDelegate!
    
    var albumArt: [UIImage]!
    var albums: [Album]!
    var usage: [AlbumUsage]!
    
    var currentAlbumTracks: [Track]?
    var nextAlbumTracks: [Track]?
    
    var currentIndex: Int = 0
    
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ConfigureAlbumViews
        currentAlbumView = initialAlbumView
        currentAlbumView.imageView.image = albumArt[0]
        currentAlbumView.delegate = self
        
        dataManager.seen(album: albums[0].objectID)
        usage[0].seen = true
        
        nextAlbumView = CGDraggableView(frame: currentAlbumView.frame)
        nextAlbumView.imageView.image = albumArt[1]
        nextAlbumView.delegate = self
        view.insertSubview(nextAlbumView, belowSubview: currentAlbumView)

        currentAlbumTracks = dataManager.getTracks(forAlbum: albums[0].objectID)
        nextAlbumTracks = dataManager.getTracks(forAlbum: albums[1].objectID)
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
        
        //add bottom album unless we are on the final album of the battery
        if currentIndex < albums.count - 1 {
            currentAlbumView = nextAlbumView
            nextAlbumView = CGDraggableView(frame: currentAlbumView.frame)
            nextAlbumView.imageView.image = albumArt[currentIndex + 1]
            nextAlbumView.delegate = self
            view.insertSubview(nextAlbumView, belowSubview: currentAlbumView)
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
}


