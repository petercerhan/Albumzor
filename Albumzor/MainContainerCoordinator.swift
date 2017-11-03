//
//  MainContainerCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class MainContainerCoordinator: Coordinator {
    
    //MARK: - Dependencies
    
    let mainContainerViewController: ContainerViewController
    let authStateController: AuthStateController
    let userProfileStateController: UserProfileStateController
    let userSettingsStateController: UserSettingsStateController
    let seedArtistStateController: SeedArtistStateController
    let audioStateController: AudioStateController
    let compositionRoot: CompositionRootProtocol
    
    //MARK: - Children
    
    var childCoordinators = [Any]()
    var activeSceneDelegateProxy: AnyObject?
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(mainContainerViewController: ContainerViewController,
         authStateController: AuthStateController,
         userProfileStateController: UserProfileStateController,
         userSettingsStateController: UserSettingsStateController,
         seedArtistStateController: SeedArtistStateController,
         audioStateController: AudioStateController,
         compositionRoot: CompositionRootProtocol)
    {
            self.mainContainerViewController = mainContainerViewController
            self.authStateController = authStateController
            self.userProfileStateController = userProfileStateController
            self.userSettingsStateController = userSettingsStateController
            self.seedArtistStateController = seedArtistStateController
            self.audioStateController = audioStateController
            self.compositionRoot = compositionRoot
    }
    
    //MARK: - Interface
    
    var containerViewController: UIViewController {
        return mainContainerViewController
    }
    
    func start() {
        let vc = compositionRoot.composeOpenScene(mainContainerCoordinator: self)
        mainContainerViewController.show(viewController: vc, animation: .none)
    }
    
}

//MARK: - OpenSceneViewModelDelegate

extension MainContainerCoordinator: OpenSceneViewModelDelegate {
    func sceneComplete(_ openSceneViewModel: OpenSceneViewModel) {
        print("Open Scene complete callback")
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
        print("post authentication code path")
//        print("\n\nInstructionsSeen: \(userSettingsStateController.instructionsSeen()) \nIsSeeded: \(userSettingsStateController.isSeeded()) \nAutoplay: \(userSettingsStateController.isAutoplayEnabled()) \nAlbumSortType: \(userSettingsStateController.getAlbumSortType())")
        
        let instructionsSeen = userSettingsStateController.instructionsSeen.value
        let isSeeded = userSettingsStateController.isSeeded.value
        
        if instructionsSeen && isSeeded {
            //Launch Home Scene
            print("Launch home scene")

            let presentingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController

//            mainContainerViewController.show(viewController: vc, animation: .none)
            
            let modalVC = compositionRoot.composeSuggestAlbumsScene(mainContainerCoordinator: self, seedArtistStateController: seedArtistStateController, audioStateController: audioStateController, userSettingsStateController: userSettingsStateController)
//            mainContainerViewController.show(viewController: vc, animation: .none)
            mainContainerViewController.showModalWithPresenter(modalViewController: modalVC, presentingViewController: presentingVC, animation: .none)
            
            
        } else if !instructionsSeen && !isSeeded {
            //Launch Welcome Scene
            let vc = compositionRoot.composeWelcomeScene(mainContainerCoordinator: self, userProfileStateController: userProfileStateController)
            mainContainerViewController.show(viewController: vc, animation: .none)
        } else if instructionsSeen && !isSeeded {
            //launch Seed Artists scene
            print("launch seed artist")
        } else if !instructionsSeen && isSeeded {
            //Launch Instructions Scene
            let vc = compositionRoot.composeInstructionsScene(mainContainerCoordinator: self, userSettingsStateController: userSettingsStateController)
            mainContainerViewController.show(viewController: vc, animation: .slideFromRight)
        }
    }
    
}

//MARK: - SpotifyViewControllerDelegate

extension MainContainerCoordinator: SpotifyLoginViewControllerDelegate {
    
    func loginSucceeded() {
        userProfileStateController.setSpotifyConnected()
        launchPostAuthenticationScene()
    }
    
    func cancelLogin() {
        //remain on login page
    }
    
}

//MARK: - WelcomeViewModelDelegate

extension MainContainerCoordinator: WelcomeViewModelDelegate {
    
    func requestToChooseArtists(from welcomeViewModel: WelcomeViewModel) {
        launchChooseArtistsScene(animated: true)
    }
    
    func launchChooseArtistsScene(animated: Bool) {
        
        seedArtistStateController.fetchSeedArtistsFromMediaLibrary()
        
        seedArtistStateController.seedArtists.asObservable()
            .observeOn(MainScheduler.instance)
            .filter( { artists in
                artists.count > 0
            })
            .take(1)
            .subscribe(onNext: { [unowned self] artists in
                if artists.count > 0 {
                    let vc = self.compositionRoot.composeChooseArtistsScene(mainContainerCoordinator: self, seedArtistStateController: self.seedArtistStateController)
            
                    self.mainContainerViewController.show(viewController: vc, animation: animated ? .slideFromRight : .none)
                }
            })
            .disposed(by: disposeBag)
    }
    
}

//MARK: - ChooseArtistViewModelDelegate

extension MainContainerCoordinator: ChooseArtistViewModelDelegate {
    
    func chooseArtistSceneComplete(_ chooseArtistViewModel: ChooseArtistViewModel) {
        print("Choose artists scene complete")
        
        userSettingsStateController.setIsSeeded(true)
        
        //launch instructions scene
        if userSettingsStateController.instructionsSeen.value {
            //launch suggest albums scene
        } else {
            let vc = compositionRoot.composeInstructionsScene(mainContainerCoordinator: self, userSettingsStateController: userSettingsStateController)
            mainContainerViewController.show(viewController: vc, animation: .slideFromRight)
        }
        
    }
    
    func showConfirmArtistScene(_ chooseArtistViewModel: ChooseArtistViewModel, confirmationArtist: String) {
        
        let confirmArtistVC = compositionRoot.composeConfirmArtistScene(mainContainerCoordinator: self, seedArtistStateController: seedArtistStateController)
        
        //launch spotify confirmation, if necessary
        if !(authStateController.sessionIsValid) {
            let vc = compositionRoot.composeSpotifyLoginScene(mainContainerCoordinator: self)
            
            mainContainerViewController.showModally(viewController: vc)
            
            //Inject somehow?
            let spotifyLoginDelegateProxy = SpotifyLoginDelegateProxy()
            spotifyLoginDelegateProxy.loginSucceededCallback = { [weak self] in
                self?.mainContainerViewController.replaceModalVC(viewController: confirmArtistVC)
            }
            spotifyLoginDelegateProxy.cancelLoginCallback = { [weak self] in
                self?.mainContainerViewController.dismissModalVC()
            }
            
            activeSceneDelegateProxy = spotifyLoginDelegateProxy
            
            //Must be set after view controller is added to container. Fix at some point
            vc.controllerDelegate = spotifyLoginDelegateProxy
            vc.cancelButton.isHidden = false
        } else {
            mainContainerViewController.showModally(viewController: confirmArtistVC)
        }
    }
}

//MARK: - ConfirmArtistViewModelDelegate

extension MainContainerCoordinator: ConfirmArtistViewModelDelegate {
    
    func cancel(_ confirmArtistViewModel: ConfirmArtistViewModel) {
        mainContainerViewController.dismissModalVC()
    }
    
}

//MARK: - SuggestAlbumsViewModelDelegate

extension MainContainerCoordinator: SuggestAlbumsViewModelDelegate {

    func suggestAlbumsSceneComplete(_ suggestAlbumsViewModel: SuggestAlbumsViewModel) {
        mainContainerViewController.dismissModalVC()
    }
    
    func showAlbumDetails(_ suggestArtistViewModel: SuggestAlbumsViewModel, albumDetailsStateController: AlbumDetailsStateControllerProtocol) {
        let vc = compositionRoot.composeAlbumsDetailsScene(mainContainerCoordinator: self, albumDetailsStateController: albumDetailsStateController, audioStateController: audioStateController)
        mainContainerViewController.showModally(viewController: vc)
    }
    
}

//MARK: - AlbumDetailsViewModelDelegate

extension MainContainerCoordinator: AlbumDetailsViewModelDelegate {
    
    func dismiss(_ albumDetailsViewModel: AlbumDetailsViewModel) {
        mainContainerViewController.dismissModalVC()
    }
    
}

//MARK: - InstructionsViewModelDelegate

extension MainContainerCoordinator: InstructionsViewModelDelegate {
    
    func requestNextScene(_ instructionsViewModel: InstructionsViewModel) {
        print("Instructions scene complete")
    }
    
}









