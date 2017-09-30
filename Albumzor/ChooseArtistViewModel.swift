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
    func showConfirmArtistScene(_ chooseArtistViewModel: ChooseArtistViewModel, confirmationArtist: String)
}

enum ChooseArtistSceneAction {
    case requestNextScene
    case requestCustomSearch
    case cancelCustomSearch
    case requestConfirmArtists(searchString: String)
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
    var confirmationActive: Observable<Bool> {
        return seedArtistStateController.confirmationActive.asObservable()
    }
    var confirmationArtistName: Observable<String?> {
        return seedArtistStateController.confirmationArtistName.asObservable()
    }
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(delegate: ChooseArtistViewModelDelegate, seedArtistStateController: SeedArtistStateController) {
        self.delegate = delegate
        self.seedArtistStateController = seedArtistStateController
        bindSeedArtistStateController()
    }
    
    //MARK: - Bind StateControllers
    
    private func bindSeedArtistStateController() {
        seedArtistStateController.seedArtists.asObservable()
            .subscribe(onNext: { [unowned self] artists in
                self.seedArtists.value = artists
            })
            .disposed(by: disposeBag)
        
        seedArtistStateController.confirmationActive.asObservable()
            .filter( { $0 })
            .withLatestFrom(seedArtistStateController.confirmationArtistName.asObservable()) { active, confirmationArtist in
                return (active, confirmationArtist)
            }
            .filter({ $1 != nil })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _, confirmationArtist in
                self.delegate?.showConfirmArtistScene(self, confirmationArtist: confirmationArtist!)
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
        case .requestConfirmArtists(let artistString):
            handle_RequestConfirmArtists(artistString: artistString)
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
    
    private func handle_RequestConfirmArtists(artistString: String) {
        seedArtistStateController.searchArtistForConfirmation(artistString: artistString)
    }
}




