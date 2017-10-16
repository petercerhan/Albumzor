//
//  DataOperationState.swift
//  Albumzor
//
//  Created by Peter Cerhan on 9/25/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

enum DataOperationState {
    case none
    case operationBegan
    case dataReceived
    case operationCompleted
    case error(Error?)
}
