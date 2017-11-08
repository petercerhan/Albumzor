//
//  ResetDataViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/7/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol ResetDataViewModelDelegate: class {
    func cancel(_ resetDataViewModel: ResetDataViewModel)
    func dataReset(_ resetDataViewModel: ResetDataViewModel)
}

enum ResetSceneAction {
    case cancel
    case resetData
}

class ResetDataViewModel {
    
    //MARK: - Dependencies
    
    private weak var delegate: ResetDataViewModelDelegate?
    private let seedArtistStateController: SeedArtistStateController
    private let userSettingsStateController: UserSettingsStateController
    
    //MARK: - State
    
    private(set) lazy var resetOperationState: Observable<DataOperationState> = {
        return self.seedArtistStateController.resetDataState.asObservable()
    }()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(delegate: ResetDataViewModelDelegate,
         seedArtistStateController: SeedArtistStateController,
         userSettingsStateController: UserSettingsStateController)
    {
        self.delegate = delegate
        self.seedArtistStateController = seedArtistStateController
        self.userSettingsStateController = userSettingsStateController
        
        bindSeedArtistStateController()
    }
    
    private func bindSeedArtistStateController() {
        seedArtistStateController.resetDataState.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .operationCompleted:
                    self.userSettingsStateController.reset()
                    self.delegate?.dataReset(self)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: ResetSceneAction) {
        switch action {
        case .cancel:
            handle_cancel()
        case .resetData:
            handle_resetData()
        }
    }
    
    private func handle_cancel() {
        delegate?.cancel(self)
    }
    
    private func handle_resetData() {
        seedArtistStateController.resetData()
    }
    
}
