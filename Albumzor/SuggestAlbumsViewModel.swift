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
    func showAlbumDetails(_ suggestArtistViewModel: SuggestAlbumsViewModel, albumDetailsStateController: AlbumDetailsStateControllerProtocol)
}

enum SuggestAlbumsSceneAction {
    case reviewAlbum(liked: Bool)
    case showDetails
    case autoPlay
    case pauseAudio
    case resumeAudio
}

class SuggestAlbumsViewModel {
    
    //MARK: - Dependencies
    
    private let seedArtistStateController: SeedArtistStateController
    private let suggestedAlbumsStateController: SuggestedAlbumsStateController
    private let audioStateController: AudioStateController
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
    
    private(set) lazy var audioState: Observable<AudioState> = {
        return self.audioStateController.audioState
            .distinctUntilChanged()
            .shareReplay(1)
    }()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(seedArtistStateController: SeedArtistStateController,
         suggestedAlbumsStateController: SuggestedAlbumsStateController,
         audioStateController: AudioStateController,
         delegate: SuggestAlbumsViewModelDelegate)
    {
        self.seedArtistStateController = seedArtistStateController
        self.suggestedAlbumsStateController = suggestedAlbumsStateController
        self.audioStateController = audioStateController
        self.delegate = delegate
        
        bindSuggestedAlbumsStateController()
    }
    
    private func bindSuggestedAlbumsStateController() {
        
        suggestedAlbumsStateController.showDetails.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.delegate?.showAlbumDetails(self, albumDetailsStateController: self.suggestedAlbumsStateController)
            })
            .disposed(by: disposeBag)
        
        suggestedAlbumsStateController.likedAlbumArtistStream
            .subscribe(onNext: { [unowned self] artistData in
                self.seedArtistStateController.addSeedArtist(artistData: artistData)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: SuggestAlbumsSceneAction) {
        switch action {
        case .reviewAlbum(let liked):
            handle_reviewAlbum(liked: liked)
        case .showDetails:
            handle_showDetails()
        case .autoPlay:
            handle_autoPlay()
        case .pauseAudio:
            handle_pauseAudio()
        case .resumeAudio:
            handle_resumeAudio()
        }
    }
    
    private func handle_reviewAlbum(liked: Bool) {
        suggestedAlbumsStateController.reviewAlbum(liked: liked)
    }
    
    private func handle_showDetails() {
        suggestedAlbumsStateController.showDetails(true)
    }
    
    private func handle_autoPlay() {
        print("Autoplay..")
    }
    
    private func handle_pauseAudio() {
        audioStateController.pauseAudio()
    }
    
    private func handle_resumeAudio() {
        audioStateController.resumeAudio()
    }
    
    
}



