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
    
    let mediaLibraryService: MediaLibraryServiceProtocol
    
    //MARK: - State
    
    let seedArtists = Variable<[String]>([])
    
    //MARK: - Rx
    
    let disposeBag = DisposeBag()

    //MARK: - Initialization
    
    init(mediaLibraryService: MediaLibraryServiceProtocol) {
        self.mediaLibraryService = mediaLibraryService
    }

    //MARK: - Interface
    
    func fetchSeedArtistsFromMediaLibrary() {
        mediaLibraryService.fetchArtistsFromMediaLibrary()
            .subscribe(onNext: { [unowned self] artists in
                self.seedArtists.value = artists
            })
            .disposed(by: disposeBag)
    }
    
}
