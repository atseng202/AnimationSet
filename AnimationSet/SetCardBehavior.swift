//
//  SetCardBehavior.swift
//  AnimationSet
//
//  Created by Alan Tseng on 2/2/18.
//  Copyright © 2018 Alan Tseng. All rights reserved.
//

import UIKit

class SetCardBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
       let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.resistance = 0
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi/2).arc4Random
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi - (CGFloat.pi / 2).arc4Random
            case let (x, y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi/2).arc4Random
            case let (x,y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi + (CGFloat.pi/2).arc4Random
            default:
                push.angle = (CGFloat.pi*2).arc4Random
            }
        }
        
        push.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4Random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        itemBehavior.addAngularVelocity(10, for: item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}

extension CGFloat {
    var arc4Random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            return CGFloat(0)
        }
    }
}
