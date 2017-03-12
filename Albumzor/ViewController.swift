//
//  ViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = SpotifyClient.sharedInstance()
        
        let parameters = [SpotifyClient.ParameterKeys.searchQuery : "Red+Hot+Chili+Peppers", SpotifyClient.ParameterKeys.searchType : "artist"]
        
        _ = client.task(getMethod: SpotifyClient.Methods.search, parameters: parameters as [String : AnyObject]) { results, error in
            
            if let error = error {
                print("")
            }
            
        }
        
        
        
    }
    
    
    func getSpotifyAPIKey() -> String? {
        
        let filePath = Bundle.main.path(forResource: "SpotifyApiKey", ofType: "txt")

        print("file path: \(filePath)")
        
        do {
            let textString = try String(contentsOfFile: filePath!)
            return textString
        } catch {
            print("error reading file to string")
        }
        
        return nil
    }
    

}
