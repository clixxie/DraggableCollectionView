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
    
    var presenter: DraggableCollectionPresenter?
    
    lazy var photos = [Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor()), Photo(color: UIColor.redColor()), Photo(color: UIColor.greenColor()), Photo(color: UIColor.purpleColor()), Photo(color: UIColor.orangeColor()), Photo(color: UIColor.cyanColor()), Photo(color: UIColor.magentaColor())]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let draggableCollectionWireframe = DraggableCollectionWireframe()
        presenter = draggableCollectionWireframe.addFunctionalityToCollectionView(collectionView, delegate: self)
    }
    
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
    
    func moveElementFromIndex(index: Int, toIndex: Int) {
        let photo = photos.removeAtIndex(index)
        let revisedIndex = index < toIndex ? toIndex - 1 : toIndex
        photos.insert(photo, atIndex: revisedIndex)
    }
    
//    func customAnimationForDraggableCollectionViewController(viewController: DraggableCollectionViewController, snapshot: UIView, indexPath: NSIndexPath) -> Bool {
//        
//        if CGRectIntersectsRect(deleteView.frame, viewController.collectionView.convertRect(snapshot.frame, toView: view)) {
//            
//            if let hiddenCell = viewController.collectionView.cellForItemAtIndexPath(indexPath) {
//                let photo = photos.removeAtIndex(indexPath.row)
//                viewController.items = photos
//                
//                func batchUpdates() {
//                    viewController.collectionView.deleteItemsAtIndexPaths([indexPath])
//                }
//
//                viewController.collectionView.performBatchUpdates(batchUpdates) {
//                    finished in
//                }
//                
//                snapshot.removeFromSuperview()
//                deleteView.backgroundColor = UIColor.blueColor()
//            }
//            
//            return true
//        } else {
//            return false
//        }
//        
//    }
    
}
