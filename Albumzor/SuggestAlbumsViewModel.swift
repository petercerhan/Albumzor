//
//  SuggestAlbumsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/18/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class SuggestAlbumsViewModel {
    
    //MARK: - Dependencies
    
    private let seedArtistStateController: SeedArtistStateController
    
    //MARK: - Initialization
    
    init(seedArtistStateController: SeedArtistStateController) {
        self.seedArtistStateController = seedArtistStateController
    }
    
}
