//
//  MainContainerCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

//Temporary
import MediaPlayer
import GameKit

class MainContainerCoordinator {
    
    //MARK: - Dependencies
    
    let mainContainerViewController: ContainerViewController
    let authStateController: AuthStateController
    let userProfileStateController: UserProfileStateController
    let userSettingsStateController: UserSettingsStateController
    let seedArtistStateController: SeedArtistStateController
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
         compositionRoot: CompositionRootProtocol)
    {
            self.mainContainerViewController = mainContainerViewController
            self.authStateController = authStateController
            self.userProfileStateController = userProfileStateController
            self.userSettingsStateController = userSettingsStateController
            self.seedArtistStateController = seedArtistStateController
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
        
//        print("\n\nInstructionsSeen: \(userSettingsStateController.instructionsSeen()) \nIsSeeded: \(userSettingsStateController.isSeeded()) \nAutoplay: \(userSettingsStateController.isAutoplayEnabled()) \nAlbumSortType: \(userSettingsStateController.getAlbumSortType())")
        
        let instructionsSeen = userSettingsStateController.instructionsSeen.value
        let isSeeded = userSettingsStateController.isSeeded.value
        
        if instructionsSeen && isSeeded {
            //Launch Home Scene
        } else if !instructionsSeen && !isSeeded {
            //Launch welcome scene
            let vc = compositionRoot.composeWelcomeScene(mainContainerCoordinator: self, userProfileStateController: userProfileStateController)
            mainContainerViewController.show(viewController: vc, animation: .none)
            
        } else if instructionsSeen && !isSeeded {
            //launch Seed Artists scene
        } else if !instructionsSeen && isSeeded {
            //launch Instructions Scene
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
            //launch 
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

extension MainContainerCoordinator: ConfirmArtistViewModelDelegate {
    
    func cancel(_ confirmArtistViewModel: ConfirmArtistViewModel) {
        mainContainerViewController.dismissModalVC()
    }
    
}











