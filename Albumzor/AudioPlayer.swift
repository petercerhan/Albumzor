//
//  AudioPlayer.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/13/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioPlayerDelegate {
    func beganLoading()
    func beganPlaying()
    func paused()
    func stopped()
    func couldNotPlay()
}

class AudioPlayer {
    
    var audioPlayer: AVAudioPlayer?
    var shouldPlay = false
    
    var delegate: AudioPlayerDelegate?
    
    //use these variables to prevent the wrong track from playing (on a slow network, a new download may start before an old one finishes)
    var currentAlbum = -1
    var currentTrack = -1
    
    func playTrack(url: URL, albumIndex: Int, trackIndex: Int) {
        audioPlayer?.stop()
        
        currentAlbum = albumIndex
        currentTrack = trackIndex
        
        DispatchQueue.global(qos: .userInitiated).async {
            //Download audio data
            if let audioData = try? Data(contentsOf: url) {
                
                DispatchQueue.main.async {
                    //make sure the album hasn't changed; (for slow networks)
                    if albumIndex != self.currentAlbum, trackIndex != self.currentTrack {
                        return
                    }
                    
                    do {
                        self.audioPlayer = try AVAudioPlayer(data: audioData)
                        self.audioPlayer?.numberOfLoops = -1
                        self.audioPlayer?.play()
                    } catch {
                        //Could not play track
                        self.delegate?.couldNotPlay()
                    }
                }
            } else {
                //Could not get data
                self.delegate?.couldNotPlay()
            }
        }
        
    }
    
    func play() {
        audioPlayer?.play()
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func stop() {
        audioPlayer?.stop()
    }
    
}



