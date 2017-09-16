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
    
    let mainContainerViewController: MainContainerViewController
    let compositionRoot: CompositionRootProtocol
    
    //MARK: - Children
    
    var childCoordinators = [Any]()
    
    //MARK: - Initialization
    
    init(containerViewController: MainContainerViewController, compositionRoot: CompositionRootProtocol) {
        mainContainerViewController = containerViewController
        self.compositionRoot = compositionRoot
    }
    
    func start() {
        
    }
    
}
