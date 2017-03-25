//
//  SearchArtistViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit


class SearchArtistViewController: UIViewController {
    
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func home() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func search() {
        if textField.text! == "" {
            return
        }
        
        set(uiEnabled: false)
        activityIndicator.startAnimating()
        
        DataManager().addArtist(searchString: textField.text!) { error in
            if let error = error {
                print("error \(error)")
            } else {
                print("success")
            }
            DispatchQueue.main.async {
                self.set(uiEnabled: true)
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func set(uiEnabled enabled: Bool) {
        searchButton.isEnabled = enabled
        homeButton.isEnabled = enabled
        textField.isEnabled = enabled
        if !enabled {
            textField.resignFirstResponder()
        }
    }
        
}

extension SearchArtistViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("\(textField.text!)")
        return true
    }
    
    
}
