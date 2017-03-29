//
//  AlbumsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/15/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol AlbumsViewControllerDelegate {
    func quit()
    func batteryComplete()
}

typealias AlbumUsage = (seen: Bool, liked: Bool, starred: Bool, relatedAdded: Bool)

class AlbumsViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var starButton: UIButton!
    
    var delegate: AlbumsViewControllerDelegate!
    
    var albumArt: [UIImage]!
    var albums: [Album]!
    var usage: [AlbumUsage]!
    
    var currentIndex: Int = 0
    
    var currentAlbumTracks: [Track]?
    var nextAlbumTracks: [Track]?
    
    let dataManager = (UIApplication.shared.delegate as! AppDelegate).dataManager!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //album 1 seen
        dataManager.seen(album: albums[0].objectID)
        usage[0].seen = true
        //get tracks
        currentAlbumTracks = dataManager.getTracks(forAlbum: albums[0].objectID)
        nextAlbumTracks = dataManager.getTracks(forAlbum: albums[1].objectID)
    }
    
    
    @IBAction func quit() {
        delegate.quit()
    }
    
    //Album liked
    @IBAction func likeAlbum() {
        if usage[currentIndex].liked {
            likeButton.setTitleColor(UIColor.blue, for: .normal)
            usage[currentIndex].liked = false
            dataManager.unlike(album: albums[currentIndex].objectID)
        } else {
            likeButton.setTitleColor(UIColor.green, for: .normal)
            usage[currentIndex].liked = true
            dataManager.like(album: albums[currentIndex].objectID, addRelatedArtists: !usage[currentIndex].relatedAdded)
            usage[currentIndex].relatedAdded = true
        }
    }
    
    //Album starred
    @IBAction func starAlbum() {
        if usage[currentIndex].starred {
            starButton.setTitleColor(UIColor.blue, for: .normal)
            usage[currentIndex].starred = false
            dataManager.unstar(album: albums[currentIndex].objectID)
        } else {
            starButton.setTitleColor(UIColor.green, for: .normal)
            usage[currentIndex].starred = true
            dataManager.star(album: albums[currentIndex].objectID, addRelatedArtists: !usage[currentIndex].relatedAdded)
            usage[currentIndex].relatedAdded = true
        }
    }
    
    
    
    
}

extension AlbumsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "AlbumDetailsViewController") as! AlbumDetailsViewController
        vc.albumImage = albumArt[currentIndex]
        vc.tracks = currentAlbumTracks
        vc.album = albums[currentIndex]
        present(vc, animated: true, completion: nil)
        
        return false
    }
    
}

extension AlbumsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        if(indexPath.item < albums.count) {
            let album = albums[indexPath.item]
            cell.imageView.image = albumArt[indexPath.item]
            cell.titleLabel.text = album.name!.cleanAlbumName()
            cell.artistLabel.text = album.artist!.name!
        } else {
            cell.imageView.image = nil
            cell.titleLabel.text = ""
            cell.artistLabel.text = ""
        }
        
        return cell
    }
    
    func updateButtons() {
        if usage[currentIndex].liked {
            likeButton.setTitleColor(UIColor.green, for: .normal)
        } else {
            likeButton.setTitleColor(UIColor.blue, for: .normal)
        }
        
        if usage[currentIndex].starred {
            starButton.setTitleColor(UIColor.green, for: .normal)
        } else {
            starButton.setTitleColor(UIColor.blue, for: .normal)
        }
    }
    
}

extension AlbumsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scroll detected")
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //print("will begin dragging; index \(currentIndex)")
        likeButton.isUserInteractionEnabled = false
        starButton.isUserInteractionEnabled = false
        collectionView.isUserInteractionEnabled = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.x == 0.0 {
            likeButton.isUserInteractionEnabled = true
            starButton.isUserInteractionEnabled = true
            collectionView.isUserInteractionEnabled = true
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //print("will begin decelerating; index \(currentIndex)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let indexDouble = scrollView.contentOffset.x / scrollView.frame.size.width
        let index = Int(indexDouble)
        
        currentIndex = index
        if index == albums.count {
            delegate.batteryComplete()
            return
        }
        
        if !usage[index].seen {
            dataManager.seen(album: albums[index].objectID)
            usage[index].seen = true
        }
        
        likeButton.isUserInteractionEnabled = true
        starButton.isUserInteractionEnabled = true
        collectionView.isUserInteractionEnabled = true
        
        updateButtons()
        
        usage[index].seen = true
        
        if currentIndex > 10 {
            currentAlbumTracks = nil
        } else {
            currentAlbumTracks = dataManager.getTracks(forAlbum: albums[currentIndex].objectID)
        }
        if currentIndex > 9 {
            nextAlbumTracks = nil
        } else {
            nextAlbumTracks = dataManager.getTracks(forAlbum: albums[currentIndex + 1].objectID)
        }
        
    }
    
}

extension AlbumsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthPerItem = collectionView.frame.width - 40.0
        let cellHeight = collectionView.frame.height - 40.0
        
        return CGSize(width: widthPerItem, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40.0
    }
}
