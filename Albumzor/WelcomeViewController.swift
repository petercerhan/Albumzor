//
//  WelcomeViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import MediaPlayer
import RxSwift

class WelcomeViewController: UIViewController {
    
    //MARK: - Dependencies
    
    var viewModel: WelcomeViewModel!
    
    //MARK: - IB Components
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: WelcomeViewModel) -> WelcomeViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        vc.viewModel = viewModel
        vc.bindViewModel()
        return vc
    }
    
    private func bindViewModel() {
        viewModel.dataLoadStateSubject.observeOn(MainScheduler.instance)
            .subscribe(onNext: { state in
                switch state {
                case .none:
                    break
                case .operationBegan:
                    self.ui(setLoading: true)
                case .operationCompleted:
                    self.ui(setLoading: false)
                case .error:
                    self.ui(setLoading: false)
                    self.networkingError()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
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
        viewModel.dispatch(action: .requestChooseArtists)
    }
    
    func networkingError() {
        //TODO: make sure this isn't a retain cycle
        alert(title: "Network Error", message: "Please check your internet connection", buttonTitle: "Dismiss") { action in
            self.viewModel.dispatch(action: .networkAlertsDismissed)
        }
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
