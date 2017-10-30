//
//  AlbumDetailsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/29/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol AlbumDetailsViewModelDelegate: class {
    func dismiss(_ albumDetailsViewModel: AlbumDetailsViewModel)
}

protocol AlbumDetailsStateControllerProtocol {
    var albumDetails_album: Observable<AlbumData?> { get }
    var albumDetails_artist: Observable<ArtistData?> { get }
    var albumDetails_albumArt: Observable<UIImage?> { get }
    var albumDetails_tracks: Observable<[TrackData]?> { get }
}

enum AlbumDetailsSceneAction {
    case dismiss
    case playTrack(url: String, trackIndex: Int)
}

class AlbumDetailsViewModel {
    
    //MARK: - Dependencies
    
    private let albumDetailsStateController: AlbumDetailsStateControllerProtocol
    private let audioStateController: AudioStateController
    private weak var delegate: AlbumDetailsViewModelDelegate?
    
    //MARK: - State
    
    private(set) lazy var albumTitle: Observable<String?> = {
        return self.albumDetailsStateController.albumDetails_album
            .map { $0?.cleanName }
            .shareReplay(1)
    }()
    
    private(set) lazy var artistName: Observable<String?> = {
        return self.albumDetailsStateController.albumDetails_artist
            .map { $0?.cleanName }
            .shareReplay(1)
    }()
    
    private(set) lazy var albumImage: Observable<UIImage?> = {
        return self.albumDetailsStateController.albumDetails_albumArt
            .shareReplay(1)
    }()
    
    private(set) lazy var tracks: Observable<[TrackData]?> = {
        return self.albumDetailsStateController.albumDetails_tracks
            .shareReplay(1)
    }()
    
    //MARK: - Initialization
    
    init(albumDetailsStateController: AlbumDetailsStateControllerProtocol, audioStateController: AudioStateController, delegate: AlbumDetailsViewModelDelegate) {
        self.albumDetailsStateController = albumDetailsStateController
        self.audioStateController = audioStateController
        self.delegate = delegate
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: AlbumDetailsSceneAction) {
        switch action {
        case .dismiss:
            handle_dismiss()
        case .playTrack(let url, let trackIndex):
            handle_playTrack(url: url, trackIndex: trackIndex)
        }
    }
    
    private func handle_dismiss() {
        delegate?.dismiss(self)
    }
    
    private func handle_playTrack(url: String, trackIndex: Int) {
        print("audio command dispatched")
        audioStateController.playTrack(url: url, trackListIndex: trackIndex)
    }

}


