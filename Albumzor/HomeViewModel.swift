//
//  HomeViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol HomeViewModelDelegate: class {
    func requestMenuScene(_ homeViewModel: HomeViewModel)
}

enum HomeSceneAction {
    case requestMenuScene
}

class HomeViewModel {
    
    //MARK: - Dependencies
    
    private weak var delegate: HomeViewModelDelegate?
    
    //MARK: - Initialization
    
    init(delegate: HomeViewModelDelegate) {
        self.delegate = delegate
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: HomeSceneAction){
        switch action {
        case .requestMenuScene:
            handle_requestMenuScene()
        }
    }
    
    private func handle_requestMenuScene() {
        delegate?.requestMenuScene(self)
    }
    
}
