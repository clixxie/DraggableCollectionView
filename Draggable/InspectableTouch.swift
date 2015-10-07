//
//  InspectableTouch.swift
//  Draggable
//
//  Created by Andrew Copp on 10/7/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import UIKit

struct InspectableTouch {
    let type: TouchType
    let location: CGPoint
    let view: UIView?
    
    init(type: TouchType, location: CGPoint, inView view: UIView? = nil) {
        self.type = type
        self.location = location
        self.view = view
    }
    
    enum TouchType {
        case Began
        case Moved
        case Ended
        case Cancelled
    }
}