//
//  MenuViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/6/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol MenuViewModelDelegate: class {
    func requestSortOptionsScene(_ menuViewModel: MenuViewModel)
    func requestResetDataScene(_ menuViewModel: MenuViewModel)
    func requestAuthenticationScene(_ menuViewModel: MenuViewModel)
}

enum MenuSceneAction {
    case requestSortOptionsScene
    case requestResetDataScene
    case disconnectSpotify
    case setAutoplayIsEnabled(Bool)
}

class MenuViewModel {
    
    //MARK: - Dependencies
    
    private weak var delegate: MenuViewModelDelegate?
    private let userSettingsStateController: UserSettingsStateController
    private let userProfileStateController: UserProfileStateController
    private let authStateController: AuthStateController
    
    //MARK: - State
    
    private(set) lazy var isAutoplayEnabled: Observable<Bool> = {
        return self.userSettingsStateController.isAutoplayEnabled.asObservable()
            .shareReplay(1)
    }()
    
    private(set) lazy var albumSortType: Observable<AlbumSortType> = {
        return self.userSettingsStateController.albumSortType.asObservable()
            .map { AlbumSortType(rawValue: $0)! }
            .shareReplay(1)
    }()
    
    //MARK: - Initialization
    
    init(delegate: MenuViewModelDelegate,
         userSettingsStateController: UserSettingsStateController,
         userProfileStateController: UserProfileStateController,
         authStateController: AuthStateController)
    {
        self.delegate = delegate
        self.userSettingsStateController = userSettingsStateController
        self.userProfileStateController = userProfileStateController
        self.authStateController = authStateController
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: MenuSceneAction) {
        switch action {
        case .requestSortOptionsScene:
            handle_requestSortOptionsScene()
        case .requestResetDataScene:
            handle_requestResetDataScene()
        case .disconnectSpotify:
            handle_disconnectSpotify()
        case .setAutoplayIsEnabled(let isEnabled):
            handle_setAutoplayIsEnabled(isEnabled)
        }
    }
    
    private func handle_requestSortOptionsScene() {
        delegate?.requestSortOptionsScene(self)
    }
    
    private func handle_requestResetDataScene() {
        delegate?.requestResetDataScene(self)
    }
    
    private func handle_disconnectSpotify() {
        userProfileStateController.setSpotifyConnected(false)
        authStateController.deleteSession()
        delegate?.requestAuthenticationScene(self)
    }
    
    private func handle_setAutoplayIsEnabled(_ isEnabled: Bool) {
        userSettingsStateController.setIsAutoplayEnabled(isEnabled)
    }
}


