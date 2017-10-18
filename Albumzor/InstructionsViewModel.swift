//
//  InstructionsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/17/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol InstructionsViewModelDelegate: class {
    func requestNextScene(_ instructionsViewModel: InstructionsViewModel)
}

enum InstructionsSceneAction {
    case requestNextScene
}

class InstructionsViewModel {
    
    //MARK: - Dependencies
    
    private let userSettingsStateController: UserSettingsStateController
    private weak var delegate: InstructionsViewModelDelegate?
    
    //MARK: - Initialization
    
    init(delegate: InstructionsViewModelDelegate, userSettingsStateController: UserSettingsStateController) {
        self.userSettingsStateController = userSettingsStateController
        self.delegate = delegate
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: InstructionsSceneAction) {
        switch action {
        case .requestNextScene:
            handle_requestNextScene()
        }
    }
    
    private func handle_requestNextScene() {
        userSettingsStateController.setInstructionsSeen(true)
        delegate?.requestNextScene(self)
    }
}
