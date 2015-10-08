//
//  DraggableCollectionWireframe.swift
//  Draggable
//
//  Created by Andrew Copp on 10/8/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

class DraggableCollectionWireframe: NSObject {

    func addFunctionalityToCollectionView(collectionView: UICollectionView, delegate: DraggableCollectionPresenterDelegate) -> DraggableCollectionModuleInterface {
        
        let presenter = DraggableCollectionPresenter()
        presenter.delegate = delegate
        presenter.dataSource = collectionView.dataSource
        presenter.collectionView = collectionView
        
        let dragGestureRecognizer = DragGestureRecognizer()
        dragGestureRecognizer.addTarget(presenter, action: "dragRecognized:")
        
        collectionView.addGestureRecognizer(dragGestureRecognizer)
        
        return presenter
    }
    
}
