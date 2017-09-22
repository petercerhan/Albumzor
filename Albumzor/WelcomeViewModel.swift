//
//  WelcomeViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/21/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol WelcomeViewModelDelegate: class {
    func requestToChooseArtists(from welcomeViewModel: WelcomeViewModel)
}

enum WelcomeSceneAction {
    case requestChooseArtists
}

class WelcomeViewModel {
    
    weak var delegate: WelcomeViewModelDelegate?
    
    init(delegate: WelcomeViewModelDelegate) {
        self.delegate = delegate
    }
    
    func chooseArtists() {
        delegate?.requestToChooseArtists(from: self)
    }
    
    func dispatch(action: WelcomeSceneAction) {
        switch action {
        case .requestChooseArtists:
            handleRequestChooseArtistsAction()
        }
    }
    
    func handleRequestChooseArtistsAction() {
        delegate?.requestToChooseArtists(from: self)
    }
}
