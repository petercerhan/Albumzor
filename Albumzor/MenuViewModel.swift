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
    
}

class MenuViewModel {
    
    //MARK: - Dependencies
    
    private weak var delegate: MenuViewModelDelegate?
    private let userSettingsStateController: UserSettingsStateController
    
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
    
    init(delegate: MenuViewModelDelegate, userSettingsStateController: UserSettingsStateController) {
        self.delegate = delegate
        self.userSettingsStateController = userSettingsStateController
    }
    
    
}
