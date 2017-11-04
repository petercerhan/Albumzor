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
    func composeWelcomeScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> WelcomeViewController
    func composeChooseArtistsScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> ChooseArtistViewController
    func composeConfirmArtistScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> ConfirmArtistViewController
    func composeInstructionsScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> InstructionsViewController

    func composeSuggestAlbumsScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> SuggestAlbumsViewController
    func composeAlbumsDetailsScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> AlbumDetailsViewController
}

class CompositionRoot: CompositionRootProtocol {
    
    //MARK: - State Controllers
    
    private lazy var userProfileStateController: UserProfileStateController = {
        return UserProfileStateController(remoteDataService: self.spotifyRemoteDataService,
                                          archiveService: self.userDefaultsArchivingService)
    }()
    
    private lazy var userSettingsStateController: UserSettingsStateController = {
        return UserSettingsStateController(archiveService: self.userDefaultsArchivingService)
    }()
    
    private lazy var suggestedAlbumsStateController: SuggestedAlbumsStateController = {
        return SuggestedAlbumsStateController(localDatabaseService: self.coreDataService,
                                              remoteDataService: self.spotifyRemoteDataService,
                                              shufflingService: self.gameKitShufflingService)
    }()
    
    private lazy var seedArtistStateController: SeedArtistStateController = {
        return SeedArtistStateController(mediaLibraryService: self.itunesLibraryService,
                                         remoteDataService: self.spotifyRemoteDataService,
                                         localDatabaseService: self.coreDataService)
    }()
    
    private lazy var audioStateController: AudioStateController = {
        return AudioStateController(audioService: self.avAudioPlayerService)
    }()
    
    //MARK: - Services
    
    private lazy var coreDataService: CoreDataService = {
        return CoreDataService(coreDataStack: CoreDataStack(modelName: "Model")!)
    }()
    
    private lazy var userDefaultsArchivingService: UserDefaultsArchivingService = UserDefaultsArchivingService()
    
    private lazy var spotifyRemoteDataService: SpotifyRemoteDataService = {
        return SpotifyRemoteDataService(session: URLSession.shared, authService: SpotifyAuthManager())
    }()
    
    private lazy var gameKitShufflingService: GameKitShufflingService = GameKitShufflingService()
    
    private lazy var itunesLibraryService = ITunesLibraryService()
    
    private lazy var avAudioPlayerService = AVAudioPlayerService()
    
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
        return SetupSceneSetCoordinator(mainContainerViewController: ContainerViewController(),
                                        authStateController: composeAuthStateController(),
                                        userProfileStateController: userProfileStateController,
                                        userSettingsStateController: userSettingsStateController,
                                        seedArtistStateController: seedArtistStateController,
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
    
    func composeWelcomeScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> WelcomeViewController {
        let viewModel = WelcomeViewModel(delegate: mainContainerCoordinator, userProfileStateController: userProfileStateController)
        return WelcomeViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeChooseArtistsScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> ChooseArtistViewController {
        let viewModel = ChooseArtistViewModel(delegate: mainContainerCoordinator,
                                              seedArtistStateController: seedArtistStateController)
        return ChooseArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil),
                                                     viewModel: viewModel)
    }
    
    func composeConfirmArtistScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> ConfirmArtistViewController {
        let viewModel = ConfirmArtistViewModel(delegate: mainContainerCoordinator, seedArtistStateController: seedArtistStateController, externalURLProxy: AppDelegateURLProxy())
        return ConfirmArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeInstructionsScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> InstructionsViewController {
        let viewModel = InstructionsViewModel(delegate: mainContainerCoordinator, userSettingsStateController: userSettingsStateController)
        return InstructionsViewController.createWith(viewModel: viewModel, storyBoard: UIStoryboard(name: "Main", bundle: nil))
    }
    
    func composeSuggestAlbumsScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> SuggestAlbumsViewController {
        let viewModel = SuggestAlbumsViewModel(seedArtistStateController: seedArtistStateController,
                                               suggestedAlbumsStateController: suggestedAlbumsStateController,
                                               audioStateController: audioStateController,
                                               userSettingsStateController: userSettingsStateController,
                                               externalURLProxy: AppDelegateURLProxy(),
                                               delegate: mainContainerCoordinator)
        let vc = SuggestAlbumsViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
        return vc
    }
    
    func composeAlbumsDetailsScene(mainContainerCoordinator: SetupSceneSetCoordinator) -> AlbumDetailsViewController {
        let viewModel = AlbumDetailsViewModel(albumDetailsStateController: suggestedAlbumsStateController,
                                              audioStateController: audioStateController,
                                              externalURLProxy: AppDelegateURLProxy(),
                                              delegate: mainContainerCoordinator)
        let vc = AlbumDetailsViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
        return vc
    }
}







