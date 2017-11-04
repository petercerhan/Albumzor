//
//  SuggestAlbumsSceneSetCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/2/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol SuggestAlbumsSceneSetCoordinatorDelegate: class {
    func requestCompleteSceneSet(_ suggestAlbumsSceneSetCoordinator: SuggestAlbumsSceneSetCoordinator)
}

class SuggestAlbumsSceneSetCoordinator: Coordinator {
   
    //MARK: - Dependencies
    
    fileprivate let containerVC: ContainerViewController
    fileprivate let compositionRoot: CompositionRoot
    fileprivate weak var delegate: SuggestAlbumsSceneSetCoordinatorDelegate?
    
    //MARK: - Children
    
    fileprivate var childCoordinator: Coordinator?
    
    //MARK: - Initialization
    
    init(containerViewController: ContainerViewController, compositionRoot: CompositionRoot, delegate: SuggestAlbumsSceneSetCoordinatorDelegate) {
        self.containerVC = containerViewController
        self.compositionRoot = compositionRoot
        self.delegate = delegate
    }
    
    //MARK: - Interface
    
    var containerViewController: UIViewController {
        return containerVC
    }
    
    func start() {
        let vc = compositionRoot.composeSuggestAlbumsScene(delegate: self)
        containerVC.show(viewController: vc, animation: .none)
    }
}

extension SuggestAlbumsSceneSetCoordinator: SuggestAlbumsViewModelDelegate {
    
    func suggestAlbumsSceneComplete(_ suggestAlbumsViewModel: SuggestAlbumsViewModel) {
        delegate?.requestCompleteSceneSet(self)
        print("suggest album scene complete")
    }
    
    func showAlbumDetails(_ suggestArtistViewModel: SuggestAlbumsViewModel) {
        print("Show album details")
        
        let vc = compositionRoot.composeAlbumsDetailsScene(delegate: self)
        containerVC.showModally(viewController: vc)
    }
    
}


//MARK: - AlbumDetailsViewModelDelegate

extension SuggestAlbumsSceneSetCoordinator: AlbumDetailsViewModelDelegate {
    
    func dismiss(_ albumDetailsViewModel: AlbumDetailsViewModel) {
        containerVC.dismissModalVC()
    }
    
}



