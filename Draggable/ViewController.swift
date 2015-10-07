//
//  ViewController.swift
//  Draggable
//
//  Created by Andrew Copp on 10/7/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DraggableCollectionViewControllerDelegate {
    
    @IBOutlet weak var deleteView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for viewController in childViewControllers {
            if viewController.isKindOfClass(DraggableCollectionViewController) {
                let draggableViewController = viewController as! DraggableCollectionViewController
                draggableViewController.delegate = self
            }
        }
    }

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
                let photo = viewController.photos.removeAtIndex(indexPath.row)

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
