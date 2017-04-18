//
//  ConfirmArtistViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/30/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol ConfirmArtistViewControllerDelegate {
    func artistChosen(spotifyID: String)
    func artistCanceled()
}

class ConfirmArtistViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var delegate: ConfirmArtistViewControllerDelegate!
    var client = SpotifyClient.sharedInstance()
    
    var searchString: String!
    
    var spotifyID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getArtist()
        // Do any additional setup after loading the view.
    }

    func getArtist() {
        
        client.searchArtist(searchString: searchString) { result, error in
            
            if let error = error {
                print("error \(error)")
                return
            }
            
            guard let artistData = result as? [String : AnyObject],
                let name = artistData["name"] as? String,
                let id = artistData["id"] as? String,
                let images = artistData["images"] as? [[String : AnyObject]],
                images.count >= 3,
                let largeImage = images[0]["url"] as? String else {
                    
                    //could not get artist
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.artistNotFound()
                    }
                    
                    return
            }
            
            DispatchQueue.main.async {
                self.spotifyID = id
                self.artistLabel.text = name
                self.dislikeButton.isEnabled = true
                self.likeButton.isEnabled = true
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                guard let url = URL(string: largeImage) else {
                    return
                }
                
                if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.imageView.image = image
                        self.imageView.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func selectArtist() {
        delegate.artistChosen(spotifyID: spotifyID!)
    }
    
    @IBAction func rejectArtist() {
        delegate.artistCanceled()
    }
    
    func artistNotFound() {
        
        let alert = UIAlertController(title: "Could not find \(searchString!)!", message: "Note: some artists may be unavailable.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Done", style: .default) {
            action in
            self.delegate.artistCanceled()
        }
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
        
    }

}

