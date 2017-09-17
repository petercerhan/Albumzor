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

struct OpenSceneActions {
    struct SceneCompleteAction: Action {}
}

class OpenSceneViewModel {
    
    //MARK: - Dependencies
    
    weak var delegate: OpenSceneViewModelDelegate?
    
    //MARK: - Initialization
    
    init(delegate: OpenSceneViewModelDelegate) {
        self.delegate = delegate
    }
    
    
    //MARK: - Actions
    
    func dispatch(action: Action) {
        switch action {
        case let action as OpenSceneActions.SceneCompleteAction:
            handleSceneCompleteAction(action: action)
        default:
            return
        }
    }
    
    func handleSceneCompleteAction(action: OpenSceneActions.SceneCompleteAction) {
        delegate?.sceneComplete(self)
    }
    
}
