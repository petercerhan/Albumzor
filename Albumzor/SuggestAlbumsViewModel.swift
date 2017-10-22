//
//  SuggestAlbumsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/18/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation



enum SuggestAlbumsSceneAction {
    case likeAlbum
}


class SuggestAlbumsViewModel {
    
    //MARK: - Dependencies
    
    private let seedArtistStateController: SeedArtistStateController
    private let suggestedAlbumsStateController: SuggestedAlbumsStateController
    
    //MARK: - Initialization
    
    init(seedArtistStateController: SeedArtistStateController, suggestedAlbumsStateController: SuggestedAlbumsStateController) {
        self.seedArtistStateController = seedArtistStateController
        self.suggestedAlbumsStateController = suggestedAlbumsStateController
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: SuggestAlbumsSceneAction) {
        switch action {
        case .likeAlbum:
            handle_likeAlbum()
        }
    }
    
    private func handle_likeAlbum() {
        suggestedAlbumsStateController.reviewAlbum(like: true)
    }
    
}

