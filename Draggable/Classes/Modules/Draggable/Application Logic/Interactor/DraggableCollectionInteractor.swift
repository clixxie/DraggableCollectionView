//
//  DraggableCollectionInteractor.swift
//  Draggable
//
//  Created by Andrew Copp on 10/7/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

class DraggableCollectionInteractor: NSObject, DraggableCollectionInteractorInput {

    var output: DraggableCollectionInteractorOutput?
    
    var startingIndexPath: NSIndexPath?
    var currentIndexPath: NSIndexPath?
    
    
    func dragRecognized(gesture: DragGestureRecognizer, atIndexPath indexPath: NSIndexPath?) {
        switch gesture.state {
        case .Began:

            guard let i = indexPath else {
                gesture.enabled = false
                gesture.enabled = true
                return
            }
            
            output!.moveStartedAtIndexPath(i)
            startingIndexPath = i
            currentIndexPath = i

        case .Changed:
            
            let translation = gesture.translationInView(gesture.view)
            output!.movedDistance(translation)
            gesture.setTranslation(CGPointZero, inView: gesture.view)
            
            let finalIndexPath = NSIndexPath(forRow: output!.numberOfElements(), inSection: 0)
            
            if let i = indexPath {
                if currentIndexPath == finalIndexPath {
                    output!.moveFromIndexPath(finalIndexPath, toIndexPath: i)
                    currentIndexPath = i
                }
            } else {
                if let i = currentIndexPath {
                    output!.moveFromIndexPath(i, toIndexPath: finalIndexPath)
                    currentIndexPath = finalIndexPath
                }
            }

        case .Ended:
            
            let point = gesture.locationInView(gesture.view)
            output!.moveFinshedAtPoint(point, startingIndexPath: startingIndexPath!, currentIndexPath: currentIndexPath!)
            
        default:

            return
        
        }
    }
}
