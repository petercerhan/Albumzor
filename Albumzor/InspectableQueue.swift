//
//  InspectableQueue.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/19/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation

struct InspectableQueue<T> {
    
    private var array = [T]()
    
    var count: Int {
        return array.count
    }
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    func elementAt(_ index: Int) -> T? {
        if count > index {
            return array[index]
        } else {
            return nil
        }
    }
    
}

