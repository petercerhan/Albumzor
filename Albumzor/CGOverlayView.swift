//
//  CGOverlayView.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/1/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class CGOverlayView: UIView {
    
    var mode: SwipeDirection = .none {
        didSet {
            if mode != oldValue {
                if mode == .left {
                    label.text = "left"
                } else {
                    label.text = "right"
                }
            }
        }
    }
    
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22.0)
        label.text = "Long Sentence"
        label.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        label.sizeToFit()
        addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
}
