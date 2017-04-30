//
//  OpenSceneViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/21/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol OpenSceneViewControllerDelegate {
    func openingSceneComplete()
}

class OpenSceneViewController: UIViewController {

    @IBOutlet var recordImage: UIImageView!
    
    var delegate: OpenSceneViewControllerDelegate?
    
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
