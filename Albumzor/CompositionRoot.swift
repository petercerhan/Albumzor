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
    func composeAuthStateController() -> AuthStateController
    
    func composeMainCoordinator(authStateController: AuthStateController) -> MainContainerCoordinator
    
    func composeOpenScene(mainContainerCoordinator: MainContainerCoordinator) -> OpenSceneViewController
    func composeSpotifyLoginScene(mainContainerCoordinator: MainContainerCoordinator) -> SpotifyLoginViewController
    func composeWelcomeScene(mainContainerCoordinator: MainContainerCoordinator, userProfileStateController: UserProfileStateController) -> WelcomeViewController
    func composeChooseArtistsScene(mainContainerCoordinator: MainContainerCoordinator, seedArtistStateController: SeedArtistStateController) -> ChooseArtistViewController
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
        let remoteDataService = SpotifyRemoteDataService(session: URLSession.shared, authService: SpotifyAuthManager())
        let userProfileStateController = UserProfileStateController(remoteDataService: remoteDataService, archiveService: UserDefaultsArchivingService())
        return MainContainerCoordinator(mainContainerViewController: ContainerViewController(),
                                        authStateController: authStateController,
                                        userProfileStateController: userProfileStateController,
                                        userSettingsStateController: UserSettingsStateController(),
                                        seedArtistStateController: SeedArtistStateController(mediaLibraryService: ITunesLibraryService(), remoteDataService: remoteDataService),
                                        compositionRoot: self)
    }
    
    //MARK: - Main Coordinator Scenes
    
    func composeOpenScene(mainContainerCoordinator: MainContainerCoordinator) -> OpenSceneViewController {
        let viewModel = OpenSceneViewModel(delegate: mainContainerCoordinator)
        return OpenSceneViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeSpotifyLoginScene(mainContainerCoordinator: MainContainerCoordinator) -> SpotifyLoginViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController
    }
    
    func composeWelcomeScene(mainContainerCoordinator: MainContainerCoordinator, userProfileStateController: UserProfileStateController) -> WelcomeViewController {
        let viewModel = WelcomeViewModel(delegate: mainContainerCoordinator, userProfileStateController: userProfileStateController)
        return WelcomeViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeChooseArtistsScene(mainContainerCoordinator: MainContainerCoordinator, seedArtistStateController: SeedArtistStateController) -> ChooseArtistViewController {
        let viewModel = ChooseArtistViewModel(delegate: mainContainerCoordinator, seedArtistStateController: seedArtistStateController)
        return ChooseArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
}








