//
//  UserProfileStateController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/17/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class UserProfileStateController {
    
    //MARK: - Dependencies
    
    private let remoteDataService: RemoteDataServiceProtocol
    private let archiveService: ArchivingServiceProtocol
    
    //MARK: - State
    
    let userMarket: Variable<String>!
    let spotifyConnected: Variable<Bool>!
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(remoteDataService: RemoteDataServiceProtocol, archiveService: ArchivingServiceProtocol) {
        self.remoteDataService = remoteDataService
        self.archiveService = archiveService
        
        let userProfile = archiveService.unarchiveObject(forKey: "userProfile") as? UserProfile ?? UserProfile()
        
        self.userMarket = Variable(userProfile.userMarket)
        self.spotifyConnected = Variable(userProfile.spotifyConnected)
    }
    
    //MARK: - Interface
    
    func fetchUserMarketFromAPI() -> Observable<Void> {
        let infoObservable = remoteDataService.fetchUserInfo()
        infoObservable
            .subscribe(onNext: { userInfo in
                self.userMarket.value = userInfo.userMarket
                
                let userProfile = UserProfile(userMarket: self.userMarket.value, spotifyConnected: self.spotifyConnected.value)
                self.archiveService.archive(object: userProfile, forKey: "userProfile")
            })
            .disposed(by: disposeBag)
        
        return infoObservable.map { userInfo -> () in }
    }
    
    func setSpotifyConnected() {
        spotifyConnected.value = true
        let userProfile = UserProfile(userMarket: userMarket.value, spotifyConnected: spotifyConnected.value)
        self.archiveService.archive(object: userProfile, forKey: "userProfile")
    }
    
    //MARK: - Utilities
    
    func reset() {
        let userProfile = UserProfile()
        userMarket.value = userProfile.userMarket
        spotifyConnected.value = userProfile.spotifyConnected
        archiveService.archive(object: userProfile, forKey: "userProfile")
    }
}

