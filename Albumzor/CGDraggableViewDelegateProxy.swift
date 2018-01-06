//
//  CGDraggableViewDelegateProxy.swift
//  Albumzor
//
//  Created by Peter Cerhan on 1/5/18.
//  Copyright © 2018 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

class CGDraggableViewDelegateProxy: CGDraggableViewDelegate {
    
    //MARK: - Observable Events
    
    private let swipeBeganSubject = PublishSubject<Void>()
    
    private(set) lazy var swipeBeganObservable: Observable<Void> = {
        return self.swipeBeganSubject.asObservable()
    }()
    
    private let swipeCanceledSubject = PublishSubject<Void>()
    
    private(set) lazy var swipeCanceledObservable: Observable<Void> = {
        return self.swipeCanceledSubject.asObservable()
    }()
    
    private let swipeCompleteSubject = PublishSubject<SwipeDirection>()
    
    private(set) lazy var swipeCompleteObservable: Observable<SwipeDirection> = {
        return self.swipeCompleteSubject.asObservable()
    }()
    
    private let tappedSubject = PublishSubject<Void>()
    
    private(set) lazy var tappedObservable: Observable<Void> = {
        return self.tappedSubject.asObservable()
    }()
    
    
    //MARK: - Delegate Methods
    
    func swipeBegan() {
        swipeBeganSubject.onNext()
    }
    
    func swipeCanceled() {
        swipeCanceledSubject.onNext()
    }
    
    func swipeComplete(direction: SwipeDirection) {
        swipeCompleteSubject.onNext(direction)
    }
    
    func tapped() {
        tappedSubject.onNext()
    }
    
}
