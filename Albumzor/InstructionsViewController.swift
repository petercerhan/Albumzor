//
//  InstructionsViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InstructionsViewController: UIViewController {
    
    //MARK: - Dependencies
    
    private var viewModel: InstructionsViewModel!
    
    //MARK: - Interface Components
    
    @IBOutlet var startButton: UIButton!
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    static func createWith(viewModel: InstructionsViewModel, storyBoard: UIStoryboard) -> InstructionsViewController {
        let vc = storyBoard.instantiateViewController(withIdentifier: "InstructionsViewController") as! InstructionsViewController
        vc.viewModel = viewModel
        
        return vc
    }
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindActions()
    }
    
    //MARK: - Bind Actions
    
    func bindActions() {
        startButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.viewModel.dispatch(action: .requestNextScene)
            })
            .disposed(by: disposeBag)
    }
    
}
