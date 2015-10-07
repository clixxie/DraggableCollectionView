//
//  ViewController.swift
//  Draggable
//
//  Created by Andrew Copp on 10/2/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

protocol DraggableCollectionViewControllerDelegate {
    
    func draggableCollectionViewController(viewController: DraggableCollectionViewController, movedToRect rect: CGRect)
    func customAnimationForDraggableCollectionViewController(viewController: DraggableCollectionViewController, snapshot: UIView, indexPath: NSIndexPath) -> Bool
    
}

protocol DraggableCollectionViewDataSource {
    
    func draggableCollectionView(draggableCollectionView: DraggableCollectionView, configureCell cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    
}

class DraggableCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DraggableCollectionViewDelegate {

    @IBOutlet weak var collectionView: DraggableCollectionView!
    var delegate: DraggableCollectionViewControllerDelegate?
    var dataSource: DraggableCollectionViewDataSource? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var items: [Photo] = []
    
    var currentSnapshot: UIView?
    
    var currentIndexPath: NSIndexPath?
    var lastIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dragDelegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        return dataSource!.draggableCollectionView(collectionView as! DraggableCollectionView, configureCell: cell, forIndexPath: indexPath)
    }
    
    // MARK: DragCollectionViewDelegate
    
    func collectionView(collectionView: DraggableCollectionView, dragEnteredIndexPath indexPath: NSIndexPath) {
        
        if let snapshot = currentSnapshot {
            
            let item = items.removeAtIndex(currentIndexPath!.row)
            items.insert(item, atIndex: indexPath.row)
            
            func movedDraggedItems() {
                collectionView.moveItemAtIndexPath(currentIndexPath!, toIndexPath: indexPath)
            }
            collectionView.performBatchUpdates(movedDraggedItems, completion: nil)
        } else {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                
                cell.hidden = true
                
                let snapshot = cell.snapshotViewAfterScreenUpdates(false)
                snapshot.frame = cell.frame
                collectionView.addSubview(snapshot)
                currentSnapshot = snapshot
                
                UIView.animateWithDuration(0.1) {
                    snapshot.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }
            }
        }
        
        currentIndexPath = indexPath
        lastIndexPath = indexPath
    }
    
    func collectionView(collectionView: DraggableCollectionView, dragMovedDistance translation: CGPoint) {
        
        if let snapshot = currentSnapshot {
            
            let x = CGRectGetMinX(snapshot.frame) + translation.x
            let y = CGRectGetMinY(snapshot.frame) + translation.y
            let width = CGRectGetWidth(snapshot.frame)
            let height = CGRectGetHeight(snapshot.frame)
            
            snapshot.frame = CGRectMake(x, y, width, height)
            
            let rect = view.convertRect(snapshot.frame, toView: view.superview?.superview)
            
            delegate?.draggableCollectionViewController(self, movedToRect: rect)
        }
    }
    
    func collectionView(collectionView: DraggableCollectionView, dragLeftIndexPath indexPath: NSIndexPath) {
        
        let item = items.removeAtIndex(indexPath.row)
        items.append(item)
        
        let finalIndexPath = NSIndexPath(forRow: items.count - 1, inSection: 0)
        
        func moveDraggedItem() {
            collectionView.moveItemAtIndexPath(indexPath, toIndexPath: finalIndexPath)
        }
        collectionView.performBatchUpdates(moveDraggedItem, completion: nil)
        
        currentIndexPath = finalIndexPath

    }

    func collectionView(collectionView: DraggableCollectionView, dragEndedAtPoint point: CGPoint) {
        
        if delegate!.customAnimationForDraggableCollectionViewController(self, snapshot: currentSnapshot!, indexPath: currentIndexPath!) {
            
            self.currentIndexPath = nil
            self.lastIndexPath = nil
            
            self.currentSnapshot = nil
            
        } else {
            
            if let cell = collectionView.cellForItemAtIndexPath(lastIndexPath!), let hiddenCell = collectionView.cellForItemAtIndexPath(currentIndexPath!) {
                
                let photo = items.removeAtIndex(currentIndexPath!.row)
                items.insert(photo, atIndex: lastIndexPath!.row)
                
                
                func animations() {
                    currentSnapshot?.frame = cell.frame
                }
                UIView.animateWithDuration(0.3, animations: animations) {
                    finished in
                    
                    self.currentIndexPath = nil
                    self.lastIndexPath = nil
                    
                    hiddenCell.hidden = false
                    
                    self.currentSnapshot?.removeFromSuperview()
                    self.currentSnapshot = nil
                }
                
                func batchUpdates() {
                    collectionView.moveItemAtIndexPath(currentIndexPath!, toIndexPath: lastIndexPath!)
                }
                
                collectionView.performBatchUpdates(batchUpdates, completion: nil)
            }
            
        }
    }
}

