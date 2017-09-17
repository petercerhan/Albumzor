//
//  CompositionRoot.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import UIKit

protocol CompositionRootProtocol {
    func composeWindow() -> UIWindow
    func composeMainCoordinator(authStateController: AuthStateController) -> MainContainerCoordinator
    func composeOpenScene(mainContainerCoordinator: MainContainerCoordinator) -> OpenSceneViewController
    func composeAuthStateController() -> AuthStateController
    func composeSpotifyLoginScene(mainContainerCoordinator: MainContainerCoordinator) -> SpotifyLoginViewController
}

class CompositionRoot: CompositionRootProtocol {
    
    //MARK: - AppDelegate Dependencies
    //(Non-coordinators)
    
    func composeWindow() -> UIWindow {
        return UIWindow(frame: UIScreen.main.bounds)
    }
    
    func composeAuthStateController() -> AuthStateController {
        return AuthStateController(authService: SpotifyAuthManager())
    }

    //MARK: - Coordinators
    
    func composeMainCoordinator(authStateController: AuthStateController) -> MainContainerCoordinator {
        return MainContainerCoordinator(mainContainerViewController: ContainerViewController(), authStateController: authStateController, userProfileStateController: UserProfileStateController(), compositionRoot: self)
    }
    
    //MARK: - Main Coordinator Scenes
    
    func composeOpenScene(mainContainerCoordinator: MainContainerCoordinator) -> OpenSceneViewController {
        let viewModel = OpenSceneViewModel(delegate: mainContainerCoordinator)
        return OpenSceneViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeSpotifyLoginScene(mainContainerCoordinator: MainContainerCoordinator) -> SpotifyLoginViewController {
        
        let appStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = appStoryboard.instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController

        return vc
    }
    
}

