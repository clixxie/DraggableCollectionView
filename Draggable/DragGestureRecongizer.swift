//
//  DragGestureRecongizer.swift
//  Draggable
//
//  Created by Andrew Copp on 10/2/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum TouchType {
    case Began
    case Moved
    case Ended
    case Cancelled
}

struct InspectableTouch {
    let type: TouchType
    let location: CGPoint
    let view: UIView?
    
    init(type: TouchType, location: CGPoint, inView view: UIView? = nil) {
        self.type = type
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
            
            if newValue == .Ended || newValue == .Failed || newValue == .Cancelled {
                
                delayedChangeToState(.Possible)
                
            }
        }
    }
    
    // MARK: Target-Action
    
    // add a target/action pair. you can call this multiple times to specify multiple target/actions
    override func addTarget(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
    
    // remove the specified target/action pair. passing nil for target matches all targets, and the same for actions
    override func removeTarget(target: AnyObject?, action: Selector) {
        //
    }
    
    // MARK: Translation
    
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
    
    // MARK: Gesture Recognizer Methods
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        // TODO: Handle multiple touch gestures
        
        if let touch = touches.first {
            let inspectableTouch = InspectableTouch(type: .Began, location: touch.locationInView(view), inView: view)
            touchesBeganHelper(inspectableTouch)
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        // TODO: Handle multiple touch gestures
        
        if let touch = touches.first {
            let inspectableTouch = InspectableTouch(type: .Moved, location: touch.locationInView(view), inView: view)
            touchesMovedHelper(inspectableTouch)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        // TODO: Handle multiple touch gestures
        
        if let touch = touches.first {
            let inspectableTouch = InspectableTouch(type: .Ended, location: touch.locationInView(view), inView: view)
            touchesEndedHelper(inspectableTouch)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        // TODO: Handle multiple touch gestures
        
        if let touch = touches.first {
            let inspectableTouch = InspectableTouch(type: .Cancelled, location: touch.locationInView(view), inView: view)
            touchesCancelledHelper(inspectableTouch)
        }
        
    }
    
    // MARK: Gesture Recognizer Helper Methods
    
    internal func touchesBeganHelper(touch: InspectableTouch) {
        startingPoint = touch.location
        translationPoint = touch.location

        changeStateWithTouch(touch)
    }
    
    
    internal func touchesMovedHelper(touch: InspectableTouch) {
        
        changeStateWithTouch(touch)
        
    }
    
    internal func touchesEndedHelper(touch: InspectableTouch) {
        
        changeStateWithTouch(touch)

    }
    
    internal func touchesCancelledHelper(touch: InspectableTouch) {
        
        changeStateWithTouch(touch)

    }
    
    // MARK: State Machine
    
    func changeStateWithTouch(touch: InspectableTouch) {
        
        switch (state, touch.type) {
            
        case ( .Possible , .Began ):
            
            delayedChangeToState(.Began, afterDelay: minimumPressDuration)
            
        case ( .Possible , .Moved ):
            
            let startX = startingPoint.x
            let startY = startingPoint.y
            
            let currentX: CGFloat = touch.location.x
            let currentY: CGFloat = touch.location.y
            
            let dx = startX - currentX
            let dy = startY - currentY
            
            if abs(dx) > allowableMovement || abs(dy) > allowableMovement {
                state = .Failed
            }
            
        case ( .Began , .Moved ):
            
            state = .Changed
            
        case ( .Changed , .Moved ):
            
            state = .Changed
            
        case ( .Began , .Ended ):
            
            state = .Ended
            
        case ( .Changed , .Ended ):
            
            state = .Ended
            
        case ( .Possible , .Cancelled):
            
            state = .Cancelled
            
        case ( .Began , .Cancelled ):
            
            state = .Cancelled
            
        case ( .Changed , .Cancelled ):
            
            state = .Cancelled
            
        default:
            
            return
            
        }
        
    }
    
    func delayedChangeToState(state: UIGestureRecognizerState, afterDelay delay: CFTimeInterval = 0.0) {
        
        if let timer = currentTimer {
            let runLoop = CFRunLoopGetCurrent()
            CFRunLoopRemoveTimer(runLoop, timer, kCFRunLoopDefaultMode)
            CFRunLoopTimerInvalidate(timer)
        }
        
        let fireDate = CFAbsoluteTimeGetCurrent() + delay
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0.0, 0, 0) {
            _ in
            self.state = state
        }
        currentTimer = timer
        
        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopAddTimer(runLoop, timer, kCFRunLoopDefaultMode)
    }

}
