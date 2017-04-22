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
    
    var currentLoadSignature = 0
    
    var delegate: AudioPlayerDelegate?
    
    func playTrack(url: URL) {
        audioPlayer?.stop()
        
        incrementLoadSignature()
        let thisLoadSignature = currentLoadSignature

        DispatchQueue.global(qos: .userInitiated).async {
            //Download audio data
            if let audioData = try? Data(contentsOf: url) {
                
                DispatchQueue.main.async {
                    //only play most recently loaded song
                    if thisLoadSignature != self.currentLoadSignature {
                        return
                    }
                    
                    do {
                        self.audioPlayer = try AVAudioPlayer(data: audioData)
                        self.audioPlayer?.numberOfLoops = -1
                        print("this load signature: \(thisLoadSignature)")
                        self.audioPlayer?.play()
                        self.delegate?.beganPlaying()
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
        self.delegate?.beganPlaying()
    }
    
    func pause() {
        audioPlayer?.pause()
        self.delegate?.paused()
    }
    
    func stop() {
        audioPlayer?.stop()
        incrementLoadSignature()
        self.delegate?.stopped()
    }
    
    func incrementLoadSignature() {
        currentLoadSignature += 1
        print("New loadSignature \(currentLoadSignature)")
    }
    
}



