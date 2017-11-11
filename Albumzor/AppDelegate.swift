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

//    let coreDataStack = CoreDataStack(modelName: "Model")!
//    var audioPlayer = AudioPlayer()
    
    var window: UIWindow?

    var compositionRoot: CompositionRootProtocol!
    var rootCoordinator: RootCoordinator!
    
    //Mark: - Rx
    //Dev
    let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        compositionRoot = CompositionRoot()
        rootCoordinator = compositionRoot.composeRootCoordinator()
        rootCoordinator.start()
        
        window = compositionRoot.composeWindow()
        
        window?.rootViewController = rootCoordinator.containerViewController
        window?.makeKeyAndVisible()
        
        //Get albums count
        compositionRoot.localDatabaseService
            .countUnseenAlbums()
            .subscribe(onNext: { print("Total unseen albums \($0)") })
            .disposed(by: disposeBag)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SpotifyAuthManager().open(url)
    }
    
}
