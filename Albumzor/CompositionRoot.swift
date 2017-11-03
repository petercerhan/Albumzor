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
    
    func composeRootCoordinator() -> RootCoordinator
    
    func composeSetupSceneSetCoordinator() -> SetupSceneSetCoordinator
    
    func composeOpenScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> OpenSceneViewController
    func composeSpotifyLoginScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> SpotifyLoginViewController
    func composeWelcomeScene(mainContainerCoordinator: SetupSceneSetCoordinator, userProfileStateController: UserProfileStateController) -> WelcomeViewController
    func composeChooseArtistsScene(mainContainerCoordinator: SetupSceneSetCoordinator, seedArtistStateController: SeedArtistStateController) -> ChooseArtistViewController
    func composeConfirmArtistScene(mainContainerCoordinator: SetupSceneSetCoordinator, seedArtistStateController: SeedArtistStateController) -> ConfirmArtistViewController
    func composeInstructionsScene(mainContainerCoordinator: SetupSceneSetCoordinator, userSettingsStateController: UserSettingsStateController) -> InstructionsViewController
    func composeSuggestAlbumsScene(mainContainerCoordinator: SetupSceneSetCoordinator, seedArtistStateController: SeedArtistStateController, audioStateController: AudioStateController, userSettingsStateController: UserSettingsStateController) -> SuggestAlbumsViewController
    func composeAlbumsDetailsScene(mainContainerCoordinator: SetupSceneSetCoordinator, albumDetailsStateController: AlbumDetailsStateControllerProtocol, audioStateController: AudioStateController) -> AlbumDetailsViewController
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
    
    func composeRootCoordinator() -> RootCoordinator {
        return RootCoordinator(containerViewController: ContainerViewController(),
                               compositionRoot: self)
    }
    
    func composeSetupSceneSetCoordinator() -> SetupSceneSetCoordinator {
        let archivingService = UserDefaultsArchivingService()
        let remoteDataService = SpotifyRemoteDataService(session: URLSession.shared, authService: SpotifyAuthManager())
        
        let userProfileStateController = UserProfileStateController(remoteDataService: remoteDataService, archiveService: archivingService)
        let seedArtistStateController = SeedArtistStateController(mediaLibraryService: ITunesLibraryService(),
                                                                  remoteDataService: remoteDataService,
                                                                  localDatabaseService: CoreDataService(coreDataStack: CoreDataStack(modelName: "Model")!))
        let audioStateController = AudioStateController(audioService: AVAudioPlayerService())
        
        return SetupSceneSetCoordinator(mainContainerViewController: ContainerViewController(),
                                        authStateController: composeAuthStateController(),
                                        userProfileStateController: userProfileStateController,
                                        userSettingsStateController: UserSettingsStateController(archiveService: archivingService),
                                        seedArtistStateController: seedArtistStateController,
                                        audioStateController: audioStateController,
                                        compositionRoot: self)
    }
    
    //MARK: - Main Coordinator Scenes
    
    func composeOpenScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> OpenSceneViewController {
        let viewModel = OpenSceneViewModel(delegate: mainContainerCoordinator)
        return OpenSceneViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeSpotifyLoginScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> SpotifyLoginViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController
    }
    
    func composeWelcomeScene(mainContainerCoordinator: SetupSceneSetCoordinator, userProfileStateController: UserProfileStateController) -> WelcomeViewController {
        let viewModel = WelcomeViewModel(delegate: mainContainerCoordinator, userProfileStateController: userProfileStateController)
        return WelcomeViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeChooseArtistsScene(mainContainerCoordinator: SetupSceneSetCoordinator, seedArtistStateController: SeedArtistStateController) -> ChooseArtistViewController {
        let viewModel = ChooseArtistViewModel(delegate: mainContainerCoordinator, seedArtistStateController: seedArtistStateController)
        return ChooseArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeConfirmArtistScene(mainContainerCoordinator: SetupSceneSetCoordinator, seedArtistStateController: SeedArtistStateController) -> ConfirmArtistViewController {
        let viewModel = ConfirmArtistViewModel(delegate: mainContainerCoordinator, seedArtistStateController: seedArtistStateController, externalURLProxy: AppDelegateURLProxy())
        return ConfirmArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeInstructionsScene(mainContainerCoordinator: SetupSceneSetCoordinator, userSettingsStateController: UserSettingsStateController) -> InstructionsViewController {
        let viewModel = InstructionsViewModel(delegate: mainContainerCoordinator, userSettingsStateController: userSettingsStateController)
        return InstructionsViewController.createWith(viewModel: viewModel, storyBoard: UIStoryboard(name: "Main", bundle: nil))
    }
    
    func composeSuggestAlbumsScene(mainContainerCoordinator: SetupSceneSetCoordinator, seedArtistStateController: SeedArtistStateController, audioStateController: AudioStateController, userSettingsStateController: UserSettingsStateController) -> SuggestAlbumsViewController {
        let remoteDataService = SpotifyRemoteDataService(session: URLSession.shared, authService: SpotifyAuthManager())
        let suggestedAlbumsStateController = SuggestedAlbumsStateController(localDatabaseService: CoreDataService(coreDataStack: CoreDataStack(modelName: "Model")!),
                                                                            remoteDataService: remoteDataService,
                                                                            shufflingService: GameKitShufflingService())
        let viewModel = SuggestAlbumsViewModel(seedArtistStateController: seedArtistStateController,
                                               suggestedAlbumsStateController: suggestedAlbumsStateController,
                                               audioStateController: audioStateController,
                                               userSettingsStateController: userSettingsStateController,
                                               externalURLProxy: AppDelegateURLProxy(),
                                               delegate: mainContainerCoordinator)
        let vc = SuggestAlbumsViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
        return vc
    }
    
    func composeAlbumsDetailsScene(mainContainerCoordinator: SetupSceneSetCoordinator, albumDetailsStateController: AlbumDetailsStateControllerProtocol, audioStateController: AudioStateController) -> AlbumDetailsViewController {
        let viewModel = AlbumDetailsViewModel(albumDetailsStateController: albumDetailsStateController,
                                              audioStateController: audioStateController,
                                              externalURLProxy: AppDelegateURLProxy(),
                                              delegate: mainContainerCoordinator)
        let vc = AlbumDetailsViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
        return vc
    }
}







