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
    
    // 1
    //let player = SKSpriteNode(imageNamed: "player")
    let player = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(30.0, 30.0))
    
    override func didMoveToView(view: SKView) {
        
        let app = UIApplication.sharedApplication() as SYNApplication
        app.responder.delegate = self
        
        // 2
        backgroundColor = SKColor.whiteColor()
        // 3
        player.position = CGPoint(x: 50.0, y: 50.0)
        // 4
        addChild(player)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        // 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        println("touch location: \(touchLocation)")
    }
    
    func syntouchesBegan(touches: NSSet, withEvent event: SYNEvent) {
        println("touchesBegan: \(touches)")
        
        var touch:SYNTouch? = touches.anyObject() as? SYNTouch
        println("window location: \(touch?.locationInView(nil))")
        //println("view location: \(touch?.locationInView(self.view))")
        var p = touch?.locationInNode(self)
        
        if (p != nil) {
            println("touch in overlay \(p?.x) , \(p?.y)")
            
            player.position = p!
        }
        
    }
}