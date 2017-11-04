//
//  ContainerViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var contentViewController = UIViewController()
    
    var hideStatusBar = false
    var modallyPresentingViewController: UIViewController?
    
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
        newViewController.view.alpha = 0 //Default before animation
        view.addSubview(newViewController.view)
        
        priorViewController.willMove(toParentViewController: nil)
        newViewController.didMove(toParentViewController: self)
        
        animateTransition(newViewController: newViewController, priorViewController: priorViewController, animation: animation) {
            priorViewController.view.removeFromSuperview()
            priorViewController.removeFromParentViewController()
        }
        
    }
    
    func showModally(viewController newViewController: UIViewController, animation: ContainerAnimation = .modalPresentation) {
        
        let priorViewController = contentViewController
        contentViewController = newViewController
        
        newViewController.view.frame = view.bounds
        newViewController.view.alpha = 0
        view.addSubview(newViewController.view)
        
//        priorViewController.willMove(toParentViewController: nil)
        newViewController.didMove(toParentViewController: self)
        
        animateTransition(newViewController: newViewController, priorViewController: priorViewController, animation: animation) {
//            priorViewController.view.removeFromSuperview()
//            priorViewController.removeFromParentViewController()
        }
        
        modallyPresentingViewController = priorViewController
    }
    
    func dismissModalVC(animation: ContainerAnimation = .none) {
        
        guard let newViewController = modallyPresentingViewController else { return }
        
        let priorViewController = contentViewController
        contentViewController = newViewController
        
//        newViewController.view.frame = view.bounds
//        view.addSubview(newViewController.view)
        
        priorViewController.willMove(toParentViewController: nil)
//        newViewController.didMove(toParentViewController: self)
        
        dismissModalAnimation(presentingViewController: contentViewController, presentedViewController: priorViewController) { [weak self] in
            priorViewController.view.removeFromSuperview()
            priorViewController.removeFromParentViewController()
            self?.modallyPresentingViewController = nil
        }
    }
    
    
    
    func showModalWithPresenter(modalViewController: UIViewController, presentingViewController: UIViewController, animation: ContainerAnimation = .none) {
        
        let priorViewController = contentViewController
        contentViewController = modalViewController

        addChildViewController(modalViewController)
        
        modalViewController.view.frame = view.bounds
        modalViewController.view.alpha = 0
        view.addSubview(modalViewController.view)
        
        priorViewController.willMove(toParentViewController: nil)
        modalViewController.didMove(toParentViewController: self)
        
        animateTransition(newViewController: modalViewController, priorViewController: priorViewController, animation: animation) {
            priorViewController.view.removeFromSuperview()
            priorViewController.removeFromParentViewController()
            
        }
        
        presentingViewController.view.frame = view.bounds
        presentingViewController.view.alpha = 1
        view.insertSubview(presentingViewController.view, belowSubview: modalViewController.view)
        presentingViewController.didMove(toParentViewController: self)
        
        modallyPresentingViewController = presentingViewController
    }
    
    
    
    func replaceModalVC(viewController newViewController: UIViewController, animation: ContainerAnimation = .none) {
        
        guard modallyPresentingViewController != nil else { return }
        
        let priorViewController = contentViewController
        contentViewController = newViewController
        
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
        case .modalPresentation:
            presentModally(newViewController: newViewController, priorViewController: priorViewController, completion: completion)
        }
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
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                            _ in
                            newViewController.view.alpha = 1
                        }, completion:{
                            _ in
                            completion?()
                        })
    }
    
    fileprivate func presentModally(newViewController: UIViewController, priorViewController: UIViewController, completion: ( () -> Void )? ) {
        newViewController.view.center.y += view.frame.height
        newViewController.view.alpha = 1
        
        UIView.animate(withDuration: 0.3, animations: {
            _ in
            newViewController.view.center.y -= self.view.frame.height
        }, completion:{
            _ in
            completion?()
        })
    }
    
    fileprivate func dismissModalAnimation(presentingViewController: UIViewController, presentedViewController: UIViewController, completion: ( () -> Void )? ) {
        UIView.animate(withDuration: 0.3, animations: {
            _ in
            presentedViewController.view.center.y += self.view.frame.height
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
    case modalPresentation
}

