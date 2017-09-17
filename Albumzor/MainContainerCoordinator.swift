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
        print("Authenticated: \(authStateController.sessionIsValid)")
        
        if authStateController.sessionIsValid {
            print("Launch primary code path")
        } else {
            let vc = compositionRoot.composeSpotifyLoginScene(mainContainerCoordinator: self)
            vc.spotifyConnected = userProfileStateController.spotifyIsConnected()
            
            mainContainerViewController.show(viewController: vc, animation: .none)
            
            //Must be set after view controller is added to container. Fix at some point
            vc.cancelButton.isHidden = true
            vc.controllerDelegate = self
        }
    }
}

//MARK: - SpotifyViewControllerDelegate

extension MainContainerCoordinator: SpotifyLoginViewControllerDelegate {
    
    func loginSucceeded() {
        print("Delegate recognizes login succeeded")
        print("Authenticated: \(authStateController.sessionIsValid)")
    }
    
    func cancelLogin() {
        //remain on login page
    }
    
}

