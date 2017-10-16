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
    let externalURLProxy: ExternalURLProxy
    weak var delegate: ConfirmArtistViewModelDelegate?
    
    //MARK: - State
    
    var confirmationArtistName: Observable<String?> {
        return seedArtistStateController.confirmArtistData.asObservable()
            .map { artistData -> String? in
                return artistData?.name
            }
    }
    var confirmationArtistID: Observable<String?> {
        return seedArtistStateController.confirmArtistData.asObservable()
            .map { artistData -> String? in
                return artistData?.id
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
    
    init(delegate: ConfirmArtistViewModelDelegate, seedArtistStateController: SeedArtistStateController, externalURLProxy: ExternalURLProxy) {
        self.seedArtistStateController = seedArtistStateController
        self.externalURLProxy = externalURLProxy
        self.delegate = delegate
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: ConfirmArtistSceneAction) {
        switch action {
        case .confirmArtist:
            handle_ConfirmArtist()
        case .cancel:
            handle_CancelArtist()
        case .openInSpotify(let url):
            handle_OpenInSpotify(url: url)
        }
    }
    
    private func handle_ConfirmArtist() {
        seedArtistStateController.addSeedArtist()
        seedArtistStateController.endConfirmation()
        delegate?.cancel(self)
    }
    
    private func handle_CancelArtist() {
        seedArtistStateController.endConfirmation()
        delegate?.cancel(self)
    }
    
    private func handle_OpenInSpotify(url: String) {
        externalURLProxy.requestToOpen(url: url)
    }
}










