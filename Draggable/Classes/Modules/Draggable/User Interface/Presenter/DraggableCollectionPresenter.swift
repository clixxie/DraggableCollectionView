//
//  DraggableCollectionPresenter.swift
//  Draggable
//
//  Created by Andrew Copp on 10/7/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

protocol DraggableCollectionPresenterDataSource {
    func numberOfElements() -> Int
}

protocol DraggableCollectionPresenterDelegate {
    
    func draggableCollectionModuleInterface(moduleInterface: DraggableCollectionModuleInterface, willMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath: NSIndexPath)
    func draggableCollectionModuleInterface(moduleInterface: DraggableCollectionModuleInterface, didMoveMockCellToFrame frame: CGRect, inView: UICollectionView)
    func draggableCollectionModuleInterface(moduleInterface: DraggableCollectionModuleInterface, releasedMockCell mockCell: UIView, representedByIndexPath indexPath: NSIndexPath) -> Bool
}

class DraggableCollectionPresenter: NSObject, DraggableCollectionModuleInterface, DraggableCollectionInteractorOutput {
    
    let draggableCollectionInteractor = DraggableCollectionInteractor()
    var collectionView: UICollectionView?
    
    var delegate: DraggableCollectionPresenterDelegate?
    var dataSource: UICollectionViewDataSource?
    
    var mockCell: UIView?
    
    override init() {
        super.init()
        draggableCollectionInteractor.output = self
    }

    func dragRecognized(gesture: DragGestureRecognizer) {
    
        let collectionView = gesture.view as? UICollectionView
        
        let point = gesture.locationInView(collectionView)
        let indexPath = collectionView?.indexPathForItemAtPoint(point)
        
        draggableCollectionInteractor.processDragGesture(gesture, atIndexPath: indexPath)
    }
    
    // MARK: DraggableCollectionInteractorOutput
    
    func moveStartedAtIndexPath(indexPath: NSIndexPath) {
        
        if let cell = collectionView?.cellForItemAtIndexPath(indexPath) {
            
            cell.hidden = true
            
            mockCell = cell.snapshotViewAfterScreenUpdates(false)
            mockCell!.frame = cell.frame
            collectionView?.addSubview(mockCell!)
            
            UIView.animateWithDuration(0.1) {
                mockCell?.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }
            
        }
        
    }
    
    func moveFinshedAtPoint(point: CGPoint, startingIndexPath: NSIndexPath, currentIndexPath: NSIndexPath) {
        
        let noAdditionalWorkNeeded = delegate?.draggableCollectionModuleInterface(self, releasedMockCell: mockCell!, representedByIndexPath: currentIndexPath)
        if noAdditionalWorkNeeded! {
            return
        }
        
        var destinationIndexPath: NSIndexPath?
        
        if let indexPathForPoint = collectionView?.indexPathForItemAtPoint(point) {
            
            destinationIndexPath = indexPathForPoint
            
        } else {
            
            destinationIndexPath = startingIndexPath

        }
        
        delegate?.draggableCollectionModuleInterface(self, willMoveItemAtIndexPath: currentIndexPath, toIndexPath: destinationIndexPath!)
        
        let cell = collectionView?.cellForItemAtIndexPath(destinationIndexPath!)
        
        func animations() {
            mockCell?.frame = cell!.frame
        }
        
        UIView.animateWithDuration(0.3, animations: animations) {
            finished in
            
            self.collectionView?.cellForItemAtIndexPath(destinationIndexPath!)?.hidden = false
            
            self.mockCell?.removeFromSuperview()
            self.mockCell = nil
        }
        
        func batchUpdates() {
            collectionView?.moveItemAtIndexPath(currentIndexPath, toIndexPath: destinationIndexPath!)
        }
        
        collectionView?.performBatchUpdates(batchUpdates, completion: nil)
        
    }
    
    func moveFromIndexPath(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
        delegate?.draggableCollectionModuleInterface(self, willMoveItemAtIndexPath: fromIndexPath, toIndexPath: toIndexPath)
        
        func dragItem() {
            collectionView?.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
        }
        collectionView?.performBatchUpdates(dragItem, completion: nil)
        
    }
    
    func movedDistance(translation: CGPoint) {
        
        let x = CGRectGetMinX(mockCell!.frame) + translation.x
        let y = CGRectGetMinY(mockCell!.frame) + translation.y
        let width = CGRectGetWidth(mockCell!.frame)
        let height = CGRectGetHeight(mockCell!.frame)
        
        mockCell!.frame = CGRectMake(x, y, width, height)
        
        delegate?.draggableCollectionModuleInterface(self, didMoveMockCellToFrame: mockCell!.frame, inView: collectionView!)
        
    }
    
    func numberOfElements() -> Int {
        return dataSource!.collectionView(collectionView!, numberOfItemsInSection: 0) - 1
    }
    
}
