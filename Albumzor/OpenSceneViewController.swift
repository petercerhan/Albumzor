//
//  OpenSceneViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/21/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol OpenSceneViewControllerDelegate: class {
    func openingSceneComplete()
}

class OpenSceneViewController: UIViewController {

    //MARK: - Dependencies
    
    var viewModel: OpenSceneViewModel!
    weak var delegate: OpenSceneViewControllerDelegate?
    
    //MARK: - Interface Builder Components
    
    @IBOutlet var recordImage: UIImageView!

    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: OpenSceneViewModel, delegate: OpenSceneViewControllerDelegate) -> OpenSceneViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "OpenSceneViewController") as! OpenSceneViewController
        vc.viewModel = viewModel
        vc.delegate = delegate
        return vc
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordImage.translatesAutoresizingMaskIntoConstraints = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 0.4,
                       delay: 0.5,
                       options: .curveEaseOut,
                       animations: {
                        self.recordImage.center.x += self.view.frame.width
        },
                       completion: {_ in self.nextScene()})
    }
    
    func nextScene() {
        delegate?.openingSceneComplete()
    }

}
