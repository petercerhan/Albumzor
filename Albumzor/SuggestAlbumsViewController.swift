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
    
    var currentIndex: Int = 0
    
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Albums count \(albums.count)")

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
        
    }

    @IBAction func quit() {
        delegate.quit()
    }

}

extension SuggestAlbumsViewController: CGDraggableViewDelegate {
    func swipeComplete(direction: SwipeDirection) {
        if direction == .right {
            print("liked")
        } else {
            print("not liked")
        }
        
        //if last album has been swiped, go to next steps view
        if currentIndex == albums.count - 1 {
            delegate.batteryComplete()
            return
        }
        
        currentIndex += 1
        print("Current Index \(currentIndex)")
        
        //add bottom album unless we are on the final album of the battery
        if currentIndex < albums.count - 1 {
            currentAlbumView = nextAlbumView
            nextAlbumView = CGDraggableView(frame: currentAlbumView.frame)
            nextAlbumView.imageView.image = albumArt[currentIndex + 1]
            nextAlbumView.delegate = self
            view.insertSubview(nextAlbumView, belowSubview: currentAlbumView)
        }
        
        //get tracks
        
        
        
        dataManager.seen(album: albums[currentIndex].objectID)
        usage[currentIndex].seen = true
    }
}


