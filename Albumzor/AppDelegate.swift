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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = MainContainerViewController()
        mainContainerViewController = vc
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        //deleteSession()
        SpotifyAuthManager().configureSpotifyAuth()
        loadUserProfile()
        
        dataManager = DataManager()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SpotifyAuthManager().open(url)
    }    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

//MARK: - Manage user settings

extension AppDelegate {
    
    func disconnectSpotify() {
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




