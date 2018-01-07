//
//  SetupSceneSetCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol SetupSceneSetCoordinatorDelegate: class {
    func requestHomeSceneSet(_ setupSceneSetCoordinator: SetupSceneSetCoordinator)
    func requestSuggestAlbumsSceneSet(_ setupSceneSetCoordinator: SetupSceneSetCoordinator)
}

class SetupSceneSetCoordinator: Coordinator {
    
    //MARK: - Dependencies
    
    let mainContainerViewController: ContainerViewController
    let authStateController: AuthStateController
    let userProfileStateController: UserProfileStateController
    let userSettingsStateController: UserSettingsStateController
    let seedArtistStateController: SeedArtistStateController
    let compositionRoot: CompositionRootProtocol
    
    weak var delegate: SetupSceneSetCoordinatorDelegate?
    
    //MARK: - Children

    //Review
    var childCoordinators = [Any]()
    //review
    
    var activeSceneDelegateProxy: AnyObject?
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(mainContainerViewController: ContainerViewController,
         authStateController: AuthStateController,
         userProfileStateController: UserProfileStateController,
         userSettingsStateController: UserSettingsStateController,
         seedArtistStateController: SeedArtistStateController,
         compositionRoot: CompositionRootProtocol,
         delegate: SetupSceneSetCoordinatorDelegate)
    {
            self.mainContainerViewController = mainContainerViewController
            self.authStateController = authStateController
            self.userProfileStateController = userProfileStateController
            self.userSettingsStateController = userSettingsStateController
            self.seedArtistStateController = seedArtistStateController
            self.compositionRoot = compositionRoot
            self.delegate = delegate
    }
    
    //MARK: - Interface
    
    var containerViewController: UIViewController {
        return mainContainerViewController
    }
    
    func start() {
        let vc = compositionRoot.composeOpenScene(delegate: self)
        mainContainerViewController.show(viewController: vc, animation: .none)
    }
    
    func startAtWelcome() {
        let vc = compositionRoot.composeWelcomeScene(delegate: self)
        mainContainerViewController.show(viewController: vc, animation: .none)
    }
    
}

//MARK: - OpenSceneViewModelDelegate

extension SetupSceneSetCoordinator: OpenSceneViewModelDelegate {
    func sceneComplete(_ openSceneViewModel: OpenSceneViewModel) {
        
        if authStateController.sessionIsValid {
            launchPostAuthenticationScene()
        } else {
            let vc = compositionRoot.composeSpotifyLoginScene()
            
            vc.spotifyConnected = userProfileStateController.spotifyConnected.value
            
            mainContainerViewController.show(viewController: vc, animation: .none)
            
            //Must be set after view controller is added to container. Fix at some point
            vc.cancelButton.isHidden = true
            vc.controllerDelegate = self
        }
    }
    
    //Enter main application once a valid session has been obtained
    func launchPostAuthenticationScene() {

        let instructionsSeen = userSettingsStateController.instructionsSeen.value
        let isSeeded = userSettingsStateController.isSeeded.value
        
        if instructionsSeen && isSeeded {
            delegate?.requestHomeSceneSet(self)
        } else if !instructionsSeen && !isSeeded {
            let vc = compositionRoot.composeWelcomeScene(delegate: self)
            mainContainerViewController.show(viewController: vc, animation: .none)
        } else if instructionsSeen && !isSeeded {
            let vc = self.compositionRoot.composeChooseArtistsScene(delegate: self)
            self.mainContainerViewController.show(viewController: vc, animation: .slideFromRight)
        } else if !instructionsSeen && isSeeded {
            let vc = compositionRoot.composeInstructionsScene(delegate: self)
            mainContainerViewController.show(viewController: vc, animation: .none)
        }
    }
    
}

//MARK: - SpotifyViewControllerDelegate

extension SetupSceneSetCoordinator: SpotifyLoginViewControllerDelegate {
    
    func loginSucceeded() {
        userProfileStateController.setSpotifyConnected(true)
        launchPostAuthenticationScene()
    }
    
    func cancelLogin() {
        //remain on login page
    }
    
}

//MARK: - WelcomeViewModelDelegate

extension SetupSceneSetCoordinator: WelcomeViewModelDelegate {
    
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
                    let vc = self.compositionRoot.composeChooseArtistsScene(delegate: self)
                    self.mainContainerViewController.show(viewController: vc, animation: animated ? .slideFromRight : .none)
                }
            })
            .disposed(by: disposeBag)
    }
    
}

//MARK: - ChooseArtistViewModelDelegate

extension SetupSceneSetCoordinator: ChooseArtistViewModelDelegate {
    
    func chooseArtistSceneComplete(_ chooseArtistViewModel: ChooseArtistViewModel) {
        userSettingsStateController.setIsSeeded(true)
        
        if userSettingsStateController.instructionsSeen.value {
            //launch suggest albums scene
        } else {
            let vc = compositionRoot.composeInstructionsScene(delegate: self)
            mainContainerViewController.show(viewController: vc, animation: .slideFromRight)
        }
        
    }
    
    func showConfirmArtistScene(_ chooseArtistViewModel: ChooseArtistViewModel, confirmationArtist: String) {
        
        let confirmArtistVC = compositionRoot.composeConfirmArtistScene(delegate: self)
        
        //launch spotify confirmation, if necessary
        if !(authStateController.sessionIsValid) {
            let vc = compositionRoot.composeSpotifyLoginScene()
            
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

extension SetupSceneSetCoordinator: ConfirmArtistViewModelDelegate {
    
    func cancel(_ confirmArtistViewModel: ConfirmArtistViewModel) {
        mainContainerViewController.dismissModalVC()
    }
    
}

//MARK: - InstructionsViewModelDelegate

extension SetupSceneSetCoordinator: InstructionsViewModelDelegate {
    
    func requestNextScene(_ instructionsViewModel: InstructionsViewModel) {
        delegate?.requestSuggestAlbumsSceneSet(self)
    }
    
}








