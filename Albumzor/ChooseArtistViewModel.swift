//
//  ChooseArtistViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/27/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol ChooseArtistViewModelDelegate: class {
    func chooseArtistSceneComplete(_ chooseArtistViewModel: ChooseArtistViewModel)
}

enum ChooseArtistSceneAction {
    case requestNextScene
    case requestCustomSearch
    case cancelCustomSearch
}

class ChooseArtistViewModel {
    
    //MARK: - Dependencies
    
    let seedArtistStateController: SeedArtistStateController
    weak var delegate: ChooseArtistViewModelDelegate?
    
    //MARK: - State
    
    let seedArtists = Variable<[String]>([])
    var searchActive: Variable<Bool> {
        return seedArtistStateController.searchActive
    }
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(delegate: ChooseArtistViewModelDelegate, seedArtistStateController: SeedArtistStateController) {
        self.seedArtistStateController = seedArtistStateController
        bindSeedArtistStateController()
    }
    
    private func bindSeedArtistStateController() {
        seedArtistStateController.seedArtists.asObservable()
            .subscribe(onNext: { [unowned self] artists in
                self.seedArtists.value = artists
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: ChooseArtistSceneAction) {
        switch action {
        case .requestNextScene:
            handle_RequestNextSceneAction()
        case .requestCustomSearch:
             handle_RequestCustomSearch()
        case .cancelCustomSearch:
            handle_CancelCustomSearch()
        }
        
    }
    
    private func handle_RequestNextSceneAction() {
        delegate?.chooseArtistSceneComplete(self)
    }
    
    private func handle_RequestCustomSearch() {
        seedArtistStateController.customArtistSearch(showSearch: true)
    }
    
    private func handle_CancelCustomSearch() {
        seedArtistStateController.customArtistSearch(showSearch: false)
    }
}




