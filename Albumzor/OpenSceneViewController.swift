//
//  OpenSceneViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/21/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class OpenSceneViewController: UIViewController {

    //MARK: - Dependencies
    
    var viewModel: OpenSceneViewModel!
    
    //MARK: - Interface Components
    
    @IBOutlet var recordImage: UIImageView!
    @IBOutlet var imageXCenterContraint: NSLayoutConstraint!

    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: OpenSceneViewModel) -> OpenSceneViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "OpenSceneViewController") as! OpenSceneViewController
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageXCenterContraint.constant = self.view.frame.width
        
        UIView.animate(withDuration: 0.4,
                       delay: 0.5,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
        },
                       completion: {_ in self.nextScene()})
    }
    
    //MARK: - Actions
    
    func nextScene() {
        viewModel.dispatch(action: .sceneComplete)
    }

}
