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
    
    var window: UIWindow?
    var compositionRoot: CompositionRootProtocol!
    var rootCoordinator: RootCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        compositionRoot = CompositionRoot()
        rootCoordinator = compositionRoot.composeRootCoordinator()
        rootCoordinator.start()
        
        window = compositionRoot.composeWindow()
        
        window?.rootViewController = rootCoordinator.containerViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SpotifyAuthManager().open(url)
    }
    
}
