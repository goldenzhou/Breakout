//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Liuyu Zhou on 2/24/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.collisionDelegate = self
        lazilyCreatedCollider.action = {
            if let gameview = self.dynamicAnimator?.referenceView? {
                if let subViews = self.dynamicAnimator?.referenceView?.subviews {
                    if let ballView = subViews[subViews.count - 1] as? UIView {
                        if CGRectContainsRect(gameview.frame, ballView.frame) == false {
                            self.dynamicAnimator?.removeBehavior(self.collider)
                            self.dynamicAnimator?.removeBehavior(self.pushBall)
                            self.dynamicAnimator?.removeBehavior(self.dropBehavior)
                            println("ddedwed")
                            
                        }
                    }
                }
            }
        }
        return lazilyCreatedCollider
    }()
    
    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying) {
        if let identifierAsInt = (identifier as? NSNumber)?.integerValue {
            println("identifier = \(identifierAsInt)")
            behavior.removeBoundaryWithIdentifier(identifierAsInt)
            if let view = dynamicAnimator?.referenceView?.subviews[identifierAsInt] as? UIView {
                UIView.animateWithDuration(0.1, delay: 0.0, options: nil,
                    animations: { () -> Void in
                        view.backgroundColor = UIColor.orangeColor()
                    }) { finished in
                        view.backgroundColor = nil
                }
            }
        }
    }
    
    var pushBall = UIPushBehavior(items: nil, mode: UIPushBehaviorMode.Instantaneous)
    
    lazy var dropBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedDropBehavior = UIDynamicItemBehavior()
        lazilyCreatedDropBehavior.allowsRotation = false
        lazilyCreatedDropBehavior.elasticity = 1
        lazilyCreatedDropBehavior.friction = 0
        lazilyCreatedDropBehavior.resistance = 0
        return lazilyCreatedDropBehavior
        }()
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(pushBall)
        addChildBehavior(dropBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: NSCopying) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }

    
    func addBlock(block: UIView) {
        dynamicAnimator?.referenceView?.addSubview(block)
        pushBall.addItem(block)
        collider.addItem(block)
        dropBehavior.addItem(block)
    }
    
    func removeBlock(block: UIView) {
        collider.removeItem(block)
        pushBall.removeItem(block)
        dropBehavior.removeItem(block)
        block.removeFromSuperview()
    }
    
}
