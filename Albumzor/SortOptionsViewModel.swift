//
//  SortOptionsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/6/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol SortOptionsViewModelDelegate: class {
    
}

enum SortOptionsSceneAction {
    case setSortType(AlbumSortType)
}

class SortOptionsViewModel {
    
    //MARK: - Dependencies
    
    private weak var delegate: SortOptionsViewModelDelegate?
    private let userSettingsStateController: UserSettingsStateController
    
    //MARK: - State
    
    private(set) lazy var albumSortType: Observable<AlbumSortType> = {
        return self.userSettingsStateController.albumSortType.asObservable()
            .map { AlbumSortType(rawValue: $0)! }
            .shareReplay(1)
    }()
    
    //MARK: - Initialization
    
    init(delegate: SortOptionsViewModelDelegate, userSettingsStateController: UserSettingsStateController) {
        self.delegate = delegate
        self.userSettingsStateController = userSettingsStateController
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: SortOptionsSceneAction){
        switch action {
        case .setSortType(let sortType):
            handle_setSortType(sortType)
        }
    }
    
    private func handle_setSortType(_ sortType: AlbumSortType) {
        userSettingsStateController.setSortType(sortType.rawValue)
    }
    
}
