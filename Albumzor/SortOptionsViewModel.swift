//
//  SortOptionsViewModel.swift
//  Albumzor
//
//  Created by Peter Cerhan on 11/6/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import Foundation
import RxSwift

protocol SortOptionsViewModelDelegate: class {
    
}

class SortOptionsViewModel {
    
    //MARK: - Dependencies
    
    private weak var delegate: SortOptionsViewModelDelegate?
    
    //MARK: - Initialization
    
    init(delegate: SortOptionsViewModelDelegate) {
        self.delegate = delegate
    }
    
    
}
