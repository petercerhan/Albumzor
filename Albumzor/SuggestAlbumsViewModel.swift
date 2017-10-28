//
//  SuggestAlbumsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/18/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

enum SuggestAlbumsSceneAction {
    case reviewAlbum(liked: Bool)
}

class SuggestAlbumsViewModel {
    
    //MARK: - Dependencies
    
    private let seedArtistStateController: SeedArtistStateController
    private let suggestedAlbumsStateController: SuggestedAlbumsStateController
    
    //MARK: - State
    
    private(set) lazy var currentAlbumTitle: Observable<String?> = {
        return self.suggestedAlbumsStateController.currentAlbum
            .map { $0?.name }
            .shareReplay(1)
    }()
    
    private(set) lazy var currentAlbumArtistName: Observable<String?> = {
        return self.suggestedAlbumsStateController.currentArtist
            .map { $0?.name }
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
    
    init(seedArtistStateController: SeedArtistStateController, suggestedAlbumsStateController: SuggestedAlbumsStateController) {
        self.seedArtistStateController = seedArtistStateController
        self.suggestedAlbumsStateController = suggestedAlbumsStateController
        
        bindSuggestedAlbumsStateController()
    }
    
    private func bindSuggestedAlbumsStateController() {
        suggestedAlbumsStateController.likedAlbumArtistStream
            .subscribe(onNext: { [unowned self] artistData in
                
                print("view model sees add seed artist for artist \(artistData.name)")
                
                self.seedArtistStateController.addSeedArtist(artistData: artistData)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: SuggestAlbumsSceneAction) {
        switch action {
        case .reviewAlbum(let liked):
            handle_reviewAlbum(liked: liked)
        }
    }
    
    private func handle_reviewAlbum(liked: Bool) {
        suggestedAlbumsStateController.reviewAlbum(liked: liked)
    }
    
}

