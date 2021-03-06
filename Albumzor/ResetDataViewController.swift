//
//  ResetDataViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/26/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//REMOVE
enum ResetDataAction {
    case reset, reseed
}

protocol ResetDataViewControllerDelegate: NSObjectProtocol {
    func resetSucceeded()
    func resetFailed()
}
//remove


class ResetDataViewController: UIViewController {
    
    //MARK: - Interface Components
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Dependencies
    
    private var viewModel: ResetDataViewModel!
    
    //MARK: - Initialization
    
    static func createWith(storyBoard: UIStoryboard, viewModel: ResetDataViewModel) -> ResetDataViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "ResetDataViewController") as! ResetDataViewController
        vc.viewModel = viewModel
        return vc
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindUI()
        bindActions()
    }
    
    private func bindUI() {
        viewModel.resetOperationState
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .operationBegan:
                    self.activityIndicator.startAnimating()
                default:
                    self.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindActions() {
        //bind reset button
        resetButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.dispatch(action: .resetData)
            })
            .disposed(by: disposeBag)
        
        //bind cancel button
        cancelButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.dispatch(action: .cancel)
            })
            .disposed(by: disposeBag)
    }

}

