//
//  UIViewController+Alerts.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alert(title: String?, message: String, buttonTitle: String, buttonAction: ((UIAlertAction) -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: buttonTitle, style: .default, handler: buttonAction)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
}
