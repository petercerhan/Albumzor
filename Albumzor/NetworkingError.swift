//
//  NetworkingError.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/1/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

enum NetworkRequestError: Error {
    case connectionFailed
    case invalidData
}

