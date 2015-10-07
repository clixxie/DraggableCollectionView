//
//  DraggableCollectionView.swift
//  Draggable
//
//  Created by Andrew Copp on 10/2/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

class DraggableCollectionView: UICollectionView {
    
    let dragGestureRecognizer = DragGestureRecognizer()
    var dragDelegate: DraggableCollectionViewDelegate?
    
    var currentIndexPath: NSIndexPath?
    
    required init?(coder aDecoder: NSCoder) {
    
        super.init(coder: aDecoder)
        
        dragGestureRecognizer.addTarget(self, action: "dragRecognized:")
        self.addGestureRecognizer(dragGestureRecognizer)
    }
    
    func dragRecognized(gesture: DragGestureRecognizer) {
        
        let point = gesture.locationInView(self)
                
        switch gesture.state {
        case .Began:
            
            guard let indexPath = indexPathForItemAtPoint(point) else {
                dragGestureRecognizer.enabled = false
                dragGestureRecognizer.enabled = true
                return
            }
            
            dragDelegate?.collectionView(self, dragEnteredIndexPath: indexPath)
            currentIndexPath = indexPath
            
        case .Changed:
            
            let translation = gesture.translationInView(self)
            dragDelegate?.collectionView(self, dragMovedDistance: translation)
            gesture.setTranslation(CGPointZero, inView: self)
            
            if let indexPath = indexPathForItemAtPoint(point) {
                if currentIndexPath == nil {
                    dragDelegate?.collectionView(self, dragEnteredIndexPath: indexPath)
                    currentIndexPath = indexPath
                }
            } else {
                if let indexPath = currentIndexPath {
                    dragDelegate?.collectionView(self, dragLeftIndexPath: indexPath)
                    currentIndexPath = nil
                }
            }

        case .Ended:
            
            dragDelegate?.collectionView(self, dragEndedAtPoint: point)
            
        default:
            print("Unsupported")
        }
        
    }

}


protocol DraggableCollectionViewDelegate {
 
    func collectionView(collectionView: DraggableCollectionView, dragEnteredIndexPath indexPath: NSIndexPath)
    func collectionView(collectionView: DraggableCollectionView, dragMovedDistance translation: CGPoint)
    func collectionView(collectionView: DraggableCollectionView, dragLeftIndexPath indexPath: NSIndexPath)
    func collectionView(collectionView: DraggableCollectionView, dragEndedAtPoint point: CGPoint)
}
