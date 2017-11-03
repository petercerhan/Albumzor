//
//  RootCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/2/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class RootCoordinator: Coordinator {
    
    //MARK: - Dependencies
    
    fileprivate let containerVC: ContainerViewController
    fileprivate let compositionRoot: CompositionRoot
    
    //MARK: - Children
    
    fileprivate var childCoordinator: Coordinator?
    
    //MARK: - Initialization
    
    init(containerViewController: ContainerViewController, compositionRoot: CompositionRoot) {
        self.containerVC = containerViewController
        self.compositionRoot = compositionRoot
    }
    
    //MARK: - Interface
    
    var containerViewController: UIViewController {
        return containerVC
    }
    
    func start() {
        let setupSceneSetCoordinator = compositionRoot.composeSetupSceneSetCoordinator()
        containerVC.show(viewController: setupSceneSetCoordinator.containerViewController, animation: .none)
        setupSceneSetCoordinator.start()
        childCoordinator = setupSceneSetCoordinator
    }
    
}



