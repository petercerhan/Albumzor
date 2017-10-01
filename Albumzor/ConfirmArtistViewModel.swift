//
//  ConfirmArtistViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/30/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class ConfirmArtistViewModel {
    
    //MARK: - Dependencies
    
    let seedArtistStateController: SeedArtistStateController
    
    //MARK: - State
    
    var confirmationArtistName: Observable<String?> {
        return seedArtistStateController.confirmArtistData.asObservable()
            .map { artistData -> String? in
                return artistData?.name
            }
    }
    var loadConfirmArtistState: Observable<DataOperationState> {
        return seedArtistStateController.loadConfirmArtistState.asObservable()
    }
    
    var loadConfirmArtistImageOperationState: Observable<DataOperationState> {
        return seedArtistStateController.loadConfirmArtistImageOperationState.asObservable()
    }
    
    
    
    //MARK: - Initialization
    
    init(seedArtistStateController: SeedArtistStateController) {
        self.seedArtistStateController = seedArtistStateController
    }
    
}
