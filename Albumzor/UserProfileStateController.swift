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
    
    let apiService: SpotifyClient
    
    let remoteDataService: RemoteDataServiceProtocol
    
    //MARK: - State
    
    private let userProfile: UserProfile
    
    //MARK: - Initialization
    
    init(apiService: SpotifyClient, remoteDataService: RemoteDataServiceProtocol) {
        self.apiService = apiService
        self.remoteDataService = remoteDataService
        
        if let data = UserDefaults.standard.object(forKey: "userProfile") as? Data,
            let userProfile = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserProfile {
                self.userProfile = userProfile
        } else {
            userProfile = UserProfile(userMarket: "None", spotifyConnected: false)
        }
    }
    
    //MARK: - Observables..
    
    
    
    //MARK: - State getters
    
    func getUserMarket() -> String {
        return userProfile.userMarket
    }
    
    func spotifyIsConnected() -> Bool {
        return userProfile.spotifyConnected
    }
    
    //MARK: - Interface
    
    func fetchUserMarketFromAPI() {
        print("Get user market SC")
        
        let infoObservable = remoteDataService.fetchUserInfo()
        infoObservable.subscribe(onNext: { print("result \($0)")})
        
    }
    
    func priorNetworkImplementation() {
        
        apiService.getUserInfo() { result, error in
            
            if let _ = error {
                DispatchQueue.main.async {
                    print("Networking Error")
                }
            } else {
                guard let result = result as? [String : AnyObject], let market = result["country"] as? String else {
                    DispatchQueue.main.async {
                        print("Bad data error")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    print("User info: \(result)")
                    print("Market found: \(market)")
                }
            }
            
        }
    }
    
    //MARK: - Utilities
    
    func reset() {
        userProfile.userMarket = "None"
        userProfile.spotifyConnected = false
    }
}

