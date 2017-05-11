//
//  ConfirmArtistViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/30/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol ConfirmArtistViewControllerDelegate: NSObjectProtocol {
    func artistChosen(spotifyID: String, searchOrigin: ArtistSearchOrigin)
    func artistCanceled()
}

class ConfirmArtistViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var quitButton: UIButton!
    
    weak var delegate: ConfirmArtistViewControllerDelegate!
    var client = SpotifyClient.sharedInstance()
    
    var confirmSessionComplete = false
    
    var searchString: String!
    var searchOrigin: ArtistSearchOrigin!
    
    var spotifyID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !confirmSessionComplete {
            confirmSessionComplete = true
            confirmSession()
        }
    }
    
    func confirmSession() {
        if SpotifyAuthManager().sessionIsValid() {
            getArtist()
        } else {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            let appStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let vc = appStoryboard.instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController
            vc.spotifyConnected = appDelegate.userProfile.spotifyConnected
            self.present(vc, animated: false, completion: nil)
            vc.controllerDelegate = self
        }
    }
    
    func getArtist() {
        
        client.searchArtist(searchString: searchString) { result, error in
            if let error = error {
                
                self.activityIndicator.stopAnimating()
                
                if error.code == -1009 {
                    DispatchQueue.main.async {
                        self.artistNotFound(networkError: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.artistNotFound(networkError: false)
                    }
                }
                
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
                        self.artistNotFound(networkError: false)
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
                        self.quitButton.isHidden = true
                        self.imageView.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
                    }
                }
            }
        }
    }
    
    @IBAction func quit() {
        delegate.artistCanceled()
    }
    
    @IBAction func selectArtist() {
        delegate.artistChosen(spotifyID: spotifyID!, searchOrigin: searchOrigin)
    }
    
    @IBAction func rejectArtist() {
        delegate.artistCanceled()
    }
    
    func artistNotFound(networkError: Bool) {
        var title = ""
        var message = ""
        
        if networkError {
            title = "Network Error"
            message = "Please check you internet connection"
        } else {
            title = "Could not find \(searchString!)!"
            message = "Note: some artists may be unavailable."
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default) {
            action in
            self.delegate.artistCanceled()
        }
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
        
    }

}

//MARK: - SpotifyLoginViewControllerDelegate

extension ConfirmArtistViewController: SpotifyLoginViewControllerDelegate {
    
    func loginSucceeded() {
        getArtist()
        dismiss(animated: false, completion: nil)
    }
    
    func cancelLogin() {
        dismiss(animated: false, completion: nil)
        delegate.artistCanceled()
    }
    
}





