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
    case autoPlay
    case pauseAudio
    case resumeAudio
    case openInSpotify
    case home
}

class SuggestAlbumsViewModel {
    
    //MARK: - Dependencies
    
    private let seedArtistStateController: SeedArtistStateController
    private let suggestedAlbumsStateController: SuggestedAlbumsStateController
    private let audioStateController: AudioStateController
    private let userSettingsStateController: UserSettingsStateController
    private let externalURLProxy: ExternalURLProxy
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
         userSettingsStateController: UserSettingsStateController,
         externalURLProxy: ExternalURLProxy,
         delegate: SuggestAlbumsViewModelDelegate)
    {
        self.seedArtistStateController = seedArtistStateController
        self.suggestedAlbumsStateController = suggestedAlbumsStateController
        self.audioStateController = audioStateController
        self.userSettingsStateController = userSettingsStateController
        self.externalURLProxy = externalURLProxy
        self.delegate = delegate
        
        bindSuggestedAlbumsStateController()
    }
    
    private func bindSuggestedAlbumsStateController() {
        
        //show details
        suggestedAlbumsStateController.showDetails.asObservable()
            .filter { $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self.delegate?.showAlbumDetails(self)
            })
            .disposed(by: disposeBag)
        
        //Seed artists
        suggestedAlbumsStateController.likedAlbumArtistStream
            .subscribe(onNext: { [unowned self] artistData in
                self.seedArtistStateController.addSeedArtist(artistData: artistData)
            })
            .disposed(by: disposeBag)
        
        //tracks
        suggestedAlbumsStateController.currentAlbumTracks
            .subscribe().disposed(by: disposeBag)
        
        //Autoplay
        currentAlbumTitle
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                if self.userSettingsStateController.isAutoplayEnabled.value {
                    self.handle_autoPlay()
                }
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
        case .openInSpotify:
            handle_openInSpotify()
        case .home:
            handle_home()
        }
    }
    
    private func handle_reviewAlbum(liked: Bool) {
        audioStateController.clear()
        suggestedAlbumsStateController.reviewAlbum(liked: liked)
    }
    
    private func handle_showDetails() {
        suggestedAlbumsStateController.showDetails(true)
    }
    
    private func handle_autoPlay() {
        suggestedAlbumsStateController.currentAlbumTracks
            .take(1)
            .subscribe(onNext: { [unowned self] tracks in
                guard let tracks = tracks else {
                    self.audioStateController.noPreview(trackListIndex: nil)
                    return
                }
                
                var maxPopularity = 0
                var maxIndex = 0
                
                for (index, track) in tracks.enumerated() {
                    if Int(track.popularity) > maxPopularity {
                        maxPopularity = Int(track.popularity)
                        maxIndex = index
                    }
                }
                
                guard let previewURL = tracks[maxIndex].previewURL else {
                    self.audioStateController.noPreview(trackListIndex: nil)
                    return
                }

                print("Autoplay track at index \(maxIndex)")
                
                self.audioStateController.playTrack(url: previewURL, trackListIndex: maxIndex)
            })
            .disposed(by: disposeBag)
    }
    
    private func handle_pauseAudio() {
        audioStateController.pauseAudio()
    }
    
    private func handle_resumeAudio() {
        audioStateController.resumeAudio()
    }
    
    private func handle_openInSpotify() {
        suggestedAlbumsStateController.currentAlbum
            .take(1)
            .filter { $0 != nil }
            .subscribe(onNext: { [unowned self] albumData in
                self.externalURLProxy.requestToOpen(url: "https://open.spotify.com/album/\(albumData!.id)")
            })
            .disposed(by: disposeBag)
    }
    
    private func handle_home() {
        audioStateController.clear()
        delegate?.suggestAlbumsSceneComplete(self)
    }
    
}



