//
//  LikedAlbumsStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class LikedAlbumsStateController: AlbumDetailsStateControllerProtocol {
    
    //MARK: - Dependencies
    
    private let localDatabaseService: LocalDatabaseServiceProtocol
    private let remoteDataService: RemoteDataServiceProtocol
    
    //MARK: - State

    private(set) lazy var likedAlbums: Observable<[(AlbumData, Observable<UIImage>?)]?> = {
        return self.likedAlbumsSubject.asObservable()
            .map { [weak self] albumArray -> [(AlbumData, Observable<UIImage>?)]? in
                if albumArray == nil {
                    return nil
                } else {
                    return albumArray!.map { albumData -> (AlbumData, Observable<UIImage>?) in
                        if albumData.smallImageData != nil {
                            return (albumData, nil)
                        } else {
                            return (albumData, self?.remoteDataService.fetchImageFrom(urlString: albumData.smallImage).do(onNext: { [weak self] image in
                                var mutableAlbumData = albumData
                                mutableAlbumData.smallImageData = UIImagePNGRepresentation(image)
                                self?.localDatabaseService.save(album: mutableAlbumData)
                            }))
                        }
                    }
                }
                
            }
            .shareReplay(1)
    }()
    
    private let likedAlbumsSubject = BehaviorSubject<[AlbumData]?>(value: nil)
    
    //MARK: - Album Details State
    
    private(set) lazy var detailsActive: Observable<Bool> = {
        return self.detailsActiveSubject.asObservable().shareReplay(1)
    }()
    
    private let detailsActiveSubject = BehaviorSubject<Bool>(value: false)
    
    private(set) lazy var albumDetails_album: Observable<AlbumData?> = {
        return self.albumDetails_albumSubject.asObservable().shareReplay(1)
    }()
    
    private let albumDetails_albumSubject = BehaviorSubject<AlbumData?>(value: nil)
    
    private(set) lazy var albumDetails_artist: Observable<ArtistData?> = {
        return self.albumDetails_artistSubject.asObservable().shareReplay(1)
    }()
    
    private let albumDetails_artistSubject = BehaviorSubject<ArtistData?>(value: nil)
    
    private(set) lazy var albumDetails_albumArt: Observable<UIImage?> = {
        return self.albumDetails_albumSubject.asObservable()
            .map { albumData -> UIImage? in
                if let albumData = albumData, let imageData = albumData.imageData {
                    return UIImage(data: imageData)
                } else {
                    return nil
                }
            }
            .shareReplay(1)
    }()
    
    private(set) lazy var albumDetails_tracks: Observable<[TrackData]?> = {
        return self.albumDetails_tracksSubject.asObservable().shareReplay(1)
    }()
    
    private let albumDetails_tracksSubject = BehaviorSubject<[TrackData]?>(value: nil)
    
    //MARK: - Rx
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(localDatabaseService: LocalDatabaseServiceProtocol, remoteDataService: RemoteDataServiceProtocol) {
        self.localDatabaseService = localDatabaseService
        self.remoteDataService = remoteDataService
        refreshLikedAlbums()
    }
    
    //MARK: - Interface
    
    //get liked albums and update exposed state
    func refreshLikedAlbums() {
        localDatabaseService.getLikedAlbums()
            .subscribe(onNext: { [unowned self] albumData in
                self.likedAlbumsSubject.onNext(albumData)
            })
            .disposed(by: disposeBag)
    }
    
    func getDetailsForAlbum(albumID: String) {
        localDatabaseService.getAlbumArtistTracks(forAlbumID: albumID)
            .subscribe(onNext: { [unowned self] dataTuple in
                print("Got some album info")
                self.albumDetails_albumSubject.onNext(dataTuple.0)
                self.albumDetails_artistSubject.onNext(dataTuple.1)
                self.albumDetails_tracksSubject.onNext(dataTuple.2)
            })
            .disposed(by: disposeBag)
        
        detailsActiveSubject.onNext(true)
    }
    
    func setDetailsInactive() {
        detailsActiveSubject.onNext(false)
    }
    
    func deleteAlbum(id: String) {
        localDatabaseService.deleteAlbum(id: id)
    }
    
}



















