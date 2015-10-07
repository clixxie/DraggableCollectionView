//
//  DragGestureRecongizer.swift
//  Draggable
//
//  Created by Andrew Copp on 10/2/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

struct InspectableTouch {
    let location: CGPoint
    let view: UIView?
    
    init(location: CGPoint, inView view: UIView? = nil) {
        self.location = location
        self.view = view
    }
}

class DragGestureRecognizer: UIGestureRecognizer {

    var minimumPressDuration: CFTimeInterval = 0.5
    var allowableMovement: CGFloat = 10
    
    var startingPoint: CGPoint = CGPointZero
    var translationPoint: CGPoint = CGPointZero
    
    var target: AnyObject?
    var action: Selector?
    
    var currentTimer: CFRunLoopTimerRef?
    
    private var _state: UIGestureRecognizerState = .Possible
    override var state : UIGestureRecognizerState {
        get {
            return self._state
        }
        set {
            self._state = newValue
            if let action = self.action, let target = self.target where newValue != .Possible {
                UIApplication.sharedApplication().sendAction(action, to: target, from: self, forEvent: nil)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        if let touch = touches.first {
            touchesBeganHelper(InspectableTouch(location: touch.locationInView(self.view), inView: self.view))
        }
        
    }
    
    internal func touchesBeganHelper(touch: InspectableTouch) {
        startingPoint = touch.location
        translationPoint = touch.location
        
        let fireDate = CFAbsoluteTimeGetCurrent() + minimumPressDuration
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0.0, 0, 0) {
            _ in
            if self.state == .Possible {
                self.state = .Began
            }
        }
        currentTimer = timer
        
        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopAddTimer(runLoop, timer, kCFRunLoopDefaultMode)

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        if let touch = touches.first {
            touchesMovedHelper(InspectableTouch(location: touch.locationInView(self.view), inView: self.view))
        }
    }
    
    internal func touchesMovedHelper(touch: InspectableTouch) {
        
        if state == .Failed {
            return
        }
        
        if state == .Possible {
            let startX = startingPoint.x
            let startY = startingPoint.y
            
            let currentX: CGFloat = touch.location.x
            let currentY: CGFloat = touch.location.y
            
            let dx = startX - currentX
            let dy = startY - currentY
            
            if abs(dx) > allowableMovement || abs(dy) > allowableMovement {
                state = .Failed
                
                if let timer = currentTimer {
                    let runLoop = CFRunLoopGetCurrent()
                    CFRunLoopRemoveTimer(runLoop, timer, kCFRunLoopDefaultMode)
                    CFRunLoopTimerInvalidate(timer)
                }
                
                let fireDate = CFAbsoluteTimeGetCurrent()
                let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0.0, 0, 0) {
                    _ in
                    self.state = .Possible
                }
                
                let runLoop = CFRunLoopGetCurrent()
                CFRunLoopAddTimer(runLoop, timer, kCFRunLoopDefaultMode)
            }
        }
        
        if state == .Began {
            state = .Changed
        } else {
            if let action = self.action, let target = self.target {
                UIApplication.sharedApplication().sendAction(action, to: target, from: self, forEvent: nil)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        if let touch = touches.first {
            touchesEndedHelper(InspectableTouch(location: touch.locationInView(self.view), inView: self.view))
        }
    }
    
    internal func touchesEndedHelper(touch: InspectableTouch) {
        
        if state != .Failed && state != .Possible {
            state = .Ended
        }
        
        if let timer = currentTimer {
            let runLoop = CFRunLoopGetCurrent()
            CFRunLoopRemoveTimer(runLoop, timer, kCFRunLoopDefaultMode)
            CFRunLoopTimerInvalidate(timer)
        }
        
        let fireDate = CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0.0, 0, 0) {
            _ in
            self.state = .Possible
        }
        
        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopAddTimer(runLoop, timer, kCFRunLoopDefaultMode)
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        if let touch = touches.first {
            touchesCancelledHelper(InspectableTouch(location: touch.locationInView(self.view), inView: self.view))
        }
        
    }
    
    internal func touchesCancelledHelper(touch: InspectableTouch) {
        
        if state != .Failed {
            state = .Cancelled
        }
        
        if let timer = currentTimer {
            let runLoop = CFRunLoopGetCurrent()
            CFRunLoopRemoveTimer(runLoop, timer, kCFRunLoopDefaultMode)
            CFRunLoopTimerInvalidate(timer)
        }
        
        let fireDate = CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0.0, 0, 0) {
            _ in
            self.state = .Possible
        }
        
        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopAddTimer(runLoop, timer, kCFRunLoopDefaultMode)
    }
    
    // translation in the coordinate system of the specified view
    func translationInView(view: UIView?) -> CGPoint {
        let currentPoint = locationInView(view)
        let delta = CGPointMake(currentPoint.x - translationPoint.x, currentPoint.y - translationPoint.y)
        return self.view!.convertPoint(delta, toView: view)
    }
    
    func setTranslation(translation: CGPoint, inView view: UIView?) {
        let currentPoint = locationInView(view)
        let point = CGPointMake(currentPoint.x + translation.x, currentPoint.y + translation.y)
        translationPoint = self.view!.convertPoint(point, fromView: view)
    }
    
    // add a target/action pair. you can call this multiple times to specify multiple target/actions
    override func addTarget(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
    
    // remove the specified target/action pair. passing nil for target matches all targets, and the same for actions
    override func removeTarget(target: AnyObject?, action: Selector) {
        //
    }
    
//    override func locationInView(view: UIView?) -> CGPoint {
//        return CGPointZero;
//    }
}
