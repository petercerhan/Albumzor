//
//  ChooseArtistViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol ChooseArtistViewModelDelegate: class {
    func chooseArtistSceneComplete(_ chooseArtistViewModel: ChooseArtistViewModel)
}

enum ChooseArtistSceneAction {
    case requestNextScene
}

class ChooseArtistViewModel {
    
    //MARK: - Dependencies
    
    let seedArtistStateController: SeedArtistStateController
    weak var delegate: ChooseArtistViewModelDelegate?
    
    //MARK: - Initialization
    
    init(delegate: ChooseArtistViewModelDelegate, seedArtistStateController: SeedArtistStateController) {
        self.seedArtistStateController = seedArtistStateController
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: ChooseArtistSceneAction) {
        switch action {
        case .requestNextScene:
            handleRequestNextSceneAction()
        }
    }
    
    private func handleRequestNextSceneAction() {
        delegate?.chooseArtistSceneComplete(self)
    }
}

