//
//  SpotifyRemoteDataService.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/23/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol RemoteDataServiceProtocol {
    func fetchUserInfo() -> Observable<UserInfo>
}

class SpotifyRemoteDataService: RemoteDataServiceProtocol {
    
    //MARK: - Dependencies
    
    //TODO: Inject
    let session = URLSession.shared
    let authService = SpotifyAuthManager()
    
    
    func fetchUserInfo() -> Observable<UserInfo> {
        let endpoint = "https://api.spotify.com/v1/me"
        
        let response = Observable.from([endpoint])
            .map { urlString -> URL in
                return URL(string: urlString)!
            }
            .map { [weak self] url -> URLRequest in
                var request = URLRequest(url: url)
                if let token = (self?.authService.getToken()) {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                return request
            }
            .flatMap { [weak self] request -> Observable<(HTTPURLResponse, Data)> in
                return self!.session.rx.response(request: request)
            }
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [String: Any] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                    let result = jsonObject as? [String: AnyObject] else {
                        return [:]
                }
                return result
            }
            .map { jsonDictionary -> UserInfo in
                return UserInfo(dictionary: jsonDictionary)!
            }
        
        return response
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
