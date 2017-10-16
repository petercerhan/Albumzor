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
    func configureUserMarket(market: String)
    func fetchUserInfo() -> Observable<UserInfo>
    func fetchArtistInfo(artistName: String) -> Observable<ArtistData>
    func fetchImageFrom(urlString: String) -> Observable<UIImage>
    func fetchRelatedArtists(id: String) -> Observable<[ArtistData]>
    func fetchArtistAlbums(id: String) -> Observable<[AbbreviatedAlbumData]>
    func fetchAlbumDetails(albums: [AbbreviatedAlbumData]) -> Observable<[AlbumData]>
}

class SpotifyRemoteDataService: RemoteDataServiceProtocol {
    
    //MARK: - Dependencies

    let session: URLSession
    let authService: SpotifyAuthManager
    
    //MARK: - State
    
    var userMarket: String = "us"
    
    //MARK: - Initialization
    
    init(session: URLSession, authService: SpotifyAuthManager) {
        self.session = session
        self.authService = authService
    }
    
    //MARK: - Other Interface Methods
    
    func configureUserMarket(market: String) {
        userMarket = market
    }

    //MARK: - Spotify API Methods
    
    func fetchUserInfo() -> Observable<UserInfo> {
        let endpoint = Endpoint.userProfile
        let queryItems = [URLQueryItem]()
        
        let userInfoStream = assembleRequest(endpoint: endpoint, queryItems: queryItems)
            .map { jsonDictionary -> UserInfo in
                guard let userInfo = UserInfo(dictionary: jsonDictionary) else {
                    throw NetworkRequestError.invalidData
                }
                return userInfo
            }
            .shareReplay(1)
        
        return userInfoStream
    }
    
    func fetchArtistInfo(artistName: String) -> Observable<ArtistData> {
        let endpoint = Endpoint.search
        let queryItems = [URLQueryItem(name: ParameterKeys.searchQuery, value: artistName),
                          URLQueryItem(name: ParameterKeys.searchType, value: "artist")]
        
        let artistInfoStream = assembleRequest(endpoint: endpoint, queryItems: queryItems)
            .map { jsonDictionary -> [String: Any] in
                guard let resultsDict = jsonDictionary["artists"] as? [String: Any],
                    let resultsArray = resultsDict["items"] as? [[String: Any]],
                    resultsArray.count > 0 else
                {
                    throw NetworkRequestError.invalidData
                }
                return resultsArray[0]
            }
            .map { jsonDictionary -> ArtistData in
                guard let artistData = ArtistData(dictionary: jsonDictionary),
                    let _ = artistData.imageURL else
                {
                    throw NetworkRequestError.invalidData
                }
                return artistData
            }
            .shareReplay(1)
        
        return artistInfoStream
    }
    
    func fetchRelatedArtists(id: String) -> Observable<[ArtistData]> {
        let endpoint = Endpoint.relatedArtists
        let relatedArtistsStream = assembleRequest(endpoint: endpoint, queryItems: nil, associatedID: id)
            .map { jsonDictionary -> [[String: Any]] in
                guard let result = jsonDictionary["artists"] as? [[String: Any]] else {
                    throw NetworkRequestError.invalidData
                }
                return result
            }
            .map { jsonObjectArray -> [ArtistData] in
                return jsonObjectArray.flatMap({ArtistData.init(dictionary: $0)})
            }
            .shareReplay(1)

        return relatedArtistsStream
    }
    
    func fetchArtistAlbums(id: String) -> Observable<[AbbreviatedAlbumData]> {
        let endpoint = Endpoint.artistAlbums
        let queryItems = [URLQueryItem(name: ParameterKeys.album_type, value: "album"),
                          URLQueryItem(name: ParameterKeys.market, value: userMarket)]
 
        let artistAlbumsStream = assembleRequest(endpoint: endpoint, queryItems: queryItems, associatedID: id)
            .map { jsonDictionary -> [[String: Any]] in
                guard let result = jsonDictionary["items"] as? [[String: Any]] else {
                    throw NetworkRequestError.invalidData
                }
                return result
            }
            .map { jsonObjectArray -> [AbbreviatedAlbumData] in
                return jsonObjectArray.flatMap({AbbreviatedAlbumData.init(jsonDictionary: $0)})
            }
            .shareReplay(1)
        
        return artistAlbumsStream
    }
    
    func fetchAlbumDetails(albums: [AbbreviatedAlbumData]) -> Observable<[AlbumData]> {
        //prepare string of album ids for Spotify query
        var idString = albums.reduce("") { (currentString, album) in
            return currentString + album.id + ","
        }
        if idString != "" {
            idString.remove(at: idString.index(before: idString.endIndex))
        }
        
        //build query
        let endpoint = Endpoint.albumDetails
        let queryItems = [URLQueryItem(name: "ids", value: idString),
                          URLQueryItem(name: ParameterKeys.market, value: userMarket)]
        
        let albumDetailsStream = assembleRequest(endpoint: endpoint, queryItems: queryItems)
            .map { jsonDictionary -> [[String: Any]] in
                guard let result = jsonDictionary["albums"] as? [[String: Any]] else {
                    throw NetworkRequestError.invalidData
                }
                return result
            }
            .map { jsonObjectArray -> [AlbumData] in
                return jsonObjectArray.flatMap({AlbumData.init(jsonDictionary: $0)})
            }
            .shareReplay(1)
        
        return albumDetailsStream
    }

    //MARK: - Generic Methods
    
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
    
    //MARK: - Request Assembly
    
    private func assembleRequest(endpoint: Endpoint, queryItems: [URLQueryItem]?, associatedID: String? = nil) -> Observable<[String: Any]> {
        let response = Observable<URL?>.of(assembleURL(endpoint: endpoint, queryItems: queryItems, id: associatedID))
            .map { url -> URL in
                if let url = url {
                    return url
                } else {
                    throw NetworkRequestError.invalidURL
                }
            }
            .map { [weak self] url -> URLRequest in
                var request = URLRequest(url: url)
                if let token = self?.authService.getToken() {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    throw NetworkRequestError.notAuthenticated
                }
                return request
            }
            .flatMap { [weak self] request -> Observable<(HTTPURLResponse, Data)> in
                if let responseStream = self?.session.rx.response(request: request) {
                    return responseStream
                } else {
                    throw NetworkRequestError.connectionFailed
                }
            }
            .catchError { error in
                switch error {
                case NetworkRequestError.notAuthenticated:
                    throw NetworkRequestError.notAuthenticated
                default:
                    throw NetworkRequestError.connectionFailed
                }
            }
            .map { response, data -> Data in
                if 200..<300 ~= response.statusCode {
                    return data
                } else {
                    throw NetworkRequestError.connectionFailed
                }
            }
            .map { data -> [String: Any] in
                guard let result = try? JSONSerialization.jsonObject(with: data, options: []), let jsonObject = result as? [String: Any] else {
                    throw NetworkRequestError.invalidData
                }
                return jsonObject
            }
        
        return response
    }
    
    private func assembleURL(endpoint endpointIn: Endpoint, queryItems: [URLQueryItem]? = nil, id: String? = nil) -> URL? {
        var endpoint = endpointIn.rawValue
        if let id = id {
            endpoint = endpoint.replacingOccurrences(of: "{id}", with: id)
        }
        
        var components = URLComponents()
        components.scheme = API_Values.apiScheme
        components.host = API_Values.apiHost
        components.path = API_Values.apiPath + endpoint
        components.queryItems = queryItems
        
        return components.url
    }
    
    //MARK: - Reference values
    
    enum Endpoint: String {
        case search = "/search"
        case userProfile = "/me"
        case relatedArtists = "/artists/{id}/related-artists"
        case artistAlbums = "/artists/{id}/albums"
        case albumDetails = "/albums"
    }
    
    struct Endpoints {
        static let search = "/search"
        static let getArtistAlbums = "/artists/{id}/albums"
        static let getRelatedArtists = "/artists/{id}/related-artists"
        static let getAlbums = "/albums"
        static let getAlbumTracks = "/albums/{id}/tracks"
        static let getTracks = "/tracks"
        static let getUserInfo = "/me"
    }
    
    struct API_Values {
        static let apiScheme = "https"
        static let apiHost = "api.spotify.com"
        static let apiPath = "/v1"
    }
    
    struct ParameterKeys {
        static let searchQuery = "q"
        static let searchType = "type"
        static let album_type = "album"
        static let market = "market"
    }
    
    struct ParameterValues {
        
    }
    
    
}
