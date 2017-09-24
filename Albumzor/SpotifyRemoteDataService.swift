//
//  SpotifyRemoteDataService.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol RemoteDataServiceProtocol {
    func fetchUserInfo() -> Observable<UserInfo>
}

class SpotifyRemoteDataService: RemoteDataServiceProtocol {
    
    func fetchUserInfo() -> Observable<UserInfo> {
        let endpoint = ""
        
        
        
        
        return Observable<UserInfo>.just(UserInfo(userMarket: "Test User Market"))
    }
    
    
    
    
    
    
    struct Constants {
        static let apiScheme = "https"
        static let apiHost = "api.spotify.com"
        static let apiPath = "/v1"
    }
    
    struct Methods {
        static let search = "/search"
        static let getArtistAlbums = "/artists/{id}/albums"
        static let getRelatedArtists = "/artists/{id}/related-artists"
        static let getAlbums = "/albums"
        static let getAlbumTracks = "/albums/{id}/tracks"
        static let getTracks = "/tracks"
        static let getUserInfo = "/me"
    }
    
    struct ParameterKeys {
        static let searchQuery = "q"
        static let searchType = "type"
    }
    
    struct ParameterValues {
        
    }
    
    
}
