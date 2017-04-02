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
                    imageView.image = UIImage(named: "X_white")
                    backgroundColor = Styles.xRed
                } else {
                    imageView.image = UIImage(named: "Check_white")
                    backgroundColor = Styles.likeGreen
                }
            }
        }
    }
    
    var label: UILabel!
    
    override init(frame: CGRect) {
        let imageViewFrame = CGRect(x: 0, y: 0, width: 100.0, height: 100.0)
        imageView = UIImageView(frame: imageViewFrame)
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        imageView.center = center
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView()
        super.init(coder: aDecoder)
    }
    
}
