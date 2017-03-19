//
//  AlbumsContainerViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class AlbumsContainerViewController: UIViewController {

    private var contentViewController: UIViewController
    let appStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    init() {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "PrepareAlbumsViewController") as! PrepareAlbumsViewController
        contentViewController = vc
        super.init(nibName: nil, bundle: nil)
        vc.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
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

extension AlbumsContainerViewController: PrepareAlbumsViewControllerDelegate {
    func launchAlbumView(albums: [Album], albumArt: [UIImage]) {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "AlbumsViewController") as! AlbumsViewController
        vc.albums = albums
        vc.albumArt = albumArt
        vc.delegate = self
        update(contentViewController: vc)
    }
}

extension AlbumsContainerViewController: AlbumsViewControllerDelegate {
    func quit() {
        dismiss(animated: true, completion: nil)
    }
    
    func batteryComplete() {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "NextStepViewController") as! NextStepViewController
        vc.delegate = self
        update(contentViewController: vc)
    }
}

extension AlbumsContainerViewController: NextStepViewControllerDelegate {
    func nextBattery() {
        let vc = appStoryboard.instantiateViewController(withIdentifier: "PrepareAlbumsViewController") as! PrepareAlbumsViewController
        vc.delegate = self
        update(contentViewController: vc)
    }
}
