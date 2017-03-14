//
//  SpotifyConstants.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

extension SpotifyClient {
    
    struct Constants {
        static let apiScheme = "https"
        static let apiHost = "api.spotify.com"
        static let apiPath = "/v1"
        
//        static let jsonContentType = "application/json"
    }
    
    struct Methods {
        static let search = "/search"
        static let getArtistAlbums = "/artists/{id}/albums"
    }
  
    struct ParameterKeys {
        static let searchQuery = "q"
        static let searchType = "type"
    }
    
    struct ParameterValues {
        
    }
    
}
