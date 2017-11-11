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
    case playTrack(trackIndex: Int)
    case pauseAudio
    case resumeAudio
    case openInSpotify
    case autoPlay
}

class AlbumDetailsViewModel {
    
    //MARK: - Dependencies
    
    private let albumDetailsStateController: AlbumDetailsStateControllerProtocol
    private let audioStateController: AudioStateController
    private let externalURLProxy: ExternalURLProxy
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
    
    private(set) lazy var tracks: Observable<[(String, Int)]?> = {
        return self.albumDetailsStateController.albumDetails_tracks
            .map { tracks -> [TrackData]? in 
                if let tracks = tracks {
                    return tracks.sorted(by: {
                        if $0.discNumber == $1.discNumber {
                            return $0.trackNumber < $1.trackNumber
                        } else {
                            return $0.discNumber < $1.discNumber
                        }
                    })
                } else {
                    return nil
                }
            }
            .map { tracks -> [(String, Int)]? in
                if let tracks = tracks {
                    return tracks.map { ($0.name, $0.trackNumber) }
                } else {
                    return nil
                }
            }
            .shareReplay(1)
    }()
    
    private(set) lazy var audioState: Observable<AudioState> = {
        return self.audioStateController.audioState
            .distinctUntilChanged()
            .shareReplay(1)
    }()
    
    private(set) lazy var trackPlayingIndex: Observable<Int?> = {
        return self.audioStateController.trackListIndex
            .shareReplay(1)
    }()
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(albumDetailsStateController: AlbumDetailsStateControllerProtocol,
         audioStateController: AudioStateController,
         externalURLProxy: ExternalURLProxy,
         delegate: AlbumDetailsViewModelDelegate)
    {
        self.albumDetailsStateController = albumDetailsStateController
        self.audioStateController = audioStateController
        self.externalURLProxy = externalURLProxy
        self.delegate = delegate
    }
    
    //MARK: - Dispatch Actions
    
    func dispatch(action: AlbumDetailsSceneAction) {
        switch action {
        case .dismiss:
            handle_dismiss()
        case .playTrack(let trackIndex):
            handle_playTrack(trackIndex: trackIndex)
        case .pauseAudio:
            handle_pauseAudio()
        case .resumeAudio:
            handle_resumeAudio()
        case .openInSpotify:
            handle_openInSpotify()
        case .autoPlay:
            handle_autoPlay()
        }
    }
    
    private func handle_dismiss() {
        delegate?.dismiss(self)
    }
    
    private func handle_playTrack(trackIndex: Int) {
        albumDetailsStateController.albumDetails_tracks
            .take(1)
            .subscribe(onNext: { [unowned self] tracks in
                if
                    let tracks = tracks,
                    let previewURL = tracks[trackIndex].previewURL
                {
                    self.audioStateController.playTrack(url: previewURL, trackListIndex: trackIndex)
                } else {
                    self.audioStateController.noPreview(trackListIndex: trackIndex)
                }
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
        albumDetailsStateController.albumDetails_album
            .take(1)
            .filter { $0 != nil }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] albumData in
                self.externalURLProxy.requestToOpen(url: "https://open.spotify.com/album/\(albumData!.id)")
            })
            .disposed(by: disposeBag)
    }
    
    private func handle_autoPlay() {
        albumDetailsStateController.albumDetails_tracks
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
                
                self.audioStateController.playTrack(url: previewURL, trackListIndex: maxIndex)
            })
            .disposed(by: disposeBag)
    }

}




