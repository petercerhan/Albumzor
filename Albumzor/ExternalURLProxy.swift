//
//  ExternalURLProxy.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/15/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

protocol ExternalURLProxy {
    func requestToOpen(url urlString: String)
}

class AppDelegateURLProxy: ExternalURLProxy {
    
    func requestToOpen(url urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
