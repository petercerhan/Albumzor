//
//  AppDelegate.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit
import RxSwift

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
    var rootCoordinator: RootCoordinator!
    
    var authStateController: AuthStateController!
    
    
    //Mark: - Rx
    //For dev purposes
    let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Reset "User settings"
//        resetUserSettings()
        
        //Reset Database
//        let coreDataUtilityService = CoreDataService(coreDataStack: CoreDataStack(modelName: "Model")!)
//        coreDataUtilityService.resetDatabase()
        
        compositionRoot = CompositionRoot()
        
        authStateController = compositionRoot.composeAuthStateController()
        //
//        authStateController.deleteSession()
        //
        
        rootCoordinator = compositionRoot.composeRootCoordinator()
        rootCoordinator.start()
        
        window = compositionRoot.composeWindow()
        
        window?.rootViewController = rootCoordinator.containerViewController
        window?.makeKeyAndVisible()
        
        dataManager = DataManager()
        
        //Get albums count
//        mainContainerCoordinator.seedArtistStateController.localDBService
//            .countUnseenAlbums()
//            .subscribe(onNext: { print("Total unseen albums \($0)") })
//            .disposed(by: disposeBag)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SpotifyAuthManager().open(url)
    }
    
    //MARK: - Dev Utilities
    func resetUserSettings() {
        let userSettingsController = UserSettingsStateController(archiveService: UserDefaultsArchivingService())
        userSettingsController.reset()
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




