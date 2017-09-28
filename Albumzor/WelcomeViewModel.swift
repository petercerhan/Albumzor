//
//  WelcomeViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/21/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol WelcomeViewModelDelegate: class {
    func requestToChooseArtists(from welcomeViewModel: WelcomeViewModel)
}

enum WelcomeSceneAction {
    case requestChooseArtists
    case networkAlertsDismissed
}

class WelcomeViewModel {
    
    //MARK: - Dependencies
    
    weak var delegate: WelcomeViewModelDelegate?
    let userProfileStateController: UserProfileStateController
    
    private let disposeBag = DisposeBag()
    
    //MARK: - State
    
    let dataLoadStateSubject = BehaviorSubject<DataOperationState>(value: .none)
    
    //MARK: - Initialization
    
    init(delegate: WelcomeViewModelDelegate, userProfileStateController: UserProfileStateController) {
        self.delegate = delegate
        self.userProfileStateController = userProfileStateController
    }

    //MARK: - Dispatch Actions
    
    func dispatch(action: WelcomeSceneAction) {
        switch action {
        case .requestChooseArtists:
            handleRequestChooseArtistsAction()
        case .networkAlertsDismissed:
            handleNetworkAlertsDismissedAction()
        }
    }
    
    private func handleRequestChooseArtistsAction() {
        dataLoadStateSubject.onNext(.operationBegan)
        
        if userProfileStateController.userMarket.value == "None" {
            userProfileStateController.fetchUserMarketFromAPI()
                .subscribe(onError: { error in
                    self.dataLoadStateSubject.onNext(.error)
                }, onCompleted: {
                    self.dataLoadStateSubject.onNext(.operationCompleted)
                })
                .disposed(by: disposeBag)
        } else {
            delegate?.requestToChooseArtists(from: self)
        }
    }
    
    private func handleNetworkAlertsDismissedAction() {
        dataLoadStateSubject.onNext(.none)
    }
}

