//
//  Coordinator.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/2/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

protocol Coordinator {
    var containerViewController: UIViewController { get }
    func start()
}
