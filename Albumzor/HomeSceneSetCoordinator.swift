//
//  HomeSceneSetCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol HomeSceneSetCoordinatorDelegate: class {
    
}

class HomeSceneSetCoordinator: Coordinator {
    
    //MARK: - Dependencies
    
    fileprivate let containerVC: ContainerViewController
    fileprivate let compositionRoot: CompositionRoot
    fileprivate weak var delegate: HomeSceneSetCoordinatorDelegate?
    
    //MARK: - Children
    
    fileprivate var childCoordinator: Coordinator?
    
    //Mark: - Initialization
    
    init(containerViewController: ContainerViewController,
         compositionRoot: CompositionRoot,
         delegate: HomeSceneSetCoordinatorDelegate)
    {
        self.containerVC = containerViewController
        self.compositionRoot = compositionRoot
        self.delegate = delegate
    }
    
    //MARK: - Interface
    
    var containerViewController: UIViewController {
        return containerVC
    }
    
    func start() {
        
    }
    
    func startWithSuggestAlbumsActive() {
        
        //Move to composition root
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        //
        
        let suggestAlbumsSceneSetCoordinator = compositionRoot.composeSuggestAlbumsSceneSetCoordinator(delegate: self)
        
        containerVC.showModalWithPresenter(modalViewController: suggestAlbumsSceneSetCoordinator.containerViewController, presentingViewController: homeVC)
        suggestAlbumsSceneSetCoordinator.start()
        childCoordinator = suggestAlbumsSceneSetCoordinator
    }
    
}

extension HomeSceneSetCoordinator: SuggestAlbumsSceneSetCoordinatorDelegate {
    
    func requestCompleteSceneSet(_ suggestAlbumsSceneSetCoordinator: SuggestAlbumsSceneSetCoordinator) {
        containerVC.dismissModalVC()
        childCoordinator = nil
    }
    
}

