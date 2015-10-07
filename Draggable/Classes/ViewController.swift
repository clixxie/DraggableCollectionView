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

class ViewController: UIViewController, DraggableCollectionViewDataSource, DraggableCollectionViewControllerDelegate {
    
    @IBOutlet weak var deleteView: UIView!
    
    var draggableCollectionViewController: DraggableCollectionViewController?
    
    lazy var photos = [Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor())]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for viewController in childViewControllers {
            if viewController.isKindOfClass(DraggableCollectionViewController) {
                draggableCollectionViewController = (viewController as! DraggableCollectionViewController)
                draggableCollectionViewController!.delegate = self
                draggableCollectionViewController!.dataSource = self
                draggableCollectionViewController!.items = photos
            }
        }
    }
    
    func draggableCollectionView(draggableCollectionView: DraggableCollectionView, configureCell cell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        cell.backgroundColor = photos[indexPath.row].backgroundColor
        return cell
        
    }
    
    // MARK: DraggableCollectionViewControllerDelegate

    func draggableCollectionViewController(viewController: DraggableCollectionViewController, movedToRect rect: CGRect) {
        if CGRectIntersectsRect(rect, deleteView.frame) {
            deleteView.backgroundColor = UIColor.blackColor()
        } else {
            deleteView.backgroundColor = UIColor.blueColor()
        }
    }
    
    func customAnimationForDraggableCollectionViewController(viewController: DraggableCollectionViewController, snapshot: UIView, indexPath: NSIndexPath) -> Bool {
        
        if CGRectIntersectsRect(deleteView.frame, viewController.collectionView.convertRect(snapshot.frame, toView: view)) {
            
            if let hiddenCell = viewController.collectionView.cellForItemAtIndexPath(indexPath) {
                let photo = photos.removeAtIndex(indexPath.row)
                viewController.items = photos
                
                func batchUpdates() {
                    viewController.collectionView.deleteItemsAtIndexPaths([indexPath])
                }

                viewController.collectionView.performBatchUpdates(batchUpdates) {
                    finished in
                }
                
                snapshot.removeFromSuperview()
                deleteView.backgroundColor = UIColor.blueColor()
            }
            
            return true
        } else {
            return false
        }
        
    }
    
}
