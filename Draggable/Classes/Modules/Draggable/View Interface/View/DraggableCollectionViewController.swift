//
//  ViewController.swift
//  Draggable
//
//  Created by Andrew Copp on 10/2/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

struct Photo {
    let backgroundColor : UIColor
    init(color: UIColor) {
        self.backgroundColor = color
    }
}

protocol DraggableCollectionViewControllerDelegate {
    
    func draggableCollectionViewController(viewController: DraggableCollectionViewController, movedToRect rect: CGRect)
    func customAnimationForDraggableCollectionViewController(viewController: DraggableCollectionViewController, snapshot: UIView, indexPath: NSIndexPath) -> Bool
    
}

class DraggableCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DraggableCollectionViewDelegate {

    @IBOutlet weak var collectionView: DraggableCollectionView!
    var delegate: DraggableCollectionViewControllerDelegate?
    
    lazy var photos = [Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor())]
    
    var currentPhoto: Photo?
    
    var currentSnapshot: UIView?
    
    var currentIndexPath: NSIndexPath?
    var lastIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dragDelegate = self
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        cell.backgroundColor = photos[indexPath.row].backgroundColor
        
        return cell
    }
    
    // MARK: DragCollectionViewDelegate
    
    func collectionView(collectionView: DraggableCollectionView, dragEnteredIndexPath indexPath: NSIndexPath) {
        
        if let snapshot = currentSnapshot {
            
            let photo = photos.removeAtIndex(currentIndexPath!.row)
            photos.insert(photo, atIndex: indexPath.row)
            
            func movedDraggedItems() {
                collectionView.moveItemAtIndexPath(currentIndexPath!, toIndexPath: indexPath)
            }
            collectionView.performBatchUpdates(movedDraggedItems) {
                finished in
            }
        } else {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                
                cell.hidden = true
                
                currentPhoto = photos[indexPath.row]
                
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
        
        let photo = photos.removeAtIndex(indexPath.row)
        photos.append(photo)
        
        let finalIndexPath = NSIndexPath(forRow: photos.count - 1, inSection: 0)
        
        func moveDraggedItem() {
            collectionView.moveItemAtIndexPath(indexPath, toIndexPath: finalIndexPath)
        }
        collectionView.performBatchUpdates(moveDraggedItem) {
            finished in
        }
        
        currentIndexPath = finalIndexPath

    }

    func collectionView(collectionView: DraggableCollectionView, dragEndedAtPoint point: CGPoint) {
        
        if delegate!.customAnimationForDraggableCollectionViewController(self, snapshot: currentSnapshot!, indexPath: currentIndexPath!) {
            
            self.currentIndexPath = nil
            self.lastIndexPath = nil
            
            self.currentSnapshot = nil
            
        } else {
            
            if let cell = collectionView.cellForItemAtIndexPath(lastIndexPath!), let hiddenCell = collectionView.cellForItemAtIndexPath(currentIndexPath!) {
                
                let photo = photos.removeAtIndex(currentIndexPath!.row)
                photos.insert(photo, atIndex: lastIndexPath!.row)
                
                
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
                
                collectionView.performBatchUpdates(batchUpdates) {
                    finished in
                }
            }
            
        }
    }
}

