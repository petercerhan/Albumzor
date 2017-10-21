//
//  ShufflingService.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/21/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import GameKit

protocol ShufflingService {
    func shuffleArray<T>(array: [T]) -> [T]
}

class GameKitShufflingService: ShufflingService {
    
    func shuffleArray<T>(array: [T]) -> [T] {
        return GKRandomSource.sharedRandom().arrayByShufflingObjects(in: array) as! Array<T>
    }
    
}
