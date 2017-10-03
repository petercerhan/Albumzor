//
//  SpotifyDelegateProxy.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/2/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

class SpotifyLoginDelegateProxy: SpotifyLoginViewControllerDelegate {
    
    var loginSucceededCallback: (() -> ())?
    var cancelLoginCallback: (() -> ())?
    
    func loginSucceeded() {
        loginSucceededCallback?()
    }
    
    func cancelLogin() {
        cancelLoginCallback?()
    }
    
}
