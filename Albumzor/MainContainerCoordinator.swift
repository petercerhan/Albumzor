//
//  MainContainerCoordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class MainContainerCoordinator {
    
    //MARK: - Dependencies
    
    let mainContainerViewController: ContainerViewController
    let compositionRoot: CompositionRootProtocol
    
    //MARK: - Children
    
    var childCoordinators = [Any]()
    
    //MARK: - Initialization
    
    init(containerViewController: ContainerViewController, compositionRoot: CompositionRootProtocol) {
        mainContainerViewController = containerViewController
        self.compositionRoot = compositionRoot
    }
    
    func start() {
        //Fix this next
        let appStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = appStoryboard.instantiateViewController(withIdentifier: "OpenSceneViewController") as! OpenSceneViewController
        vc.delegate = self
        mainContainerViewController.show(viewController: vc, animation: .none)
    }
    
}

extension MainContainerCoordinator: OpenSceneViewControllerDelegate {
    func openingSceneComplete() {
        print("Open Scene Complete")
    }
}
