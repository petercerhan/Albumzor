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
    
    let dataManager = DataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //album 1 seen
        usage[0].seen = true
    }
    
    
    
    @IBAction func quit() {
        delegate.quit()
    }
    
    //Album liked
    @IBAction func likeAlbum() {
        if usage[currentIndex].liked {
            likeButton.setTitleColor(UIColor.blue, for: .normal)
            usage[currentIndex].liked = false
        } else {
            likeButton.setTitleColor(UIColor.green, for: .normal)
            usage[currentIndex].liked = true
        }
        
        dataManager.like(album: albums[currentIndex].objectID, addRelatedArtists: !usage[currentIndex].relatedAdded)
        usage[currentIndex].relatedAdded = true
    }
    
    //Album starred
    @IBAction func starAlbum() {
        if usage[currentIndex].starred {
            starButton.setTitleColor(UIColor.blue, for: .normal)
            usage[currentIndex].starred = false
        } else {
            starButton.setTitleColor(UIColor.green, for: .normal)
            usage[currentIndex].starred = true
        }
    }
    
    
    
    
    
    
}

extension AlbumsViewController: UICollectionViewDelegate {
    
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
            cell.titleLabel.text = album.name!
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
        
        likeButton.isUserInteractionEnabled = true
        starButton.isUserInteractionEnabled = true
        collectionView.isUserInteractionEnabled = true
        
        updateButtons()
        
        usage[index].seen = true
        //print("index: \(index) seen: \(usage[index].seen) liked: \(usage[index].liked) starred: \(usage[index].starred)")
        
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
