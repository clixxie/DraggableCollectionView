//
//  DraggableCollectionInteractorIO.swift
//  Draggable
//
//  Created by Andrew Copp on 10/7/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

protocol DraggableCollectionInteractorInput {
        
    func dragRecognized(gesture: DragGestureRecognizer, atIndexPath: NSIndexPath?)
}

protocol DraggableCollectionInteractorOutput {
    
    func moveStartedAtIndexPath(indexPath: NSIndexPath)
    func moveFinshedAtPoint(point: CGPoint, startingIndexPath: NSIndexPath, currentIndexPath: NSIndexPath)
    
    func movedDistance(translation: CGPoint)
    
    func moveFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    
    func numberOfElements() -> Int
    
}