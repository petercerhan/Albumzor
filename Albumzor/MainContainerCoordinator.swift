//
//  MainContainerCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

//Temporary
import MediaPlayer
import GameKit

class MainContainerCoordinator {
    
    //MARK: - Dependencies
    
    let mainContainerViewController: ContainerViewController
    let authStateController: AuthStateController
    let userProfileStateController: UserProfileStateController
    let userSettingsStateController: UserSettingsStateController
    let compositionRoot: CompositionRootProtocol
    
    //MARK: - Children
    
    var childCoordinators = [Any]()
    
    //MARK: - Initialization
    
    init(mainContainerViewController: ContainerViewController,
         authStateController: AuthStateController,
         userProfileStateController: UserProfileStateController,
         userSettingsStateController: UserSettingsStateController,
         compositionRoot: CompositionRootProtocol)
    {
            self.mainContainerViewController = mainContainerViewController
            self.authStateController = authStateController
            self.userProfileStateController = userProfileStateController
            self.userSettingsStateController = userSettingsStateController
            self.compositionRoot = compositionRoot
    }
    
    func start() {
        let vc = compositionRoot.composeOpenScene(mainContainerCoordinator: self)
        mainContainerViewController.show(viewController: vc, animation: .none)
    }
    
}

//MARK: - OpenSceneViewModelDelegate

extension MainContainerCoordinator: OpenSceneViewModelDelegate {
    func sceneComplete(_ openSceneViewModel: OpenSceneViewModel) {
        
        if authStateController.sessionIsValid {
            launchPostAuthenticationScene()
        } else {
            let vc = compositionRoot.composeSpotifyLoginScene(mainContainerCoordinator: self)
            
            vc.spotifyConnected = userProfileStateController.spotifyConnected.value
            
            mainContainerViewController.show(viewController: vc, animation: .none)
            
            //Must be set after view controller is added to container. Fix at some point
            vc.cancelButton.isHidden = true
            vc.controllerDelegate = self
        }
    }
    
    //Enter main application once a valid session has been obtained
    func launchPostAuthenticationScene() {
        
//        print("\n\nInstructionsSeen: \(userSettingsStateController.instructionsSeen()) \nIsSeeded: \(userSettingsStateController.isSeeded()) \nAutoplay: \(userSettingsStateController.isAutoplayEnabled()) \nAlbumSortType: \(userSettingsStateController.getAlbumSortType())")
        
        if userSettingsStateController.instructionsSeen() && userSettingsStateController.isSeeded() {
            //Launch Home Scene
        } else if !(userSettingsStateController.instructionsSeen()) && !(userSettingsStateController.isSeeded()) {
            //Launch welcome scene
            let vc = compositionRoot.composeWelcomeScene(mainContainerCoordinator: self, userProfileStateController: userProfileStateController)
            mainContainerViewController.show(viewController: vc, animation: .none)
            
        } else if userSettingsStateController.instructionsSeen() && !userSettingsStateController.isSeeded() {
            //launch Seed Artists scene
        } else if !userSettingsStateController.instructionsSeen() && userSettingsStateController.isSeeded() {
            //launch Instructions Scene
        }
        
    }
    
    
}

//MARK: - SpotifyViewControllerDelegate

extension MainContainerCoordinator: SpotifyLoginViewControllerDelegate {
    
    func loginSucceeded() {
        print("login succeeded")
        userProfileStateController.setSpotifyConnected()
        launchPostAuthenticationScene()
    }
    
    func cancelLogin() {
        //remain on login page
    }
    
}

//MARK: - WelcomeViewControllerDelegate

extension MainContainerCoordinator: WelcomeViewModelDelegate {
    
    func requestToChooseArtists(from welcomeViewModel: WelcomeViewModel) {
        print("Welcome Scene Complete")
        
        
        getSeedArtists(animateTransition: true)
        
    }
    
    
    
    
    //TEMPORARY
    func getSeedArtists(animateTransition: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            var artists = [String]()
            
            if let itunesArtists = self.getArtistsFromItunes() {
                artists = itunesArtists
            } else {
                artists = ChooseArtistViewController.defaultArtists
            }
            
            artists = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: artists) as! Array<String>
            
            DispatchQueue.main.async {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseArtistViewController") as! ChooseArtistViewController
                vc.artists = artists
                vc.delegate = self
                
                if animateTransition {
                    self.mainContainerViewController.show(viewController: vc, animation: .slideFromRight)
                } else {
                    self.mainContainerViewController.show(viewController: vc, animation: .none)
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

extension MainContainerCoordinator: ChooseArtistViewControllerDelegate {
    func chooseArtistSceneComplete() {
        print("Choose artists scene complete")
    }
}











