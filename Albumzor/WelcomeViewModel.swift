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
}

class WelcomeViewModel {
    
    //MARK: - Dependencies
    
    weak var delegate: WelcomeViewModelDelegate?
    let userProfileStateController: UserProfileStateController
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(delegate: WelcomeViewModelDelegate, userProfileStateController: UserProfileStateController) {
        self.delegate = delegate
        self.userProfileStateController = userProfileStateController

        //TODO:  (Dev) Reset Profile State Controller
        userProfileStateController.reset()
    }

    //MARK: - Dispatch actions
    
    func dispatch(action: WelcomeSceneAction) {
        switch action {
        case .requestChooseArtists:
            handleRequestChooseArtistsAction()
        }
    }
    
    private func handleRequestChooseArtistsAction() {
        if userProfileStateController.userMarket.value == "None" {
            let infoObservable = userProfileStateController.fetchUserMarketFromAPI()
            
            infoObservable.subscribe(onError: { error in
                print("An error has occurred")
            }, onCompleted: {
                print("Networking process completed")
            })
            .disposed(by: disposeBag)
            
        } else {
            delegate?.requestToChooseArtists(from: self)
        }
    }
}
