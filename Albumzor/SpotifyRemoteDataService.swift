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
    func fetchArtistInfo(artistName: String) -> Observable<ArtistData?>
    func fetchImageFrom(urlString: String) -> Observable<UIImage>
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
            .shareReplay(1)
        
        return response
    }
    
    func fetchArtistInfo(artistName: String) -> Observable<ArtistData?> {
        let endpoint = "search"
        
        let response = Observable.from([endpoint])
            .map { enpoint -> URL in
                var components = URLComponents()
                components.scheme = API_Values.apiScheme
                components.host = API_Values.apiHost
                components.path = API_Values.apiPath + Methods.search
                
                let searchQueryItem = URLQueryItem(name: ParameterKeys.searchQuery, value: artistName)
                let searchTypeQueryItem = URLQueryItem(name: ParameterKeys.searchType, value: "artist")
                components.queryItems = [searchQueryItem, searchTypeQueryItem]
                
                return components.url!
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
            .map { dataDictionary -> [String: Any] in
                guard let resultsDict = dataDictionary["artists"] as? [String: Any],
                    let resultsArray = resultsDict["items"] as? [[String: Any]],
                    resultsArray.count > 0 else
                {
                    return [:]
                }
                return resultsArray[0]
            }
            .map { jsonDictionary -> ArtistData? in
                return ArtistData(dictionary: jsonDictionary)
            }
            .shareReplay(1)
      
        return response
    }

   
    func fetchImageFrom(urlString: String) -> Observable<UIImage> {
        
        guard let url = URL(string: urlString) else {
            return Observable<UIImage>.empty()
        }
        
        let observable = Observable<UIImage>.create { (observer) -> Disposable in
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url),
                    let image = UIImage(data: imageData) {
                        observer.onNext(image)
                        observer.onCompleted()
                } else {
                    observer.onError(NetworkRequestError.connectionFailed)
                }
            }
            return Disposables.create()
        }
        .shareReplay(1)
        
        return observable
    }
    
    
    //MARK: - Reference values
    
    struct API_Values {
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
