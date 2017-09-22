//
//  MainContainerCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

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
        //print("Authenticated: \(authStateController.sessionIsValid)")
        
        if authStateController.sessionIsValid {
            launchPostAuthenticationScene()
        } else {
            let vc = compositionRoot.composeSpotifyLoginScene(mainContainerCoordinator: self)
            vc.spotifyConnected = userProfileStateController.spotifyIsConnected()
            
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
            let vc = compositionRoot.composeWelcomeScene(mainContainerCoordinator: self)
            
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
        //Code path in OpenSceneViewModelDelegate section
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
    }
    
}












