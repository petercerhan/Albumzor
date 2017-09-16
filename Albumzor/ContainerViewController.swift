//
//  ContainerViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    private var contentViewController = UIViewController()
    
    var hideStatusBar = false
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentViewController.view)
    }
    
    func show(viewController newViewController: UIViewController, animation: ContainerAnimation) {
        
        let priorViewController = contentViewController
        
        contentViewController = newViewController
        
        addChildViewController(newViewController)
        
        newViewController.view.frame = view.bounds
        newViewController.view.alpha = 0
        view.addSubview(newViewController.view)
        
        priorViewController.willMove(toParentViewController: nil)
        newViewController.didMove(toParentViewController: self)
        
        animateTransition(newViewController: newViewController, priorViewController: priorViewController, animation: animation) {
            priorViewController.view.removeFromSuperview()
            priorViewController.removeFromParentViewController()
        }
        
    }
    
    fileprivate func animateTransition(newViewController: UIViewController, priorViewController: UIViewController, animation: ContainerAnimation, completion: ( () -> Void )? ) {
        
        switch animation {
        case .none:
            noAnimation(newViewController: newViewController, priorViewController: priorViewController, completion: completion)
        case .slideFromRight:
            slideFromRight(newViewController: newViewController, priorViewController: priorViewController, completion: completion)
        case .fadeIn:
            fadeIn(newViewController: newViewController, priorViewController: priorViewController, completion: completion)
        }
    }
    
    fileprivate func remove(priorViewController: UIViewController) {
        priorViewController.view.removeFromSuperview()
        priorViewController.removeFromParentViewController()
    }
}

//MARK: - Animations

extension ContainerViewController {
    
    fileprivate func noAnimation(newViewController: UIViewController, priorViewController: UIViewController, completion: ( () -> Void )? ) {
        newViewController.view.alpha = 1
        
        completion?()
    }
    
    fileprivate func slideFromRight(newViewController: UIViewController, priorViewController: UIViewController, completion: ( () -> Void )? ) {
        newViewController.view.center.x += view.frame.width
        newViewController.view.alpha = 1
        
        UIView.animate(withDuration: 0.3, animations: {
            _ in
            newViewController.view.center.x -= self.view.frame.width
            priorViewController.view.center.x -= self.view.frame.width
        }, completion:{
            _ in
            completion?()
        })
    }
    
    fileprivate func fadeIn(newViewController: UIViewController, priorViewController: UIViewController, completion: ( () -> Void )? ) {
        UIView.animate(withDuration: 0.3, animations: {
            _ in
            newViewController.view.alpha = 1
        }, completion:{
            _ in
            completion?()
        })
    }
    
}

//MARK: - Enumerate animations

enum ContainerAnimation {
    case none
    case slideFromRight
    case fadeIn
}

