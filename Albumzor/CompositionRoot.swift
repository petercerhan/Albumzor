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
//    func composeAuthStateController() -> AuthStateController
    
    func composeRootCoordinator() -> RootCoordinator
    
    func composeSetupSceneSetCoordinator(delegate: SetupSceneSetCoordinatorDelegate) -> SetupSceneSetCoordinator
    func composeSuggestAlbumsSceneSetCoordinator(delegate: SuggestAlbumsSceneSetCoordinatorDelegate) -> SuggestAlbumsSceneSetCoordinator
    func composeHomeSceneSetCoordinator(delegate: HomeSceneSetCoordinatorDelegate) -> HomeSceneSetCoordinator
    
    func composeOpenScene(delegate: OpenSceneViewModelDelegate) -> OpenSceneViewController
    func composeSpotifyLoginScene() -> SpotifyLoginViewController
    func composeWelcomeScene(delegate: WelcomeViewModelDelegate) -> WelcomeViewController
    func composeChooseArtistsScene(delegate: ChooseArtistViewModelDelegate) -> ChooseArtistViewController
    func composeConfirmArtistScene(delegate: ConfirmArtistViewModelDelegate) -> ConfirmArtistViewController
    func composeInstructionsScene(delegate: InstructionsViewModelDelegate) -> InstructionsViewController

    func composeSuggestAlbumsScene(delegate: SuggestAlbumsViewModelDelegate) -> SuggestAlbumsViewController
    func composeAlbumsDetailsScene(delegate: AlbumDetailsViewModelDelegate) -> AlbumDetailsViewController
    
    func composeHomeScene(delegate: HomeViewModelDelegate) -> HomeViewController
    func composeAlbumDetailsScene_FromHome(delegate: AlbumDetailsViewModelDelegate) -> AlbumDetailsViewController
    func composeMenuScene(delegate: MenuViewModelDelegate) -> MenuTableViewController
    func composeSortOptionsScene(delegate: SortOptionsViewModelDelegate) -> SortOptionsTableViewController
    func composeResetDataScene(delegate: ResetDataViewModelDelegate) -> ResetDataViewController
    
    var localDatabaseService: LocalDatabaseServiceProtocol { get }
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
    
    private lazy var likedAlbumsStateController: LikedAlbumsStateController = {
        return LikedAlbumsStateController(localDatabaseService: self.coreDataService, remoteDataService: self.spotifyRemoteDataService)
    }()
    
    private lazy var authStateController: AuthStateController = {
        return AuthStateController(authService: SpotifyAuthManager())
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
    
//    func composeAuthStateController() -> AuthStateController {
//        return AuthStateController(authService: SpotifyAuthManager())
//    }

    //MARK: - Coordinators
    
    func composeRootCoordinator() -> RootCoordinator {
        return RootCoordinator(containerViewController: ContainerViewController(),
                               compositionRoot: self)
    }
    
    func composeSetupSceneSetCoordinator(delegate: SetupSceneSetCoordinatorDelegate) -> SetupSceneSetCoordinator {
        return SetupSceneSetCoordinator(mainContainerViewController: ContainerViewController(),
                                        authStateController: authStateController,
                                        userProfileStateController: userProfileStateController,
                                        userSettingsStateController: userSettingsStateController,
                                        seedArtistStateController: seedArtistStateController,
                                        compositionRoot: self,
                                        delegate: delegate)
    }
    
    func composeHomeSceneSetCoordinator(delegate: HomeSceneSetCoordinatorDelegate) -> HomeSceneSetCoordinator {
        return HomeSceneSetCoordinator(containerViewController: NavigationContainerViewController(), compositionRoot: self,
                                       likedAlbumsStateController: likedAlbumsStateController,
                                       userProfileStateController: userProfileStateController,
                                       delegate: delegate)
    }
    
    func composeSuggestAlbumsSceneSetCoordinator(delegate: SuggestAlbumsSceneSetCoordinatorDelegate) -> SuggestAlbumsSceneSetCoordinator {
        return SuggestAlbumsSceneSetCoordinator(containerViewController: ContainerViewController(),
                                                compositionRoot: self,
                                                delegate: delegate,
                                                suggestedAlbumsStateController: suggestedAlbumsStateController)
    }
    
    //MARK: - Setup Scene Set
    
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
    
    //MARK: - Suggest Albums Scene Set
    
    func composeSuggestAlbumsScene(delegate: SuggestAlbumsViewModelDelegate) -> SuggestAlbumsViewController {
        resetSuggestedAlbumsStateController()
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
    
    //MARK: - Home Scene Set
    
    func composeHomeScene(delegate: HomeViewModelDelegate) -> HomeViewController {
        let viewModel = HomeViewModel(delegate: delegate,
                                      likedAlbumsStateController: likedAlbumsStateController,
                                      userSettingsStateController: userSettingsStateController)
        return HomeViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }

    func composeAlbumDetailsScene_FromHome(delegate: AlbumDetailsViewModelDelegate) -> AlbumDetailsViewController {
        let viewModel = AlbumDetailsViewModel(albumDetailsStateController: likedAlbumsStateController,
                                              audioStateController: audioStateController,
                                              externalURLProxy: AppDelegateURLProxy(),
                                              delegate: delegate)
        let vc = AlbumDetailsViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
        return vc
    }
    
    func composeMenuScene(delegate: MenuViewModelDelegate) -> MenuTableViewController {
        let viewModel = MenuViewModel(delegate: delegate,
                                      userSettingsStateController: userSettingsStateController,
                                      userProfileStateController: userProfileStateController,
                                      authStateController: authStateController)
        return MenuTableViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeSortOptionsScene(delegate: SortOptionsViewModelDelegate) -> SortOptionsTableViewController {
        let viewModel = SortOptionsViewModel(delegate: delegate, userSettingsStateController: userSettingsStateController)
        return SortOptionsTableViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    func composeResetDataScene(delegate: ResetDataViewModelDelegate) -> ResetDataViewController {
        let viewModel = ResetDataViewModel(delegate: delegate,
                                           seedArtistStateController: seedArtistStateController,
                                           userSettingsStateController: userSettingsStateController)
        return ResetDataViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
    
    //MARK: - Manage State Controllers
    
    private func resetSuggestedAlbumsStateController() {
        suggestedAlbumsStateController = SuggestedAlbumsStateController(localDatabaseService: self.coreDataService,
                                                                        remoteDataService: self.spotifyRemoteDataService,
                                                                        shufflingService: self.gameKitShufflingService)
    }
    
    //MARK: - Dev
    
    var localDatabaseService: LocalDatabaseServiceProtocol {
        return coreDataService
    }
    
}







