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
    func composeConfirmArtistScene(mainContainerCoordinator: MainContainerCoordinator, seedArtistStateController: SeedArtistStateController) -> ConfirmArtistViewController
    func composeInstructionsScene(mainContainerCoordinator: MainContainerCoordinator, userSettingsStateController: UserSettingsStateController) -> InstructionsViewController
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
        let archivingService = UserDefaultsArchivingService()
        let remoteDataService = SpotifyRemoteDataService(session: URLSession.shared, authService: SpotifyAuthManager())
        
        let userProfileStateController = UserProfileStateController(remoteDataService: remoteDataService, archiveService: archivingService)
        let seedArtistStateController = SeedArtistStateController(mediaLibraryService: ITunesLibraryService(),
                                                                  remoteDataService: remoteDataService,
                                                                  localDatabaseService: CoreDataService(coreDataStack: CoreDataStack(modelName: "Model")!))
        
        return MainContainerCoordinator(mainContainerViewController: ContainerViewController(),
                                        authStateController: authStateController,
                                        userProfileStateController: userProfileStateController,
                                        userSettingsStateController: UserSettingsStateController(archiveService: archivingService),
                                        seedArtistStateController: seedArtistStateController,
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
    
    func composeConfirmArtistScene(mainContainerCoordinator: MainContainerCoordinator, seedArtistStateController: SeedArtistStateController) -> ConfirmArtistViewController {
        let viewModel = ConfirmArtistViewModel(delegate: mainContainerCoordinator, seedArtistStateController: seedArtistStateController, externalURLProxy: AppDelegateURLProxy())
        return ConfirmArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeInstructionsScene(mainContainerCoordinator: MainContainerCoordinator, userSettingsStateController: UserSettingsStateController) -> InstructionsViewController {
        let viewModel = InstructionsViewModel(delegate: mainContainerCoordinator, userSettingsStateController: userSettingsStateController)
        return InstructionsViewController.createWith(viewModel: viewModel, storyBoard: UIStoryboard(name: "Main", bundle: nil))
    }
    
}








