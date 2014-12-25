//
//  GameScene.swift
//  HostExample
//
//  Created by Michael Garrido on 12/24/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene, SYNGestureRecognizerDelegate {
    
    var streamCache:NSString? = nil
    var streamFeed:NSString? = nil
    
    // 1
    //let player = SKSpriteNode(imageNamed: "player")
    let player = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(30.0, 30.0))
    let looper = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(50.0, 50.0))
    
    override func didMoveToView(view: SKView) {
        
        let app = UIApplication.sharedApplication() as SYNApplication
        app.responder.delegate = self
    
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveStreamNotification:", name: "streamAlive", object: nil)
        
        backgroundColor = SKColor.whiteColor()
        
        player.position = CGPoint(x: 50.0, y: 50.0)
        looper.position = CGPoint(x: 250.0, y: 250.0)
        
        addChild(player)
        addChild(looper)
        
        runLoopAction()
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        // 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        //println("touch location: \(touchLocation)")
    }
    
    func runLoopAction(){
        var actions = Array<SKAction>();
        actions.append(SKAction.moveTo(CGPoint(x:300,y:300), duration: 1));
        actions.append(SKAction.rotateByAngle(6.28, duration: 1));
        actions.append(SKAction.moveBy(CGVectorMake(150,0), duration: 1));
        actions.append(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 0.5, duration: 1));
        let sequence = SKAction.sequence(actions);
        //looper.runAction(sequence);
        looper.runAction(SKAction.repeatActionForever(sequence));
    }
    
    func syntouchesBegan(touches: NSSet, withEvent event: SYNEvent) {
        //println("touchesBegan: \(touches)")
        
        var touch:SYNTouch? = touches.anyObject() as? SYNTouch
        //println("window location: \(touch?.locationInView(nil))")
        //println("view location: \(touch?.locationInView(self.view))")
        var p = touch?.locationInNode(self)
        
        if (p != nil) {
            //println("touch in overlay \(p?.x) , \(p?.y)")
            
            //player.position = p!
            println("new position: \(p)")
            //println("actual position: \(player.position)")
            
            let point = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(10.0, 10.0))
            point.position = p!
            
            addChild(point)
            var actions = Array<SKAction>();
            actions.append(SKAction.waitForDuration(5.0))
            actions.append(SKAction.fadeAlphaTo(0, duration: 1.0))
            point.runAction(SKAction.sequence(actions))
            
        }
        
    }
    
    }