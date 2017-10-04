//
//  ConfirmArtistViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/30/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol ConfirmArtistViewModelDelegate: class {
    func cancel(_ confirmArtistViewModel: ConfirmArtistViewModel)
}

enum ConfirmArtistSceneAction {
    case confirmArtist
    case cancel
    case openInSpotify(url: String)
}

class ConfirmArtistViewModel {
    
    //MARK: - Dependencies
    
    let seedArtistStateController: SeedArtistStateController
    weak var delegate: ConfirmArtistViewModelDelegate?
    
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
    var confirmArtistImage: Observable<UIImage?> {
        return seedArtistStateController.confirmArtistImage.asObservable()
    }
    
    //MARK: - Initialization
    
    init(delegate: ConfirmArtistViewModelDelegate, seedArtistStateController: SeedArtistStateController) {
        self.seedArtistStateController = seedArtistStateController
        self.delegate = delegate
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: ConfirmArtistSceneAction) {
        switch action {
        case .confirmArtist:
            print("Confirm artist")
        case .cancel:
            handle_ConfirmArtist()
        case .openInSpotify(let url):
            print("URL \(url)")
        }
    }
    
    private func handle_ConfirmArtist() {
        delegate?.cancel(self)
    }
    
}







