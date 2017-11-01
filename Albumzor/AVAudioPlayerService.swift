//
//  AVAudioPlayerService.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/29/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift
import AVFoundation

protocol AudioService {
    var audioState: Observable<AudioState> { get }
    
    func playTrack(url urlString: String)
    func pauseAudio()
    func resumeAudio()
    func error()
    func clear()
}

enum AudioState {
    case none
    case loading
    case playing
    case paused
    case error
}

class AVAudioPlayerService: AudioService {
    
    //MARK: - State
    
    private var audioPlayer: AVAudioPlayer?
    
    private(set) lazy var audioState: Observable<AudioState> = {
        return self.audioStateSubject.asObservable().shareReplay(1)
    }()
    
    private let audioStateSubject = ReplaySubject<AudioState>.create(bufferSize: 1)
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init() {
        audioStateSubject.onNext(.none)
    }
    
    //MARK: - Interface
    
    func playTrack(url urlString: String) {
        //stop current track if any
        audioPlayer?.stop()
        //set current state to loading
        audioStateSubject.onNext(.loading)
        
        playerWithTrack(atURL: urlString)
            .subscribe(onNext: { [unowned self] audioPlayer in
                self.audioPlayer = audioPlayer
                self.audioPlayer?.play()
                self.audioStateSubject.onNext(.playing)
            }, onError: { _ in
                self.audioStateSubject.onNext(.error)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func playerWithTrack(atURL urlString: String) -> Observable<AVAudioPlayer> {
        return Observable<AVAudioPlayer>.create() { (observer) -> Disposable in
            DispatchQueue.global(qos: .userInitiated).async {
                if
                    let url = URL(string: urlString),
                    let audioData = try? Data(contentsOf: url),
                    let audioPlayer = try? AVAudioPlayer(data: audioData)
                {
                    observer.onNext(audioPlayer)
                } else {
                    observer.onError(NetworkRequestError.connectionFailed)
                }
            }
            return Disposables.create()
        }
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        audioStateSubject.onNext(.paused)
    }
    
    func resumeAudio() {
        audioPlayer?.play()
        audioStateSubject.onNext(.playing)
    }
    
    func clear() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioStateSubject.onNext(.none)
    }
    
    func error() {
        audioPlayer?.stop()
        audioPlayer = nil
        audioStateSubject.onNext(.error)
    }
    
}


