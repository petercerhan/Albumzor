//
//  AppDelegate.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let coreDataStack = CoreDataStack(modelName: "Model")!
    var dataManager: DataManager!
    var audioPlayer = AudioPlayer()
    //initial/default settings
    var userSettings = UserSettings(instructionsSeen: false, isSeeded: false, autoplay: true, albumSortType: 0)
    var userProfile = UserProfile(userMarket: "None", spotifyConnected: false)
    
    var mainContainerViewController: MainContainerViewController?
    
    var window: UIWindow?

    var compositionRoot: CompositionRootProtocol!
    var mainContainerCoordinator: MainContainerCoordinator!
    var spotifyAuthStateController: SpotifyAuthStateController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        compositionRoot = CompositionRoot()
        
        spotifyAuthStateController = compositionRoot.composeSpotifyAuthStateController()
        
        mainContainerCoordinator = compositionRoot.composeMainCoordinator()
        mainContainerCoordinator.start()
        
        print("Spotify login state is \(spotifyAuthStateController.sessionIsValid)")
        
        window = compositionRoot.composeWindow()
        
        window?.rootViewController = mainContainerCoordinator.mainContainerViewController
        window?.makeKeyAndVisible()
        
        
        //This will go away
        //disconnectSpotify()
        SpotifyAuthManager().configureSpotifyAuth()
        //
        
        loadUserProfile()
        
        dataManager = DataManager()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SpotifyAuthManager().open(url)
    }

}

//MARK: - Manage user settings

extension AppDelegate {
    
    func disconnectSpotify() {
        SpotifyAuthManager().deleteSession();
        UserDefaults.standard.removeObject(forKey: "SpotifySession")
    }
    
    func deleteUserProfile() {
        UserDefaults.standard.removeObject(forKey: "userProfile")
    }
    
    func testForObject() {
        if UserDefaults.standard.object(forKey: "SpotifySession") == nil {
            print("did not find")
        } else {
            print("found")
        }
    }
    
    func loadUserSettings() {
        if let data = UserDefaults.standard.object(forKey: "userSettings") as? Data,
            let userSettings = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserSettings {
            
            self.userSettings = userSettings
        } else {
            
        }
    }
    
    func saveUserSettings() {
        let data = NSKeyedArchiver.archivedData(withRootObject: userSettings)
        UserDefaults.standard.set(data, forKey: "userSettings")
    }
    
    func loadUserProfile() {
        if let data = UserDefaults.standard.object(forKey: "userProfile") as? Data,
            let userProfile = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserProfile {
            
            self.userProfile = userProfile
        } else {
            
        }
    }
    
    func saveUserProfile() {
        let data = NSKeyedArchiver.archivedData(withRootObject: userProfile)
        UserDefaults.standard.set(data, forKey: "userProfile")
    }
    
    func resetUserProfile() {
        userProfile = UserProfile(userMarket: "None", spotifyConnected: false)
        saveUserProfile()
    }
}




