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
    
    //MARK: - State
    
    let userMarket: Variable<String>!
    let spotifyConnected: Variable<Bool>!
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Initialization
    
    init(remoteDataService: RemoteDataServiceProtocol) {
        self.remoteDataService = remoteDataService
        
        let userProfile: UserProfile
        
        if let data = UserDefaults.standard.object(forKey: "userProfile") as? Data,
            let userProfileLocal = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserProfile {
                userProfile = userProfileLocal
        } else {
            userProfile = UserProfile(userMarket: "None", spotifyConnected: false)
        }
    
        self.userMarket = Variable(userProfile.userMarket)
        self.spotifyConnected = Variable(userProfile.spotifyConnected)
    }
    
    //MARK: - Interface
    
    func fetchUserMarketFromAPI() -> Observable<UserInfo> {
        let infoObservable = remoteDataService.fetchUserInfo()
        infoObservable
            .subscribe(onNext: { [weak self] userInfo in
                guard let userMarket = self?.userMarket else { return }
                userMarket.value = userInfo.userMarket
            })
            .disposed(by: disposeBag)
        
        return infoObservable
    }
    
    //MARK: - Utilities
    
    func reset() {
        
    }
}

