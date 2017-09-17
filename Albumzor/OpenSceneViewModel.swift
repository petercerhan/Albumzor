//
//  OpenSceneViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

struct OpenSceneActions {
    struct SceneCompleteAction: Action {}
}

class OpenSceneViewModel {
    
    func dispatch(action: Action) {
        switch action {
        case let action as OpenSceneActions.SceneCompleteAction:
            handleSceneCompleteAction(action: action)
        default:
            return
        }
    }
    
    func handleSceneCompleteAction(action: OpenSceneActions.SceneCompleteAction) {
        print("Scene complete vm")
    }
    
}
