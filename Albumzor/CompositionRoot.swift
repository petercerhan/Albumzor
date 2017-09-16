//
//  CompositionRoot.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/16/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

import Foundation
import UIKit

protocol CompositionRootProtocol {
    func composeWindow() -> UIWindow
}

class CompositionRoot: CompositionRootProtocol {
    
    func composeWindow() -> UIWindow {
        return UIWindow(frame: UIScreen.main.bounds)
    }
    
}

