//
//  NavigationContainerViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class NavigationContainerViewController: ContainerViewController {
    
    var navController: UINavigationController!
    
    func setRootViewController(_ rootVC: UIViewController) {
        navController = UINavigationController(rootViewController: rootVC)
        show(viewController: navController, animation: .none)
    }
    
    func push(viewController: UIViewController, animated: Bool) {
        navController.pushViewController(viewController, animated: animated)
    }
    
    func pop(animated: Bool) {
        navController.popViewController(animated: animated)
    }
    
    
}
