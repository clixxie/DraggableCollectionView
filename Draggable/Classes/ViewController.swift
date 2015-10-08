//
//  ViewController.swift
//  Draggable
//
//  Created by Andrew Copp on 10/7/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

struct Photo {
    let backgroundColor : UIColor
    init(color: UIColor) {
        self.backgroundColor = color
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DraggableCollectionPresenterDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteView: UIView!
    
    var presenter: DraggableCollectionModuleInterface?
    
    lazy var photos = [Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.blackColor())]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let draggableCollectionWireframe = DraggableCollectionWireframe()
        presenter = draggableCollectionWireframe.addFunctionalityToCollectionView(collectionView, delegate: self)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        cell.backgroundColor = photos[indexPath.row].backgroundColor
        
        return cell
    }
    
    // MARK: DraggableCollectionPresenterDelegate
    
    func draggableCollectionModuleInterface(moduleInterface: DraggableCollectionModuleInterface, willMoveItemAtIndexPath indexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let photo = photos.removeAtIndex(indexPath.row)
        let index = indexPath.row < toIndexPath.row ? toIndexPath.row - 1 : toIndexPath.row
        photos.insert(photo, atIndex: index)
    }

    func draggableCollectionModuleInterface(moduleInterface: DraggableCollectionModuleInterface, didMoveMockCellToFrame frame: CGRect, inView: UICollectionView) {
        let adjustedFrame = view.convertRect(frame, fromView: inView)
        if CGRectIntersectsRect(adjustedFrame, deleteView.frame) {
            deleteView.backgroundColor = UIColor.yellowColor()
        } else {
            deleteView.backgroundColor = UIColor.blueColor()
        }
    }
    
    func draggableCollectionModuleInterface(moduleInterface: DraggableCollectionModuleInterface, releasedMockCell mockCell: UIView, representedByIndexPath indexPath: NSIndexPath) -> Bool {
        let frame = view.convertRect(mockCell.frame, fromView: mockCell.superview)
        
        if CGRectIntersectsRect(frame, deleteView.frame) {
            
            photos.removeAtIndex(indexPath.row)
            
            func batchUpdates() {
                collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            collectionView.performBatchUpdates(batchUpdates, completion: nil)
            
            func animations() {
                mockCell.frame = CGRectMake(deleteView.center.x, deleteView.center.y, 0.0, 0.0)
            }
            
            UIView.animateWithDuration(0.3, animations: animations) {
                finished in
                
                mockCell.removeFromSuperview()
                self.deleteView.backgroundColor = UIColor.blueColor()
            }
            
            return true
        } else {
            return false
        }
    }
    
}
