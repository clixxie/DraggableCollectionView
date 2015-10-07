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
    
    init(type: TouchType, location: CGPoint) {
        self.type = type
        self.location = location
    }
    
    enum TouchType {
        case Began
        case Moved
        case Ended
        case Cancelled
    }
}