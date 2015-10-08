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
    func moveElementFromIndex(index: Int, toIndex: Int)
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
        
        draggableCollectionInteractor.dragRecognized(gesture, atIndexPath: indexPath)
    }
    
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
        
        var destinationIndexPath: NSIndexPath?
        
        if let currentIndexPath = collectionView?.indexPathForItemAtPoint(point) {
            
            destinationIndexPath = currentIndexPath
            
        } else {
            
            destinationIndexPath = startingIndexPath

        }
        
        delegate!.moveElementFromIndex(currentIndexPath.row, toIndex: destinationIndexPath!.row)
        
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
    
        delegate!.moveElementFromIndex(fromIndexPath.row, toIndex: toIndexPath.row)
        
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
            
//            let rect = view.convertRect(snapshot.frame, toView: view.superview?.superview)
//            
//            delegate?.draggableCollectionViewController(self, movedToRect: rect)
    }
    
    func numberOfElements() -> Int {
        return dataSource!.collectionView(collectionView!, numberOfItemsInSection: 0) - 1
    }
    
}
