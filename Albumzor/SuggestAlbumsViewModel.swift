//
//  SuggestAlbumsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/18/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol SuggestAlbumsViewModelDelegate: class {
    func suggestAlbumsSceneComplete(_ suggestAlbumsViewModel: SuggestAlbumsViewModel)
    func showAlbumDetails(_ suggestArtistViewModel: SuggestAlbumsViewModel)
}

enum SuggestAlbumsSceneAction {
    case reviewAlbum(liked: Bool)
    case showDetails
}

class SuggestAlbumsViewModel {
    
    //MARK: - Dependencies
    
    private let seedArtistStateController: SeedArtistStateController
    private let suggestedAlbumsStateController: SuggestedAlbumsStateController
    private weak var delegate: SuggestAlbumsViewModelDelegate?
    
    //MARK: - State
    
    private(set) lazy var currentAlbumTitle: Observable<String?> = {
        return self.suggestedAlbumsStateController.currentAlbum
            .map { $0?.cleanName }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentAlbumArtistName: Observable<String?> = {
        return self.suggestedAlbumsStateController.currentArtist
            .map { $0?.cleanName }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentAlbumArt: Observable<UIImage?> = {
        return self.suggestedAlbumsStateController.currentAlbumArt
            .shareReplay(1)
    }()
    
    private(set) lazy var nextAlbumArt: Observable<UIImage?> = {
        return self.suggestedAlbumsStateController.nextAlbumArt
            .shareReplay(1)
    }()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(seedArtistStateController: SeedArtistStateController, suggestedAlbumsStateController: SuggestedAlbumsStateController, delegate: SuggestAlbumsViewModelDelegate) {
        self.seedArtistStateController = seedArtistStateController
        self.suggestedAlbumsStateController = suggestedAlbumsStateController
        self.delegate = delegate
        
        bindSuggestedAlbumsStateController()
    }
    
    private func bindSuggestedAlbumsStateController() {
        
        suggestedAlbumsStateController.showDetails.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.delegate?.showAlbumDetails(self)
            })
            .disposed(by: disposeBag)
        
        suggestedAlbumsStateController.likedAlbumArtistStream
            .subscribe(onNext: { [unowned self] artistData in
                self.seedArtistStateController.addSeedArtist(artistData: artistData)
            })
            .disposed(by: disposeBag)
        
        
        //Current Tracks...
        suggestedAlbumsStateController.currentAlbumTracks
            .subscribe(onNext: { tracks in
                if let tracks = tracks {
                    print("tracks received: \(tracks[0].name)")
                } else {
                    print("nil received")
                }
            })
            .disposed(by: disposeBag)
        ////
        
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: SuggestAlbumsSceneAction) {
        switch action {
        case .reviewAlbum(let liked):
            handle_reviewAlbum(liked: liked)
        case .showDetails:
            handle_showDetails()
        }
    }
    
    private func handle_reviewAlbum(liked: Bool) {
        suggestedAlbumsStateController.reviewAlbum(liked: liked)
    }
    
    private func handle_showDetails() {
        suggestedAlbumsStateController.showDetails(true)
    }
    
}

