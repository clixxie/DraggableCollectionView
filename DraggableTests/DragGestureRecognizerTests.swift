//
//  DragGestureRecognizerTests.swift
//  Draggable
//
//  Created by Andrew Copp on 10/5/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import XCTest
@testable import Draggable

class DragGestureRecognizerTests: XCTestCase {
    
    // MARK: Possible State
    
    func testThatGestureDoesNotImmediatelyStartWhenTouched() {
        
        // GIVEN a drag gesture in the Possible state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 1.0
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
        
        // WHEN the touch starts and ends before the minimum press duration passes
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        
        // THEN the drag gesture stays in the Possible state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
    }
    
    func testThatGestureBeginsAfterMinimumPressDurationIsSatisfied() {
        
        // GIVEN a drag gesture in the Possible state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
        
        // WHEN the minimum press duration passes
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        
        // THEN the drag gesture enters the Began state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Began, "")
    }
    
    func testThatGestureFailsIfTooMuchMovementBeforeBeginning() {
        
        // GIVEN a drag gesture in the Possible state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 1.0
        
        let firstTouch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(firstTouch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
        
        // WHEN the touch starts and moves more than the allowable distance before the minimum press duration passes
        let secondTouch = InspectableTouch(location: CGPointMake(20.0, 20.0))
        dragGestureRecognizer.touchesMovedHelper(secondTouch)
        
        // THEN the drag gesture enters the Failed state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Failed, "")
    }
    
    func testThatGestureIsUnaffectedByMovement() {
        
        // GIVEN a drag gesture in the Possible state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 1.0
        
        let firstTouch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(firstTouch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
        
        // WHEN the touch starts and moves less than the allowable distance before the minimum press duration passes
        let secondTouch = InspectableTouch(location: CGPointMake(5.0, 5.0))
        dragGestureRecognizer.touchesMovedHelper(secondTouch)
        
        // THEN the drag gesture stays in the Possible state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
    }
    
    func testThatGestureSwitchesToCancelledState() {
        
        // GIVEN a drag gesture in the Possible state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 1.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
        
        // WHEN the touch cancels before the minimum press duration passes
        dragGestureRecognizer.touchesCancelledHelper(touch)
        
        // THEN the drag gesture enters the Cancelled state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Cancelled, "")
    }
    
    // MARK: Began State
    
    func testThatGestureSwitchesToChangedState() {
        
        // GIVEN a drag gesture is in the Began state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Began, "")
        
        // WHEN the touch moves
        dragGestureRecognizer.touchesMovedHelper(touch)
        
        // THEN the drag gesture enters the Changed state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Changed, "")
    }
    
    func testThatBeganCanEnd() {
        
        // GIVEN a gesture is in the Began state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Began, "")
        
        // WHEN the touch ends
        dragGestureRecognizer.touchesEndedHelper(touch)

        // THEN then drag gesture enters the Ended state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Ended, "")
    }
    
    func testThatBeganCanCancel() {
        
        // GIVEN a gesture is in the Began state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Began, "")
        
        // WHEN the touch cancels
        dragGestureRecognizer.touchesCancelledHelper(touch)

        // THEN the drag gesture enters the Cancelled state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Cancelled, "")
    }
    
    // MARK: Changed State
    
    func testThatChangedStaysChanged() {
        
        // GIVEN a drag gesture is in the Changed state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        dragGestureRecognizer.touchesMovedHelper(touch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Changed, "")
        
        // WHEN the touch moves
        dragGestureRecognizer.touchesMovedHelper(touch)
        
        // THEN the drag gesture enters the Changed state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Changed, "")
    }
    
    func testAnother() {
        
        // GIVEN a drag gesture is in the Changed state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        dragGestureRecognizer.touchesMovedHelper(touch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Changed, "")
        
        // WHEN the touch ends
        dragGestureRecognizer.touchesEndedHelper(touch)
        
        // THEN the drag gesture enters the Ended state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Ended, "")
    }
    
    func testSomething() {
        
        // GIVEN a drag gesture is in the Changed state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        dragGestureRecognizer.touchesMovedHelper(touch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Changed, "")
        
        // WHEN the touch cancels
        dragGestureRecognizer.touchesCancelledHelper(touch)
        
        // THEN the drag gesture enters the Cancelled state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Cancelled, "")
    }
    
    // MARK: Ended State
    
    func testThatEnd() {
        
        //    Given a drag gesture is in the Ended state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        dragGestureRecognizer.touchesEndedHelper(touch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Ended, "")

        //    When
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        
        //    Then dimmed
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
        
    }
    
    // MARK: Failed State
    
    // TODO: Test run loop
    
    func testThatFailedGestureResetsWhenTouchEnds() {
        
        // GIVEN a drag gesture is in the Failed state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 1.0
        
        let firstTouch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(firstTouch)
        
        let secondTouch = InspectableTouch(location: CGPointMake(20.0, 20.0))
        dragGestureRecognizer.touchesMovedHelper(secondTouch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Failed, "")
        
        // WHEN the touch ends
        dragGestureRecognizer.touchesEndedHelper(secondTouch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        
        // THEN the drag gesture enters the Possible state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
    }
    
    func testAThing() {
        
        // GIVEN a gesture is in the Failed state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 1.0
        
        let firstTouch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(firstTouch)
        
        let secondTouch = InspectableTouch(location: CGPointMake(20.0, 20.0))
        dragGestureRecognizer.touchesMovedHelper(secondTouch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Failed, "")
        
        // WHEN the touch cancels
        dragGestureRecognizer.touchesCancelledHelper(secondTouch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        
        // THEN the drag gesture enters the Possible state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
    }
        
    // MARK: Cancelled State

    func testThatCancel() {
        
        // GIVEN a drag gesture is in the Cancelled state
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        dragGestureRecognizer.touchesCancelledHelper(touch)
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Cancelled, "")
        
        // WHEN the touch ends
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        
        // THEN the drag gesture enters the Possible state
        XCTAssertEqual(dragGestureRecognizer.state, UIGestureRecognizerState.Possible, "")
    }
    
    // MARK: Target-Action
    
    func DISABLED_testTargetAction() {
        
        // GIVEN a drag gesture with a target-action
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.minimumPressDuration = 0.0
        
        let target = Target()
        dragGestureRecognizer.addTarget(target, action: "action:")
        
        // WHEN the drag gesture changes state
        let touch = InspectableTouch(location: CGPointZero)
        dragGestureRecognizer.touchesBeganHelper(touch)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false)
        
        // THEN the target receives the action
        self.expectationForNotification(target.notificationName, object: target, handler: nil)
    }
    
    func DISABLEDtestNoTargetAction() {
        
        // GIVEN a drag gesture without a target-action
        
        
        // WHEN the drag gesture changes state
        
        
        // THEN the app does not crash
    }
    
    // TODO: Target-Action for movement
    
}

class Target {
    let notificationName = "Blah"
    
    func action(gesture: DragGestureRecognizer) {
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: self)
    }
}
