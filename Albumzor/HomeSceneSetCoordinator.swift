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
    
    fileprivate let containerVC: NavigationContainerViewController
    fileprivate let compositionRoot: CompositionRoot
    fileprivate weak var delegate: HomeSceneSetCoordinatorDelegate?
    
    //MARK: - Children
    
    fileprivate var childCoordinator: Coordinator?
    
    //Mark: - Initialization
    
    init(containerViewController: NavigationContainerViewController,
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
        let homeVC = compositionRoot.composeHomeScene(delegate: self)
        containerVC.setRootViewController(homeVC)
        
        let suggestAlbumsSceneSetCoordinator = compositionRoot.composeSuggestAlbumsSceneSetCoordinator(delegate: self)
        suggestAlbumsSceneSetCoordinator.start()
        containerVC.showModally(viewController: suggestAlbumsSceneSetCoordinator.containerViewController, animation: .none)
        
        childCoordinator = suggestAlbumsSceneSetCoordinator
    }
    
}

extension HomeSceneSetCoordinator: SuggestAlbumsSceneSetCoordinatorDelegate {
    
    func requestCompleteSceneSet(_ suggestAlbumsSceneSetCoordinator: SuggestAlbumsSceneSetCoordinator) {
        containerVC.dismissModalVC()
        childCoordinator = nil
    }
    
}

extension HomeSceneSetCoordinator: HomeViewModelDelegate {
    
    func requestMenuScene(_ homeViewModel: HomeViewModel) {
        
        //Move to composition root
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuTableViewController") as! MenuTableViewController
        //
        
//        vc.menuDelegate = self
//        navigationController?.pushViewController(vc, animated: true)
        
        containerVC.push(viewController: vc, animated: true)
        
    }
    
}

