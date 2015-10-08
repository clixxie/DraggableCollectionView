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
        let photo = photos.removeAtIndex(indexPath.row - 1)
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
    
    func draggableCollectionModuleInterface(moduleInterface: DraggableCollectionModuleInterface, customLogicForReleasedMockCell mockCell: UIView, representedByIndexPath indexPath: NSIndexPath, originIndexPath: NSIndexPath) -> (animations, batchUpdates, completion) {
        
        let frame = view.convertRect(mockCell.frame, fromView: mockCell.superview)
        
        if CGRectIntersectsRect(frame, deleteView.frame) {
            
            photos.removeAtIndex(indexPath.row)
            
            func batchUpdates() {
                collectionView.deleteItemsAtIndexPaths([indexPath])
            }
                        
            func animations() {
                mockCell.frame = CGRectMake(deleteView.center.x, deleteView.center.y, 0.0, 0.0)
            }
            
            func completion(_: Bool) {
                mockCell.removeFromSuperview()
                self.deleteView.backgroundColor = UIColor.blueColor()
            }
            
            return (animations, batchUpdates, completion)
        } else if photos.count < 20 && indexPath.row == photos.count - 1 {
            
            let photo = photos.removeLast()
            photos.insert(photo, atIndex: originIndexPath.row)
            
            func batchUpdates() {
                collectionView.moveItemAtIndexPath(indexPath, toIndexPath: originIndexPath)
            }
            
            func animations() {
                mockCell.frame = (collectionView.cellForItemAtIndexPath(originIndexPath)?.frame)!
            }
            
            func completion(_: Bool) {
                collectionView.cellForItemAtIndexPath(originIndexPath)?.hidden = false
                
                mockCell.removeFromSuperview()
            }
            
            return (animations, batchUpdates, completion)
        }
        
        return (nil, nil, nil)
        
    }
    
}
