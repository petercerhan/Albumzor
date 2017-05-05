//
//  CGDraggableView.swift
//  Albumzor
//
//  Created by Peter Cerhan on 4/1/17.
//  Copyright © 2017 Peter Cerhan. All rights reserved.
//
// Based on this tutorial: http://guti.in/articles/creating-tinder-like-animations

import UIKit

enum SwipeDirection: Int {
    case none
    case left
    case right
}

protocol CGDraggableViewDelegate: NSObjectProtocol {
    func swipeBegan()
    func swipeCanceled()
    func swipeComplete(direction: SwipeDirection)
    func tapped()
}

class CGDraggableView: UIView {
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var tapGestureRecognizer: UITapGestureRecognizer!
    var originalPoint = CGPoint(x: 0, y: 0)
    var overlayView: CGOverlayView!
    var imageView: UIImageView!
    var direction = SwipeDirection.none
    
    weak var delegate: CGDraggableViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragged(gestureRecognizer:)))
        self.addGestureRecognizer(panGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        imageView = UIImageView(frame: bounds)
        addSubview(imageView)
        
        overlayView = CGOverlayView(frame: bounds)
        overlayView.alpha = 0
        addSubview(overlayView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragged(gestureRecognizer:)))
        self.addGestureRecognizer(panGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        imageView = UIImageView(frame: bounds)
        addSubview(imageView)
        
        overlayView = CGOverlayView(frame: bounds)
        overlayView.alpha = 0
        addSubview(overlayView)
    }
    
    func tapped(gestureRecognizer: UITapGestureRecognizer) {
        delegate?.tapped()
    }
    
    func dragged(gestureRecognizer: UIPanGestureRecognizer) {
        let xDistance = gestureRecognizer.translation(in: self).x
        let yDistance = gestureRecognizer.translation(in: self).y
        
        switch gestureRecognizer.state {
        case .began:
            delegate?.swipeBegan()
            originalPoint = center
        case .changed:
            let rotationStrength = min(xDistance / 375, 1.0)
            let rotationAngle = 2 * CGFloat(M_PI) * rotationStrength / 16.0
            let scaleStrength = CGFloat(1 - fabsf(Float(rotationStrength)) / 4.0)
            let scale = max(scaleStrength, 0.93)
            center = CGPoint(x: originalPoint.x + xDistance, y: originalPoint.y + yDistance)
            let transform = CGAffineTransform(rotationAngle: rotationAngle)
            let scaleTransform = transform.scaledBy(x: scale, y: scale)
            self.transform = scaleTransform
            
            updateDirection(distance: xDistance)
            
        case .ended:
            if fabsf(Float(xDistance)) > 100.0 {
                completeSwipe()
            } else {
                resetViewPositionAndTransformations()
                delegate?.swipeCanceled()
            }
        default:
            break
        }
        
    }
    
    func updateDirection(distance: CGFloat) {
        
        if distance > 0 {
            direction = .right
            overlayView.mode = .right
        } else if distance <= 0 {
            direction = .left
            self.overlayView.mode = .left
        }
        
        let overlayStrength = CGFloat(min(fabsf(Float(distance)) / 70, 1.0))
        overlayView.alpha = overlayStrength
    }
    
    func completeSwipe() {
        UIView.animate(withDuration: 0.1,
                       animations: {
                            if self.overlayView.mode == .right {
                                self.center = CGPoint(x: self.center.x + 100.0, y: self.center.y + 0.0)
                            } else {
                                self.center = CGPoint(x: self.center.x - 100.0, y: self.center.y + 0.0)
                            }
                            self.alpha = 0
                        },
                       completion: { _ in self.removeFromSuperview()
                            if let delegate = self.delegate {
                                delegate.swipeComplete(direction: self.direction)
                            }
                        })
    }
    
    func resetViewPositionAndTransformations() {
        
        if direction == .none {
            return
        }
        self.direction = .none
        
        UIView.animate(withDuration: 0.2, animations: {
                            self.center = self.originalPoint
                            self.transform = CGAffineTransform(rotationAngle: 0)
                            self.overlayView.alpha = 0
                        },
                       completion: nil)
    }
    
}
