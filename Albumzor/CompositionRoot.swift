//
//  CompositionRoot.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import UIKit

protocol CompositionRootProtocol {
    func composeWindow() -> UIWindow
    func composeMainCoordinator() -> MainContainerCoordinator
    func composeOpenScene(mainContainerCoordinator: MainContainerCoordinator) -> OpenSceneViewController
}

class CompositionRoot: CompositionRootProtocol {
    
    func composeWindow() -> UIWindow {
        return UIWindow(frame: UIScreen.main.bounds)
    }
    
    func composeMainCoordinator() -> MainContainerCoordinator {
        return MainContainerCoordinator(mainContainerViewController: ContainerViewController(), compositionRoot: self)
    }
    
    func composeOpenScene(mainContainerCoordinator: MainContainerCoordinator) -> OpenSceneViewController {
        let viewModel = OpenSceneViewModel(delegate: mainContainerCoordinator)
        return OpenSceneViewController.createWith(storyBoard: UIStoryboard(name: "Main", bundle: nil), viewModel: viewModel)
    }
}

