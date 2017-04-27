//
//  AppDelegate.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//test

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let coreDataStack = CoreDataStack(modelName: "Model")!
    var dataManager: DataManager!
    var audioPlayer = AudioPlayer()
    //initial/default settings
    var userSettings = UserSettings(instructionsSeen: false, isSeeded: false, autoplay: true)
    
    var mainContainerViewController: MainContainerViewController?
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let vc = MainContainerViewController()
        mainContainerViewController = vc
        
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        dataManager = DataManager()
        
        if let data = UserDefaults.standard.object(forKey: "userSettings") as? Data,
            let userSettings = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserSettings {
                print("user settings")
                print("user settings isSeeded: \(userSettings.isSeeded), instructionsSeen:\(userSettings.instructionsSeen)")
             self.userSettings = userSettings
        }
        
//        do {
//            try coreDataStack.dropAllData()
//        } catch {
//            print("Could not reset data model")
//        }
//        userSettings = UserSettings(instructionsSeen: false, isSeeded: false, autoplay: false)
//        saveUserSettings()
        
        return true
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
    func saveUserSettings() {
        let data = NSKeyedArchiver.archivedData(withRootObject: userSettings)
        UserDefaults.standard.set(data, forKey: "userSettings")
    }
}

