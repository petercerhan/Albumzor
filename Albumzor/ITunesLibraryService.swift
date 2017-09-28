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
                var artists = self.getArtistsFromItunes() ?? ITunesLibraryService.defaultArtists
                
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

//MARK:- Default Suggested Seed Artists

extension ITunesLibraryService {
    
    static let defaultArtists = ["Radiohead",
                                 "Elliott Smith",
                                 "Nick Drake",
                                 "Pixies",
                                 "Faith No More",
                                 "The Smashing Pumpkins",
                                 "Weezer",
                                 "Pixies",
                                 "Alice in Chains",
                                 "Sufjan Stevens",
                                 "Bon Iver",
                                 "Wilco",
                                 "Yo La Tengo",
                                 "Pavement",
                                 "Red Hot Chili Peppers",
                                 "Nine Inch Nails",
                                 "Bjork",
                                 "Wu-Tang Clan",
                                 "Nas",
                                 "DJ Shadow",
                                 "Mobb Deep",
                                 "Public Enemy",
                                 "Beastie Boys",
                                 "Rage Against The Machine",
                                 "Kendrick Lamar",
                                 "OutKast",
                                 "Kanye West",
                                 "Jay-Z",
                                 "The Pharcyde",
                                 "Lauryn Hill",
                                 "Mos Def",
                                 "Nujabes",
                                 "Run the Jewels",
                                 "Public Enemy",
                                 "Miles Davis",
                                 "Charles Mingus",
                                 "John Coltrane",
                                 "Nina Simone",
                                 "Frank Sinatra",
                                 "A Tribe Called Quest",
                                 "Aretha Franklin",
                                 "Bob Marley",
                                 "Tom Waits",
                                 "Sade",
                                 "Norah Jones",
                                 "Duke Ellington",
                                 "Megadeth",
                                 "Black Sabbath",
                                 "Judas Priest",
                                 "Iron Maiden",
                                 "Metallica",
                                 "Megadeth",
                                 "The Beatles",
                                 "The Beach Boys",
                                 "Queen",
                                 "Prince",
                                 "Depeche Mode",
                                 "Fleetwood Mac",
                                 "No Doubt",
                                 "The Kinks",
                                 "Simon and Garfunkel",
                                 "Eminem",
                                 "Boston",
                                 "Elvis Presley",
                                 "U2",
                                 "Yes",
                                 "Megadeth",
                                 "David Bowie",
                                 "The Cure",
                                 "The Clash",
                                 "Talking Heads",
                                 "Dead Kennedys",
                                 "Streetlight Manifesto",
                                 "Pink Floyd",
                                 "The Jimi Hendrix Experience",
                                 "Led Zeppelin",
                                 "Bob Dylan",
                                 "The Doors",
                                 "Bruce Springsteen",
                                 "The Who",
                                 "The Velvet Underground",
                                 "Frank Zappa",
                                 "Lynyrd Skynyrd",
                                 "The Band",
                                 "Creedence Clearwater Revival",
                                 "Chuck Berry",
                                 "Frederic Chopin",
                                 "Beethoven",
                                 "Mozart",
                                 "Tchaikovsky",
                                 "Adele",
                                 "Lady Gaga",
                                 "Beyonce",
                                 "Shania Twain",
                                 "Megadeth",
                                 "Rihanna",
                                 "Taylor Swift",
                                 "Drake",
                                 "Lil Wayne",
                                 "Katy Perry",
                                 "Amy Winehouse",
                                 "Michael Jackson",
                                 "The Rolling Stones",
                                 "Guns n' Roses",
                                 "Stevie Wonder",
                                 "Drake",
                                 "Alicia Keys",
                                 "Patti Smith",
                                 "Grateful Dead",
                                 "AC/DC",
                                 "Fleetwood Mac",
                                 "P!nk"]
}

