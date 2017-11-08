//
//  HomeSceneSetCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol HomeSceneSetCoordinatorDelegate: class {
    func dataReset()
}

class HomeSceneSetCoordinator: Coordinator {
    
    //MARK: - Dependencies
    
    fileprivate let containerVC: NavigationContainerViewController
    fileprivate let compositionRoot: CompositionRoot
    fileprivate let likedAlbumsStateController: LikedAlbumsStateController
    fileprivate weak var delegate: HomeSceneSetCoordinatorDelegate?
    
    //MARK: - Children
    
    fileprivate var childCoordinator: Coordinator?
    
    //MARK: - Rx
    
    fileprivate let disposeBag = DisposeBag()
    
    //Mark: - Initialization
    
    init(containerViewController: NavigationContainerViewController,
         compositionRoot: CompositionRoot,
         likedAlbumsStateController: LikedAlbumsStateController,
         delegate: HomeSceneSetCoordinatorDelegate)
    {
        self.containerVC = containerViewController
        self.compositionRoot = compositionRoot
        self.likedAlbumsStateController = likedAlbumsStateController
        self.delegate = delegate
    }
    
    //MARK: - Interface
    
    var containerViewController: UIViewController {
        return containerVC
    }
    
    func start() {
        
    }
    
    func startWithSuggestAlbumsActive() {
        let homeVC = compositionRoot.composeHomeScene(delegate: self)
        containerVC.setRootViewController(homeVC)
        
        let suggestAlbumsSceneSetCoordinator = compositionRoot.composeSuggestAlbumsSceneSetCoordinator(delegate: self)
        suggestAlbumsSceneSetCoordinator.start()
        containerVC.showModally(viewController: suggestAlbumsSceneSetCoordinator.containerViewController, animation: .none)
        
        childCoordinator = suggestAlbumsSceneSetCoordinator
    }
    
}

//MARK: - SuggestAlbumsSceneSetCoordinatorDelegate

extension HomeSceneSetCoordinator: SuggestAlbumsSceneSetCoordinatorDelegate {
    
    func requestCompleteSceneSet(_ suggestAlbumsSceneSetCoordinator: SuggestAlbumsSceneSetCoordinator) {
        likedAlbumsStateController.refreshLikedAlbums()
        containerVC.dismissModalVC()
        childCoordinator = nil
    }
    
}

//MARK: - HomeViewModelDelegate

extension HomeSceneSetCoordinator: HomeViewModelDelegate {
    
    func requestMenuScene(_ homeViewModel: HomeViewModel) {
        
        let vc = compositionRoot.composeMenuScene(delegate: self)
        
        containerVC.push(viewController: vc, animated: true)
    }
    
    func requestSuggestAlbumsScene(_ homeViewModel: HomeViewModel) {
        let suggestAlbumsSceneSetCoordinator = compositionRoot.composeSuggestAlbumsSceneSetCoordinator(delegate: self)
        suggestAlbumsSceneSetCoordinator.start()
        containerVC.showModally(viewController: suggestAlbumsSceneSetCoordinator.containerViewController)
        childCoordinator = suggestAlbumsSceneSetCoordinator
    }
    
    func requestDetailsScene(_ homeViewModel: HomeViewModel) {
        let vc = compositionRoot.composeAlbumDetailsScene_FromHome(delegate: self)
        containerVC.showModally(viewController: vc)
    }
    
}

//MARK: - AlbumDetailsViewModelDelegate

extension HomeSceneSetCoordinator: AlbumDetailsViewModelDelegate {
    
    func dismiss(_ albumDetailsViewModel: AlbumDetailsViewModel) {
        likedAlbumsStateController.setDetailsInactive()
        containerVC.dismissModalVC()
    }
    
}

//MARK: - MenuViewModelDelegate

extension HomeSceneSetCoordinator: MenuViewModelDelegate {
    
    func requestSortOptionsScene(_ menuViewModel: MenuViewModel) {
        let vc = compositionRoot.composeSortOptionsScene(delegate: self)
        containerVC.push(viewController: vc, animated: true)
    }
    
    func requestResetDataScene(_ menuViewModel: MenuViewModel) {
        let vc = compositionRoot.composeResetDataScene(delegate: self)
        containerVC.showModally(viewController: vc)
    }
    
}

//MARK: - SortOptionsViewModelDelegate

extension HomeSceneSetCoordinator: SortOptionsViewModelDelegate {
    
}

//MARK: - ResetDataViewModelDelegate

extension HomeSceneSetCoordinator: ResetDataViewModelDelegate {

    func cancel(_ resetDataViewModel: ResetDataViewModel) {
        containerVC.dismissModalVC()
    }
    
    
    func dataReset(_ resetDataViewModel: ResetDataViewModel) {
        delegate?.dataReset()
    }

}



