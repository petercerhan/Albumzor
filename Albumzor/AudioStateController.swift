//
//  AudioStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/29/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift


class AudioStateController {
    
    //MARK: - Dependencies
    
    private let audioService: AudioService
    
    //MARK: - State
    
    private(set) lazy var audioState: Observable<AudioState> = {
        return self.audioService.audioState.shareReplay(1)
    }()
    
    private(set) lazy var trackListIndex: Observable<Int> = {
        return self.trackListIndexSubject.asObservable().shareReplay(1)
    }()
    
    private let trackListIndexSubject = PublishSubject<Int>()
    
    //MARK: - Initialization
    
    init(audioService: AudioService) {
        self.audioService = audioService
    }
    
    //MARK: - Interface
    
    func playTrack(url urlString: String, trackListIndex: Int) {
        trackListIndexSubject.onNext(trackListIndex)
        audioService.playTrack(url: urlString)
    }
    
    func pauseAudio() {
        audioService.pauseAudio()
    }
    
    func resumeAudio() {
        audioService.resumeAudio()
    }
    
    func noTrack() {
        audioService.noTrack()
    }
    
}


