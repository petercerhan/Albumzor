//
//  ObservableType+nextEventsOnly.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/21/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    
    public func nextEventsOnly() -> Observable<E> {
        return self.asObservable().materialize()
            .filter { event in
                switch event {
                case .next:
                    return true
                default:
                    return false
                }
            }
            .dematerialize()
    }
    
}
