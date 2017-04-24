//
//  MainContainerViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class MainContainerViewController: UIViewController {
    
    private var contentViewController: UIViewController
    let appStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    init() {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "OpenSceneViewController") as! OpenSceneViewController
        contentViewController = vc
        super.init(nibName: nil, bundle: nil)
        vc.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        //Never instantiated from resource file
        contentViewController = UIViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentViewController.view)
    }
    
    func update(contentViewController newViewController: UIViewController) {
        
        let priorViewController = contentViewController
        
        contentViewController = newViewController
        
        addChildViewController(newViewController)
        
        newViewController.view.frame = view.bounds
        view.addSubview(newViewController.view)
        
        priorViewController.willMove(toParentViewController: nil)
        newViewController.didMove(toParentViewController: self)
        
        priorViewController.view.removeFromSuperview()
        priorViewController.removeFromParentViewController()
    }
    
}

extension MainContainerViewController: OpenSceneViewControllerDelegate {
    func nextScene() {
        //determine whether the app is currently seeded here
        let vc = appStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        vc.delegate = self
        update(contentViewController: vc)
    }
}

extension MainContainerViewController: WelcomeViewControllerDelegate {
    func chooseArtists() {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "ChooseArtistViewController")
        update(contentViewController: vc)
    }
}


