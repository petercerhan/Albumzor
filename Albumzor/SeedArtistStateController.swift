//
//  SeedArtistStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/26/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class SeedArtistStateController {
    
    //MARK: - Dependencies
    
    private let mediaLibraryService: MediaLibraryServiceProtocol
    private let remoteDataService: RemoteDataServiceProtocol
    
    //MARK: - State
    
    let seedArtists = Variable<[String]>([])
    let searchActive = Variable<Bool>(false)
    let confirmationActive = Variable<Bool>(false)
    let confirmationArtistName = Variable<String?>(nil)
    
    let loadConfirmArtistState = Variable<DataOperationState>(.none)
    let confirmArtistData = Variable<ArtistData?>(nil)
    
    let loadConfirmArtistImageOperationState = Variable<DataOperationState>(.none)
    let confirmArtistImage = Variable<UIImage?>(nil)
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()

    //MARK: - Initialization
    
    init(mediaLibraryService: MediaLibraryServiceProtocol, remoteDataService: RemoteDataServiceProtocol) {
        self.mediaLibraryService = mediaLibraryService
        self.remoteDataService = remoteDataService
    }

    //MARK: - Interface
    
    func fetchSeedArtistsFromMediaLibrary() {
        mediaLibraryService.fetchArtistsFromMediaLibrary()
            .subscribe(onNext: { [unowned self] artists in
                self.seedArtists.value = artists
            })
            .disposed(by: disposeBag)
    }
    
    func customArtistSearch(showSearch: Bool) {
        searchActive.value = showSearch
    }
    
    func searchArtistForConfirmation(artistString: String) {
        
        loadConfirmArtistState.value = .operationBegan
        confirmationArtistName.value = artistString
        confirmationActive.value = true
        
        let artistObservable = remoteDataService.fetchArtistInfo(artistName: artistString)
        
        artistObservable
            .subscribe(onNext: { [unowned self] artistData in
                self.confirmArtistData.value = artistData
                //fetchArtistInfo method validates that an imageURL exists. It is conceivable that an artist could not have images; that artist would come up as unfound in the spotify service as currently written
                self.fetchImageFrom(urlString: artistData.imageURL!)
            })
            .disposed(by: disposeBag)
        
        artistObservable.map {_ -> Void in}
            .subscribe(onError: { [unowned self] error in
                self.loadConfirmArtistState.value = .error
            }, onCompleted: { [unowned self] in
                self.loadConfirmArtistState.value = .operationCompleted
                self.loadConfirmArtistState.value = .none
            })
            .disposed(by: disposeBag)
    }
    
    func fetchImageFrom(urlString: String) {
        loadConfirmArtistImageOperationState.value = .operationBegan
        
        let imageObservable = remoteDataService.fetchImageFrom(urlString: urlString)
        
        imageObservable
            .subscribe(onNext: { [unowned self] image in
                self.confirmArtistImage.value = image
            })
            .disposed(by: disposeBag)
        
        imageObservable.map { _ -> Void in }
            .subscribe(onError: { [unowned self] error in
                self.loadConfirmArtistImageOperationState.value = .error
            }, onCompleted: { [unowned self] in
                self.loadConfirmArtistImageOperationState.value = .operationCompleted
                self.loadConfirmArtistImageOperationState.value = .none
            })
            .disposed(by: disposeBag)
    }

}


