//
//  ITunesLibraryService.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/26/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift
import MediaPlayer
import GameKit

protocol MediaLibraryServiceProtocol {
    func fetchArtistsFromMediaLibrary() -> Observable<[String]>
}

class ITunesLibraryService: MediaLibraryServiceProtocol {
    
    func fetchArtistsFromMediaLibrary() -> Observable<[String]> {
        
        return Observable.create( { (observer) -> Disposable in
            
            DispatchQueue.global(qos: .userInitiated).async {
                var artists = self.getArtistsFromItunes() ?? ChooseArtistViewController.defaultArtists
                
                artists = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: artists) as! Array<String>
                
                observer.onNext(artists)
                observer.onCompleted()
            }
            
            return Disposables.create()
        })
        
    }
    
    func getArtistsFromItunes() -> [String]? {
        let artistQuery = MPMediaQuery.artists()
        
        guard let mediaItemsArray = artistQuery.items else {
            return nil
        }
        
        let rawArtistNames = mediaItemsArray.map { mediaItem in return mediaItem.albumArtist ?? "" }
        var artistSet = Set(rawArtistNames)
        let emptyStringSet: Set = ["", " "]
        artistSet = artistSet.subtracting(emptyStringSet)
        
        var namesArray = Array(artistSet)
        namesArray = namesArray.map { artistName in return artistName.cleanArtistName() }
        namesArray = namesArray.map { artistName in return artistName.truncated(maxLength: 30) }
        
        //Remove any new duplicates after cleaning up artist names
        namesArray = Array(Set(namesArray))
        
        if namesArray.count < 15 {
            return nil
        } else {
            return namesArray
        }
    }
    
    
}
