//
//  LVImageView.swift
//  PDFWebViewer
//
//  Created by LaValse on 2016. 3. 17..
//  Copyright © 2016년 LaValse. All rights reserved.
//

import UIKit

class LVImageView: UIView, UIGestureRecognizerDelegate {

    /* Scale Consts */
    private let MAX_SCALE : CGFloat = 3.0
    private let MIDDLE_SCALE : CGFloat = 2.0
    private let MIN_SCALE : CGFloat = 1.0
    private let DEFAULT_SCALE : CGFloat = 1.0
    
    /* Gesture Recognizers */
    private let _pinch = UIPinchGestureRecognizer()
    private let _pan = UIPanGestureRecognizer()
    private let _tap = UITapGestureRecognizer()
    
    private var pt = CGPoint(x: 0, y: 0) // touch point
    private var offset : CGPoint? // position of image view
    
    private let imageView = UIImageView()
    private var scale : CGFloat = 1.0 // variable scale
    private var isScale = false // scale flag
    
    init(image: UIImage?) {
        super.init(frame: UIScreen.mainScreen().bounds)
        
        /* Add listener to all gestures */
        _pinch.delegate = self
        _pinch.addTarget(self, action: Selector("onGesture:"))
        
        _pan.delegate = self
        _pan.addTarget(self, action: Selector("onGesture:"))
        
        _tap.delegate = self
        _tap.addTarget(self, action: Selector("onGesture:"))
        _tap.numberOfTapsRequired = 2
        
        self.userInteractionEnabled = true // It will be enable to gesture on this view
        self.addGestureRecognizer(_pinch)
        self.addGestureRecognizer(_pan)
        self.addGestureRecognizer(_tap)
        
        imageView.image = image
        imageView.frame = self.frame
        imageView.contentMode = .ScaleAspectFit // Set mode "ScaleAspectFit" to keep ratio of image
        
        offset = self.center
        
        self.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onGesture(recognizer:UIGestureRecognizer){
        let tp = recognizer.numberOfTouches()
        let state = recognizer.state
        
        if state == .Changed {
            if tp > 1 {
                /* Pinch event should receive since 2 points due to avoid duplication with pan event */
                if recognizer is UIPinchGestureRecognizer{
                    scale += ((recognizer as! UIPinchGestureRecognizer).scale - DEFAULT_SCALE)

                    scale = (scale <= MIN_SCALE) ? MIN_SCALE : (scale >= MAX_SCALE) ? MAX_SCALE : scale
                    
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        
                        self.isScale = true
                        self.imageView.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(self.scale, self.scale))

                        },completion: {(Bool) -> Void in
                            if state == .Ended {
                                self.isScale = false
                            }
                    })
                }
            }else {
                if recognizer is UIPanGestureRecognizer {
                    let p = recognizer.locationInView(self)
                    
                    if(!isScale){
                        let dist = CGPoint(x: p.x - pt.x, y: p.y - pt.y)
                        
                        self.imageView.center = CGPoint(x: offset!.x + dist.x, y: offset!.y + dist.y)
                        
                        pt = p
                        offset = self.imageView.center
                    }
                }
            }
        } else if state == .Ended {
            isScale = false
            
            /* Tap event always occur when gesture is end */
            if recognizer is UITapGestureRecognizer {
                var tScale = DEFAULT_SCALE
                
                if scale < MIDDLE_SCALE {
                    tScale = MIDDLE_SCALE
                }else if scale >= MIDDLE_SCALE && scale < MAX_SCALE {
                    tScale = MAX_SCALE
                }
                
                scale = tScale
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    
                    self.isScale = true
                    self.imageView.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(self.scale, self.scale))

                    if self.scale == self.DEFAULT_SCALE {
                        self.imageView.center = self.center
                        self.offset = self.center
                    }
                    
                    },completion: {(Bool) -> Void in
                        if state == .Ended {
                            self.isScale = false
                        }
                })
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let p = gestureRecognizer.locationInView(self)
        
        /* Setting start point to get a distance between S.P and E.P when a pan gesture occur */
        pt.x = p.x
        pt.y = p.y
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
