//
//  TargetActionPair.swift
//  Draggable
//
//  Created by Andrew Copp on 10/7/15.
//  Copyright © 2015 Andrew Copp. All rights reserved.
//

import Foundation

struct TargetActionPair: Hashable {
    let target: AnyObject
    let action: Selector
    
    init(target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
    }
    
    var hashValue: Int {
        get{
            return target.hashValue ^ action.hashValue
        }
    }
}

func ==(lhs: TargetActionPair, rhs: TargetActionPair) -> Bool {
    return lhs.target.isEqual(rhs.target) && lhs.action == rhs.action
}