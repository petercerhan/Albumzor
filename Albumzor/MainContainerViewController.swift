//
//  MainContainerViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import MediaPlayer
import GameplayKit

class MainContainerViewController: UIViewController {
    
    private var contentViewController: UIViewController
    let appStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    var hideStatusBar = true
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    init() {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "OpenSceneViewController") as! OpenSceneViewController
        contentViewController = vc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //Never instantiated from resource file
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
        
        //animate here
        
        priorViewController.view.removeFromSuperview()
        priorViewController.removeFromParentViewController()
    }
    
    func updateAnimated(contentViewController newViewController: UIViewController) {
        
        let priorViewController = contentViewController
        
        contentViewController = newViewController
        
        addChildViewController(newViewController)
        
        newViewController.view.frame = view.bounds
        newViewController.view.center.x += view.frame.width
        view.addSubview(newViewController.view)
        
        priorViewController.willMove(toParentViewController: nil)
        newViewController.didMove(toParentViewController: self)
        
        //animate here
        UIView.animate(withDuration: 0.3, animations: {
            _ in
            newViewController.view.center.x -= self.view.frame.width
            priorViewController.view.center.x -= self.view.frame.width
        }, completion:{
            _ in
            priorViewController.view.removeFromSuperview()
            priorViewController.removeFromParentViewController()
        })
        
    }
}

//MARK: - SpotifyLoginViewControllerDelegate

extension MainContainerViewController: SpotifyLoginViewControllerDelegate {
    func loginSucceeded() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

        let userProfile = appDelegate.userProfile
        userProfile.spotifyConnected = true
        appDelegate.saveUserProfile()
        
        //load user settings from UserDefaults
        appDelegate.loadUserSettings()
        let userSettings = appDelegate.userSettings
        
        if userSettings.instructionsSeen && userSettings.isSeeded {
            //standard situation - go straight to home screen
            let vc = appStoryboard.instantiateViewController(withIdentifier: "HomeNavController")
            update(contentViewController: vc)

        } else if !(userSettings.instructionsSeen) && !(userSettings.isSeeded) {
            //first time sequence
            let vc = appStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
//            vc.delegate = self
            update(contentViewController: vc)

        } else if userSettings.instructionsSeen && !userSettings.isSeeded {
            //needs reseeding; go to choose artist screen
            getSeedArtists(animateTransition: false)

        } else if !userSettings.instructionsSeen && userSettings.isSeeded {
            //user seeded artists but didn't navigate to final instructions pane
            //show last instruction screen
            let vc = appStoryboard.instantiateViewController(withIdentifier: "InstructionsViewController") as! InstructionsViewController
            vc.delegate = self
            update(contentViewController: vc)
        }
    }
    
    func cancelLogin() {
        
    }
}

//MARK: - OpenSceneViewControllerDelegate

extension MainContainerViewController {
    func openingSceneComplete() {
        hideStatusBar = false
        setNeedsStatusBarAppearanceUpdate()
        
        if SpotifyAuthManager().sessionIsValid() {
            loginSucceeded()
        
        } else {
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            
            let vc = appStoryboard.instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController
            vc.spotifyConnected = appDelegate.userProfile.spotifyConnected
            update(contentViewController: vc)
            vc.cancelButton.isHidden = true
            vc.controllerDelegate = self
        }
    }
}

//MARK: - WelcomeViewControllerDelegate

extension MainContainerViewController {
    func chooseArtists() {
        getSeedArtists(animateTransition: true)
    }
    
    func getSeedArtists(animateTransition: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            var artists = [String]()
            
            if let itunesArtists = self.getArtistsFromItunes() {
                artists = itunesArtists
            } else {
                artists = ITunesLibraryService.defaultArtists
            }
        
            artists = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: artists) as! Array<String>
            
            DispatchQueue.main.async {
                let vc = self.appStoryboard.instantiateViewController(withIdentifier: "ChooseArtistViewController") as! ChooseArtistViewController
//                vc.artists = artists
//                vc.delegate = self
                
                if animateTransition {
                    self.updateAnimated(contentViewController: vc)
                } else {
                    self.update(contentViewController: vc)
                }
            }
        }
    }
    
    func getArtistsFromItunes() -> [String]? {
        let artistQuery = MPMediaQuery.artists()
        
        guard let mediaItemsArray = artistQuery.items else {
            return nil
        }
        
        let rawArtistNames = mediaItemsArray.map { mediaItem in return mediaItem.albumArtist ?? "" }
        var artistSet = Set(rawArtistNames)
        let emptyStringSet: Set = ["", " "]
        artistSet = artistSet.subtracting(emptyStringSet)
        
        var namesArray = Array(artistSet)
        namesArray = namesArray.map { artistName in return artistName.cleanArtistName() }
        namesArray = namesArray.map { artistName in return artistName.truncated(maxLength: 30) }
        
        //Remove any new duplicates after cleaning up artist names
        namesArray = Array(Set(namesArray))
        namesArray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: namesArray) as! Array<String>
        
        if namesArray.count < 15 {
            return nil
        } else {
            return namesArray
        }
    }
}

//MARK: - ChooseArtistViewControllerDelegate

extension MainContainerViewController: ChooseArtistViewControllerDelegate {
    func chooseArtistSceneComplete() {
        let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
        
        if userSettings.instructionsSeen {
            let vc = AlbumsContainerViewController()
            vc.delegate = self
            updateAnimated(contentViewController: vc)
        } else {
            let vc = appStoryboard.instantiateViewController(withIdentifier: "InstructionsViewController") as! InstructionsViewController
            vc.delegate = self
            updateAnimated(contentViewController: vc)
        }
    }
}

//MARK: - InstructionsViewControllerDelegate

extension MainContainerViewController: InstructionsViewControllerDelegate {
    func instructionsSceneComplete() {
        let vc = AlbumsContainerViewController()
        vc.delegate = self
        updateAnimated(contentViewController: vc)
    }
}

//MARK: - AlbumsContainerViewControllerDelegate

extension MainContainerViewController: AlbumsContainerViewControllerDelegate {
    func findAlbumsHome() {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "HomeNavController")
        update(contentViewController: vc)
    }
}

//MARK: - MenuTableViewControllerDelegate

extension MainContainerViewController: MenuTableViewControllerDelegate {
    func resetData(action: ResetDataAction) {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "ResetDataViewController") as! ResetDataViewController
        vc.delegate = self
        vc.action = action
        update(contentViewController: vc)
    }
    
    func spotifyDisconnected() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        let vc = appStoryboard.instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController
        vc.spotifyConnected = appDelegate.userProfile.spotifyConnected
        update(contentViewController: vc)
        vc.cancelButton.isHidden = true
        vc.controllerDelegate = self
    }
}

//MARK: - ResetDataViewControllerDelegate

extension MainContainerViewController: ResetDataViewControllerDelegate {
    
    func resetSucceeded() {
        let userSettings = (UIApplication.shared.delegate as! AppDelegate).userSettings
        
        if userSettings.instructionsSeen {
            getSeedArtists(animateTransition: false)
        } else {
            let vc = appStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
//            vc.delegate = self
            update(contentViewController: vc)
        }
    }
    
    func resetFailed() {
        //This should not happen as core data updates should always succeed
        let vc = appStoryboard.instantiateViewController(withIdentifier: "HomeNavController")
        update(contentViewController: vc)
    }
}



