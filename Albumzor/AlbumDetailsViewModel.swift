//
//  AlbumDetailsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/29/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol AlbumDetailsViewModelDelegate: class {
    func dismiss(_ albumDetailsViewModel: AlbumDetailsViewModel)
}

enum AlbumDetailsSceneAction {
    case dismiss
}

class AlbumDetailsViewModel {
    
    //MARK: - Dependencies
    
    private weak var delegate: AlbumDetailsViewModelDelegate?
    
    //MARK: - Initialization
    
    init(delegate: AlbumDetailsViewModelDelegate) {
        self.delegate = delegate
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: AlbumDetailsSceneAction) {
        switch action {
        case .dismiss:
            handle_dismiss()
        }
    }
    
    private func handle_dismiss() {
        delegate?.dismiss(self)
    }
    
}
