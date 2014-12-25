//
//  ActiveEdgeScene.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/23/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit


class UIOverlayScene:SKScene {
    
    var egdeGroups:NSMutableArray = NSMutableArray()
    var currentEdgeGroup:EdgeGroup?
    var currentHotspot:Hotspot?
    
    
    // main menu buton
    
    override init(size: CGSize) {
        
        
        super.init(size: size)
        
        
        println("overlay size: \(size.width) , \(size.height)")
        
        currentEdgeGroup = nil
        currentHotspot = nil
        
        self.backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 0.5)
        
        var scoreLabel:SKLabelNode = SKLabelNode(text: "Connect")
        scoreLabel.fontSize = 20.0
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.name = "btn:connect"
        scoreLabel.position = CGPoint(x: 50.0, y: 50.0)
        self.addChild(scoreLabel)
        
        scoreLabel.calculateAccumulatedFrame()
        
        var addPlayerLabel:SKLabelNode = SKLabelNode(text: "Add player")
        addPlayerLabel.fontSize = 20.0
        addPlayerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        addPlayerLabel.name = "btn:player/add"
        
        addPlayerLabel.position = CGPoint(x: CGFloat(size.width)-CGFloat(50.0), y: 50 )
        self.addChild(addPlayerLabel)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //on pan update (with active object) near edge
    func detectHotspotNearLocation(location:CGPoint)->Hotspot? {
        
        var hotspot:Hotspot? = currentEdgeGroup?.findHotspotNearLocation(location)
        
        if (hotspot != nil) {
            self.activateHotspot(hotspot)
        } else {
            self.deactivateHotspot()
        }
        
        return hotspot
    }
    
    func activateHotspot(hotspot:Hotspot?) {
        currentHotspot=hotspot
        currentHotspot?.updateActionState(Hotspot.ActionState.active)
    }
    
    //on pan update leaves edge
    func deactivateHotspot(){
        currentHotspot?.updateActionState(Hotspot.ActionState.inactive)
        currentHotspot = nil
    }
    
    //on pan ended and inside hotspot
    func confirmHotspot()->Bool{
        
        if currentHotspot != nil {
            
            deactivateHotspot()
            
            return true
        } else {
            return false
        }
    }
    
    
    func activateEdgeGroup() {
        
    }
    
    func deactivateEdgeGroup() {
        
    }
    
}


class EdgeGroup {
    
    var hotspots:NSMutableArray = NSMutableArray()
    
    var camera:Camera?
    
    // position on screen
    
    // PlayPoint linked
    
    // Ghost Action derived
    
    func addHotspot(location:CGPoint, playPoint:PlayPoint) {
        
        
    }
    
    func arrangeHotspots(){
        
        // when hotspot is added / removed 
        // reposition hotspots and resize radius
        
        //TODO animate changes
    }
    
    func findHotspotNearLocation(location:CGPoint)->Hotspot? {
        
        var hotspot:Hotspot? = nil
        
        
        
        return hotspot
    }
    
}

class Hotspot {
    // a hotspot links an activeArea to a playPoint or cardGroup
    // allows user to swiftly move and manipulate cards
    
    enum ActionState {
        case inactive, active, disabled
    }
    
    enum AccessType {
        case publicOnly, privateOnly, publicAndPrivate
    }
    
    var activeArea:ActiveArea? = nil
    
    var playPoint:PlayPoint? = nil
    var cardGroup:CardGroup? = nil
    
    var actionState:ActionState = ActionState.inactive
    var accessType:AccessType = AccessType.publicAndPrivate
    
    
    init(playPoint:PlayPoint) {
        //self.location = location
        self.playPoint = playPoint
    }
    
    init(cardGroup:CardGroup) {
        //self.location = location
        self.cardGroup = cardGroup
    }
    

    func updateActionState(state:ActionState) {
        
        actionState = state
        
    }
    
}

class ActiveArea {
    
    var location:CGPoint!
    
    func activate() {
        
        
    }
    
    func deactive() {
        
    }
    
    func disable() {
        
    }
    
    func enable() {
        
        
    }
}

class ActiveArea2D:ActiveArea {
    // rendered in SpriteKit layer
    // i.e. along edges
    
    var indicatorNode:SKNode?
    
    init(node:SKNode) {
        
        self.indicatorNode = node
    }
}

class ActiveArea3D:ActiveArea {
    // rendered in SceneKit layer
    // i.e. on table near player indicator
    
    var indicatorNode:SCNNode?
    
    
    init(node:SCNNode, location:SCNVector3, rootNode:SCNNode) {
        
        self.indicatorNode = node
        self.indicatorNode?.position = location
        self.indicatorNode?.name = "activeArea"
        
        rootNode.addChildNode(self.indicatorNode!)
    }
    
}