//
//  LikedAlbumsStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/4/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class LikedAlbumsStateController {
    
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
                            return (albumData, self?.remoteDataService.fetchImageFrom(urlString: albumData.smallImage))
                        }
                    }
                }
                
            }
            .shareReplay(1)
    }()
    
    private let likedAlbumsSubject = BehaviorSubject<[AlbumData]?>(value: nil)
    
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
    
}

