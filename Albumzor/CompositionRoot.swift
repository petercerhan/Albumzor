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
    
    func composeOpenScene(delegate: OpenSceneViewModelDelegate) -> OpenSceneViewController
    func composeSpotifyLoginScene() -> SpotifyLoginViewController
    func composeWelcomeScene(delegate: WelcomeViewModelDelegate) -> WelcomeViewController
    func composeChooseArtistsScene(delegate: ChooseArtistViewModelDelegate) -> ChooseArtistViewController
    func composeConfirmArtistScene(delegate: ConfirmArtistViewModelDelegate) -> ConfirmArtistViewController
    func composeInstructionsScene(delegate: InstructionsViewModelDelegate) -> InstructionsViewController

    func composeSuggestAlbumsScene(delegate: SuggestAlbumsViewModelDelegate) -> SuggestAlbumsViewController
    func composeAlbumsDetailsScene(delegate: AlbumDetailsViewModelDelegate) -> AlbumDetailsViewController
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
    
    func composeOpenScene(delegate: OpenSceneViewModelDelegate) -> OpenSceneViewController {
        let viewModel = OpenSceneViewModel(delegate: delegate)
        return OpenSceneViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeSpotifyLoginScene() -> SpotifyLoginViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpotifyLoginViewController") as! SpotifyLoginViewController
    }
    
    func composeWelcomeScene(delegate: WelcomeViewModelDelegate) -> WelcomeViewController {
        let viewModel = WelcomeViewModel(delegate: delegate, userProfileStateController: userProfileStateController)
        return WelcomeViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeChooseArtistsScene(delegate: ChooseArtistViewModelDelegate) -> ChooseArtistViewController {
        let viewModel = ChooseArtistViewModel(delegate: delegate, seedArtistStateController: seedArtistStateController)
        return ChooseArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeConfirmArtistScene(delegate: ConfirmArtistViewModelDelegate) -> ConfirmArtistViewController {
        let viewModel = ConfirmArtistViewModel(delegate: delegate, seedArtistStateController: seedArtistStateController, externalURLProxy: AppDelegateURLProxy())
        return ConfirmArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeInstructionsScene(delegate: InstructionsViewModelDelegate) -> InstructionsViewController {
        let viewModel = InstructionsViewModel(delegate: delegate, userSettingsStateController: userSettingsStateController)
        return InstructionsViewController.createWith(viewModel: viewModel, storyBoard: UIStoryboard(name: "Main", bundle: nil))
    }
    
    func composeSuggestAlbumsScene(delegate: SuggestAlbumsViewModelDelegate) -> SuggestAlbumsViewController {
        let viewModel = SuggestAlbumsViewModel(seedArtistStateController: seedArtistStateController,
                                               suggestedAlbumsStateController: suggestedAlbumsStateController,
                                               audioStateController: audioStateController,
                                               userSettingsStateController: userSettingsStateController,
                                               externalURLProxy: AppDelegateURLProxy(),
                                               delegate: delegate)
        let vc = SuggestAlbumsViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
        return vc
    }
    
    func composeAlbumsDetailsScene(delegate: AlbumDetailsViewModelDelegate) -> AlbumDetailsViewController {
        let viewModel = AlbumDetailsViewModel(albumDetailsStateController: suggestedAlbumsStateController,
                                              audioStateController: audioStateController,
                                              externalURLProxy: AppDelegateURLProxy(),
                                              delegate: delegate)
        let vc = AlbumDetailsViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
        return vc
    }
}







