//
//  OpenSceneViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/21/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class OpenSceneViewController: UIViewController {

    @IBOutlet var recordImage: UIImageView!
    
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
                       completion: {_ in self.launch()})
    }
    
    func launch() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "HomeNavController")
        present(vc, animated: false) {
            self.recordImage.center.x -= self.view.frame.width
        }
    }

}
