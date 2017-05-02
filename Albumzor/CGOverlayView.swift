//
//  CGOverlayView.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/1/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//

import UIKit

class CGOverlayView: UIView {
    
    var imageView: UIImageView
    
    var mode: SwipeDirection = .none {
        didSet {
            if mode != oldValue {
                if mode == .left {
                    configureForDislike()
                } else {
                    configureForLike()
                }
            }
        }
    }
    
    var label: UILabel!
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80.0, height: 80.0))
        super.init(frame: frame)
        
        imageView.center = center
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView()
        super.init(coder: aDecoder)
    }
    
    func configureForLike() {
        imageView.frame = CGRect(x: 0, y: 0, width: 70.0, height: 70.0)
        imageView.image = UIImage(named: "Check_noBorder")
        imageView.center = CGPoint(x: 50, y: 50)
    }
    
    func configureForDislike() {
        imageView.frame = CGRect(x: 0, y: 0, width: 60.0, height: 60.0)
        imageView.image = UIImage(named: "X_noBorder")
        let x = Int(frame.width) - 45
        imageView.center = CGPoint(x: x, y: 45)
    }
    
}
