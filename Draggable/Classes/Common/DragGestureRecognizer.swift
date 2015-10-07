//
//  DragGestureRecognizer.swift
//  Draggable
//
//  Created by Andrew Copp on 10/2/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class DragGestureRecognizer: UIGestureRecognizer {

    var minimumPressDuration: CFTimeInterval = 0.5
    var allowableMovement: CGFloat = 10
    
    private var startingPoint = CGPointZero
    private var translationPoint = CGPointZero
    
    private var currentTimer: CFRunLoopTimerRef?
    
    private var targetActions = Set<TargetActionPair>()
    
    private var _state: UIGestureRecognizerState = .Possible
    override var state : UIGestureRecognizerState {
        get {
            return self._state
        }
        set {
            
            self._state = newValue
            
            if newValue != .Possible {
                
                for pair in targetActions {
                    UIApplication.sharedApplication().sendAction(pair.action, to: pair.target, from: self, forEvent: nil)
                }
            }
            
            if newValue == .Ended || newValue == .Failed || newValue == .Cancelled {
                
                delayedChangeToState(.Possible)
                
            }
        }
    }
    
    // MARK: Target-Action
    
    override func addTarget(target: AnyObject, action: Selector) {
        let pair = TargetActionPair(target: target, action: action)
        targetActions.insert(pair)
    }
    
    override func removeTarget(target: AnyObject?, action: Selector) {
        
        switch ( target , action ) {
            
        case ( nil , nil ):
            
            return
            
        case ( _ , nil ):
            
            for pair in targetActions {
                if pair.target.isEqual(target!) {
                    targetActions.remove(pair)
                }
            }
            
        case ( nil , _ ):
            
            for pair in targetActions {
                if pair.action == action {
                    targetActions.remove(pair)
                }
            }
            
        case ( _ , _ ):
            
            let pair = TargetActionPair(target: target!, action: action)
            targetActions.remove(pair)
            
        }
        
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
        
        if let touch = touches.first {
            let inspectableTouch = InspectableTouch(type: .Began, location: touch.locationInView(view))
            touchesBeganHelper(inspectableTouch)
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        if let touch = touches.first {
            let inspectableTouch = InspectableTouch(type: .Moved, location: touch.locationInView(view))
            touchesMovedHelper(inspectableTouch)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        
        if let touch = touches.first {
            let inspectableTouch = InspectableTouch(type: .Ended, location: touch.locationInView(view))
            touchesEndedHelper(inspectableTouch)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
                
        if let touch = touches.first {
            let inspectableTouch = InspectableTouch(type: .Cancelled, location: touch.locationInView(view))
            touchesCancelledHelper(inspectableTouch)
        }
        
    }
    
    // MARK: Gesture Recognizer Helper Methods
    
    internal func touchesBeganHelper(touch: InspectableTouch) {
        startingPoint = touch.location
        translationPoint = touch.location

        handleTouch(touch)
    }
    
    
    internal func touchesMovedHelper(touch: InspectableTouch) {
        handleTouch(touch)
    }
    
    internal func touchesEndedHelper(touch: InspectableTouch) {
        handleTouch(touch)
    }
    
    internal func touchesCancelledHelper(touch: InspectableTouch) {
        handleTouch(touch)
    }
    
    // MARK: State Machine
    
    private func handleTouch(touch: InspectableTouch) {
        
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
            
        case ( .Possible , .Ended ):
            
            invalidateTimer()
            
        case ( _ , .Moved ):
            
            state = .Changed
            
        case ( .Began , .Ended ):
            
            state = .Ended
            
        case ( .Changed , .Ended ):
            
            state = .Ended
            
        case ( _ , .Cancelled):
            
            state = .Cancelled
            
        default:
            
            return
            
        }
        
    }
    
    func invalidateTimer() {
        
        if let timer = currentTimer {
            let runLoop = CFRunLoopGetCurrent()
            CFRunLoopRemoveTimer(runLoop, timer, kCFRunLoopDefaultMode)
            CFRunLoopTimerInvalidate(timer)
        }
    }
    
    private func delayedChangeToState(state: UIGestureRecognizerState, afterDelay delay: CFTimeInterval = 0.0) {
        
        invalidateTimer()
        
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
