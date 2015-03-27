//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Liuyu Zhou on 2/24/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var gameView: BezierPathsView! {
        didSet {
        }
    }
    
    let breakout = BreakoutBehavior()
    
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
        }()
    
    var alert = UIAlertController(title: "Game Over", message: "", preferredStyle: UIAlertControllerStyle.Alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakout)
        breakout.pushBall.active = false

        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: nil))
    }
    
    var breakPerRow = 5
    var numRow = 4
    var whiteSpace = CGFloat(4)
    
    @IBAction func startBall(sender: UITapGestureRecognizer) {
        if let pushBehavior = breakout.pushBall {
            pushBehavior.magnitude = 0.3
            pushBehavior.angle = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * CGFloat(M_PI)
            pushBehavior.action = { [unowned pushBehavior] in
                pushBehavior.dynamicAnimator!.removeBehavior(pushBehavior)
            }
            pushBehavior.active = true
        }
    }
    
    
    var breakSize: CGSize {
        let horizontalSize = (gameView.bounds.size.width - whiteSpace) / CGFloat(breakPerRow)
        let verticalSize = gameView.bounds.size.height / CGFloat(3) / CGFloat(numRow)
        return CGSize(width: horizontalSize - whiteSpace, height: verticalSize - whiteSpace)
    }
    
    func showBreaks() {
        for(var i = 0; i < 4; i++) {
            for(var j = 0; j < breakPerRow; j++) {
                var frame = CGRect(origin: CGPointZero, size: breakSize)
                frame.origin.x = whiteSpace + (whiteSpace + breakSize.width) * CGFloat(j)
                frame.origin.y =  CGFloat(30) + (whiteSpace + breakSize.height) * CGFloat(i)
                let breakView = UIView(frame: frame)
                
                breakView.backgroundColor = UIColor.blueColor()
//                gameView.allBreaks.append(breakView)
                gameView.addSubview(breakView)
                
                let barrierSize = breakSize
                let barrierOrigin = CGPoint(x: breakView.frame.origin.x, y: breakView.frame.origin.y)
                let path = UIBezierPath(rect: CGRect(origin: barrierOrigin, size: barrierSize))
                breakout.addBarrier(path, named: (breakPerRow * i + j))
//                gameView.setPath(path, named: String(breakPerRow * i + j))
            }
        }
    }
    
    var paddleSize: CGSize {
        return CGSize(width: CGFloat(100), height: CGFloat(20))
    }
    
    
    var paddleView: UIView?
    
    func showPaddle() {
        var frame = CGRect(origin: CGPointZero, size: paddleSize)
        frame.origin.x = gameView.bounds.size.width / 2 - paddleSize.width / 2
        frame.origin.y = gameView.bounds.size.height - CGFloat(30)
        paddleView = UIView(frame: frame)
        
        paddleView?.backgroundColor = UIColor.greenColor()
        gameView.addSubview(paddleView!)
        
        let barrierSize = CGSize(width: paddleSize.width, height: paddleSize.width)
        let barrierOrigin = CGPoint(x: paddleView!.frame.origin.x, y: paddleView!.frame.origin.y - CGFloat(20))
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        breakout.addBarrier(path, named: "paddle")
        gameView.setPath(path, named: "paddle")
    }
    
    var ballView: UIView?
    
    var ballSize: CGSize {
        return CGSize(width: CGFloat(20), height: CGFloat(20))
    }
    
    func showBall() {
        var frame = CGRect(origin: CGPointZero, size: ballSize)
        frame.origin.x = gameView.frame.midX - ballSize.width / 2
        frame.origin.y = gameView.bounds.maxY - ballSize.height  - CGFloat(50)
        ballView = UIView(frame: frame)
        ballView!.backgroundColor = UIColor.redColor()
        gameView.addSubview(ballView!)
        breakout.addBlock(ballView!)
        breakout.pushBall.active = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        removeViews()
        showBreaks()
        showPaddle()
        showBall()
        breakout.collider.addBoundaryWithIdentifier("left", fromPoint: gameView.bounds.origin, toPoint: CGPoint(x: gameView.bounds.minX, y: gameView.bounds.maxY))
        breakout.collider.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.minY), toPoint: CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.maxY))
//        breakout.collider.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x: gameView.bounds.minX, y: gameView.bounds.maxY), toPoint: CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.maxY))
        breakout.collider.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x: gameView.bounds.minX, y: gameView.bounds.minY), toPoint: CGPoint(x: gameView.bounds.maxX, y: gameView.bounds.minY))
    }
    
    
    func removeViews() {
        for itemView in gameView.subviews {
            breakout.removeBlock(itemView as UIView)
        }
    }
    

    @IBAction func move(sender: UIPanGestureRecognizer) {
        if sender.state == .Changed {
            let translation = sender.translationInView(gameView)
            if let newPaddleView = paddleView{
                if(newPaddleView.frame.origin.x + translation.x >= gameView.bounds.minX && newPaddleView.frame.origin.x + translation.x + paddleSize.width <= gameView.bounds.maxX) {
                    newPaddleView.frame.origin.x += translation.x
                    sender.setTranslation(CGPointZero, inView: gameView)
                    
                    let barrierSize = CGSize(width: paddleSize.width, height: paddleSize.width)
                    let barrierOrigin = CGPoint(x: newPaddleView.frame.origin.x, y: newPaddleView.frame.origin.y - CGFloat(20))
                    let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
                    breakout.addBarrier(path, named: "paddle")
                    gameView.setPath(nil, named: "paddle")
                    gameView.setPath(path, named: "paddle")

                }
            }
        }
    }
        
//    func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying) {
//        if let identifierAsInt = (identifier as? NSNumber)?.integerValue {
//            println("identifier = \(identifierAsInt)")
//            behavior.removeBoundaryWithIdentifier(identifierAsInt)
//            if let view = gameView.subviews[identifierAsInt] as? UIView {
//                UIView.animateWithDuration(0.2, delay: 0.0, options: nil,
//                    animations: { () -> Void in
//                        view.backgroundColor = UIColor.orangeColor()
//                    }) { finished in
//                        view.backgroundColor = nil
//                }
//            }
//        }
//        else if let identifierAsString = (identifier as? String) {
//            if identifierAsString == "bottom" {
//                println("identifier = \(identifierAsString)")
//                breakout.removeChildBehavior(breakout.collider)
//                breakout.removeChildBehavior(breakout.pushBall)
//                breakout.removeChildBehavior(breakout.dropBehavior)
//                presentViewController(alert, animated: true, completion: nil)
//            }
//        }
//    }
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        presentViewController(alert, animated: true, completion: nil)
    }


    
//    func showAlert() {
//        var alert = UIAlertController(title: "Game Over", message: "", preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: nil))
////        presentViewController(alert, animated: true, completion: nil)
//    }
    
}

