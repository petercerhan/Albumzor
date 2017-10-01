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
        
        if userSettingsStateController.instructionsSeen() && userSettingsStateController.isSeeded() {
            //Launch Home Scene
        } else if !(userSettingsStateController.instructionsSeen()) && !(userSettingsStateController.isSeeded()) {
            //Launch welcome scene
            let vc = compositionRoot.composeWelcomeScene(mainContainerCoordinator: self, userProfileStateController: userProfileStateController)
            mainContainerViewController.show(viewController: vc, animation: .none)
            
        } else if userSettingsStateController.instructionsSeen() && !userSettingsStateController.isSeeded() {
            //launch Seed Artists scene
        } else if !userSettingsStateController.instructionsSeen() && userSettingsStateController.isSeeded() {
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

//MARK: - WelcomeViewControllerDelegate

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
            .subscribe(onNext: { [unowned self] artists in
                if artists.count > 0 {
                    let vc = self.compositionRoot.composeChooseArtistsScene(mainContainerCoordinator: self, seedArtistStateController: self.seedArtistStateController)
            
                    self.mainContainerViewController.show(viewController: vc, animation: animated ? .slideFromRight : .none)
                }
            })
            .disposed(by: disposeBag)
    }
    
}


//MARK: - ChooseArtistViewControllerDelegate
//TODO: Deletes ChooseArtistViewControllerDelegate

extension MainContainerCoordinator: ChooseArtistViewControllerDelegate, ChooseArtistViewModelDelegate {
    func chooseArtistSceneComplete() {
        print("Choose artists scene complete")
    }
    
    func chooseArtistSceneComplete(_ chooseArtistViewModel: ChooseArtistViewModel) {
        print("Choose artists scene complete")
    }
    
    func showConfirmArtistScene(_ chooseArtistViewModel: ChooseArtistViewModel, confirmationArtist: String) {
        print("Launch confirm artist scene with \(confirmationArtist)")
        
        let viewModel = ConfirmArtistViewModel(seedArtistStateController: seedArtistStateController)
        let vc = ConfirmArtistViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel, searchString: confirmationArtist, searchOrigin: .search)
        vc.delegate = self
        
        mainContainerViewController.showModally(viewController: vc)
    }
}


//MARK: - ConfirmArtistViewControllerDelegate

extension MainContainerCoordinator: ConfirmArtistViewControllerDelegate {
    
    func artistChosen(spotifyID: String, searchOrigin: ArtistSearchOrigin) {
        print("Artist chosen")
    }
    
    func artistCanceled() {
        print("Artist canceled")
    }
    
}












