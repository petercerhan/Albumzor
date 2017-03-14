//
//  ViewController.swift
//  Albumzor
//
//  Created by Peter Cerhan on 3/12/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var chilisID = "0L8ExT028jH3ddEcZwqJJ5"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = SpotifyClient.sharedInstance()

        
        client.getAlbums(forArtist: chilisID) {_,_ in 
            
        }
        
        
//        let parameters = [SpotifyClient.ParameterKeys.searchQuery : "Red hot chili peppers", SpotifyClient.ParameterKeys.searchType : "artist"]
//        
//        _ = client.task(getMethod: SpotifyClient.Methods.search, parameters: parameters as [String : AnyObject]) { result, error in
//            
//            if let error = error {
//                print("error: \(error)")
//                return
//            }
//            
//            guard let result = result as? [String : AnyObject], let artists = result["artists"] as? [String : AnyObject], let items = artists["items"] as? [[String : AnyObject]] else {
//                print("Data not formatted correctly")
//                return
//            }
//            
//            for item in items {
//                print("Artist: \(item["name"] as? String ?? "NOT FOUND") id: \(item["id"])")
//            }
//            
//            
//        }
        
        
        
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
