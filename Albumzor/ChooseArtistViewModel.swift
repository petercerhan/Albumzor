//
//  ChooseArtistViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class ChooseArtistViewModel {
    
    //MARK: - Dependencies
    
    let seedArtistStateController: SeedArtistStateController
    
    //MARK: - Initialization
    
    init(seedArtistStateController: SeedArtistStateController) {
        self.seedArtistStateController = seedArtistStateController
    }
    
}

