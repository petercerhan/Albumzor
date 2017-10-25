//
//  ObservableType+makeEventTypeOptional.swift
//  Albumzor
//
//  Created by Peter Cerhan on 10/24/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    
    public func makeEventTypeOptional(initialValue: E?) -> Observable<E?> {
        let initialValueObservable = Observable.just(initialValue)
        let currentObservableAsOptional = self.asObservable().map { event -> E? in
            return event
        }
        
        return Observable.of(initialValueObservable, currentObservableAsOptional).merge()
    }
    
    public func makeEventTypeOptional() -> Observable<E?> {
        let currentObservableAsOptional = self.asObservable().map { event -> E? in
            return event
        }
        
        return currentObservableAsOptional
    }
    
}
