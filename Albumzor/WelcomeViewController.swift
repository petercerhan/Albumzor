//
//  WelcomeViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import MediaPlayer

class WelcomeViewController: UIViewController {
    
    //MARK: - IB Components
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    //MARK: - Dependencies
    
    var viewModel: WelcomeViewModel!
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: WelcomeViewModel) -> WelcomeViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: = Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prompt app to ask for permission to use iTunes library
        //Extract this dependency
        _ = MPMediaQuery.artists()
    }
    
    //MARK: - Received User Actions
    
    @IBAction func chooseArtists() {
        //move to observable
        ui(setLoading: true)
        
        viewModel.dispatch(action: .requestChooseArtists)
    }
    
    //move to user profile state controller
    func getUserMarket() {
        //inject into state controller
//        let client = SpotifyClient.sharedInstance()
        
//        client.getUserInfo() { result, error in
//            
//            if let _ = error {
//                DispatchQueue.main.async {
//                    self.ui(setLoading: false)
//                    self.networkingError()
//                }
//            } else {
//                guard let result = result as? [String : AnyObject], let market = result["country"] as? String else {
//                    DispatchQueue.main.async {
//                        self.ui(setLoading: false)
//                        self.networkingError()
//                    }
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    self.appDelegate.userProfile.userMarket = market
//                    self.appDelegate.saveUserProfile()
//                    self.viewModel.dispatch(action: .requestChooseArtists)
//                }
//            }
//            
//        }
    }
    
    func networkingError() {
        alert(title: "Network Error", message: "Please check your internet connection", buttonTitle: "Dismiss")
    }
    
    func ui(setLoading isLoading: Bool) {
        if isLoading {
            titleLabel.alpha = 0.6
            messageLabel.alpha = 0.6
            doneButton.alpha = 0.6
            doneButton.isEnabled = false
            activityIndicator.startAnimating()
        } else {
            titleLabel.alpha = 1.0
            messageLabel.alpha = 1.0
            doneButton.alpha = 1.0
            doneButton.isEnabled = true
            activityIndicator.stopAnimating()
        }
    }
    
}
