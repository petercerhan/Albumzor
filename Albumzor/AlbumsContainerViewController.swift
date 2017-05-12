//
//  AlbumsContainerViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol AlbumsContainerViewControllerDelegate: NSObjectProtocol {
    func findAlbumsHome()
}

class AlbumsContainerViewController: UIViewController {

    weak var delegate: AlbumsContainerViewControllerDelegate?
    
    var shouldLaunchAlbumView = true
    
    var contentViewController: UIViewController
    var appStoryboard: UIStoryboard! = UIStoryboard(name: "Main", bundle: nil)
    
    init() {
        
        //check whether we need to refresh session
        if SpotifyAuthManager().sessionIsValid() {
            let vc = appStoryboard.instantiateViewController(withIdentifier: "PrepareAlbumsViewController") as! PrepareAlbumsViewController
            contentViewController = vc
            super.init(nibName: nil, bundle: nil)
            vc.delegate = self
        } else {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            
            let vc = appStoryboard.instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController
            vc.spotifyConnected = appDelegate.userProfile.spotifyConnected
            contentViewController = vc
            super.init(nibName: nil, bundle: nil)
            vc.controllerDelegate = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        contentViewController = UIViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentViewController.view)
    }
    
    func update(contentViewController newViewController: UIViewController) {
        
        let priorViewController = contentViewController
        
        contentViewController = newViewController
        
        addChildViewController(newViewController)
        
        newViewController.view.frame = view.bounds
        view.addSubview(newViewController.view)
        
        priorViewController.willMove(toParentViewController: nil)
        newViewController.didMove(toParentViewController: self)
        
        priorViewController.view.removeFromSuperview()
        priorViewController.removeFromParentViewController()
    }
    
}

//MARK:- PrepareAlbumsViewControllerDelegate

extension AlbumsContainerViewController: PrepareAlbumsViewControllerDelegate {
    func launchAlbumView(albums: [Album], albumArt: [UIImage]) {
        if shouldLaunchAlbumView {
            let vc = appStoryboard.instantiateViewController(withIdentifier: "SuggestAlbumsViewController") as! SuggestAlbumsViewController
            vc.albums = albums
            vc.albumArt = albumArt
            vc.delegate = self
            update(contentViewController: vc)
        }
    }
    
    func cancelPrepareAlbums() {
        shouldLaunchAlbumView = false
        delegate?.findAlbumsHome()
    }
}

//MARK:- AlbumsViewControllerDelegate

extension AlbumsContainerViewController: SuggestAlbumsViewControllerDelegate {
    func quit() {
        delegate?.findAlbumsHome()
    }
    
    func batteryComplete(liked: Int) {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "NextStepViewController") as! NextStepViewController
        vc.likedAlbums = liked
        vc.delegate = self
        update(contentViewController: vc)
    }
}

//MARK:- NextStepViewControllerDelegate

extension AlbumsContainerViewController: NextStepViewControllerDelegate {
    func nextBattery() {
        //check if need new session
        
        if SpotifyAuthManager().sessionIsValid() {
            let vc = appStoryboard.instantiateViewController(withIdentifier: "PrepareAlbumsViewController") as! PrepareAlbumsViewController
            vc.delegate = self
            update(contentViewController: vc)
        } else {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            
            let vc = appStoryboard.instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController
            vc.spotifyConnected = appDelegate.userProfile.spotifyConnected
            update(contentViewController: vc)
            vc.controllerDelegate = self
        }

    }
    
    func launchNextBattery() {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "PrepareAlbumsViewController") as! PrepareAlbumsViewController
        vc.delegate = self
        update(contentViewController: vc)
    }
}

//MARK: - SpotifyLoginViewControllerDelegate

extension AlbumsContainerViewController: SpotifyLoginViewControllerDelegate {
    
    func loginSucceeded() {
        launchNextBattery()
    }
    
    func cancelLogin() {
        delegate?.findAlbumsHome()
    }
    
}
