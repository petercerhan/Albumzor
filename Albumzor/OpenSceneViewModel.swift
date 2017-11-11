//
//  OpenSceneViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol OpenSceneViewModelDelegate: class {
    func sceneComplete(_ openSceneViewModel: OpenSceneViewModel)
}

enum OpenSceneAction {
    case sceneComplete
}

class OpenSceneViewModel {
    
    //MARK: - Dependencies
    
    weak var delegate: OpenSceneViewModelDelegate?
    
    //MARK: - Initialization
    
    init(delegate: OpenSceneViewModelDelegate) {
        self.delegate = delegate
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: OpenSceneAction) {
        switch action {
        case .sceneComplete:
            handle_SceneCompleteAction()
        }
    }
    
    func handle_SceneCompleteAction() {
        delegate?.sceneComplete(self)
    }
    
}
