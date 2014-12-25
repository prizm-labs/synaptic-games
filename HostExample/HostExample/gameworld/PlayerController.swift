//
//  PlayerController.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SceneKit

let CURRENT_PLAYER_ID = "player1"

class Player {
    
    var rootNode = SCNNode()
    var positionIndicator:SCNNode!
    
    var origin:SCNVector3!
    
    var handGroup:CardGroup!
    var fieldGroup:CardGroup!
    
    var handPlane:SCNNode!
    
    let INDICATOR_SIZE:CGFloat = 20.0
    let HAND_PLANE_WIDTH:CGFloat = 600.0
    let HAND_PLANE_HEIGHT:CGFloat = 300.0
    
    let transitionDuration:CFloat = 0.5
    
    var id:String? = nil
    
    var isRendered = false
    
    init(id:String) {
        
        self.id = id
        
        _init()
    }
    
    
    func _init() {
        
    }
    
    func updateOrigin(origin:SCNVector3, orientation:SCNVector3) {
        
        // when another player enters or exits table
        // move position at table
        
        self.origin = origin
        
        self.rootNode.position = self.origin
        self.rootNode.eulerAngles = orientation
        
        // update all group origins
    }
    
    func updateLocalHotspot(radius:Float){
        
        // this is hostpot area near player indicator
        // in the table's plane
        
    }
    
    func setupDefaultCardGroups() {
        
    }
    
    func setupDefaultHotspots(){
        // TODO pass config from game settings or user settings
        
        // activeArea on table, sends cards to hand
        var localHotspot = Hotspot(cardGroup:handGroup)
        
//        self.circleCenter = location;  //????
//        self.circleRadius = radius;    //????
        var radius = CGFloat(50.0)
        var depth = CGFloat(10.0)
        
        var path:UIBezierPath = UIBezierPath()
        path.addArcWithCenter(CGPointZero, radius: radius, startAngle: 0.0, endAngle: CGFloat(M_PI*2.0), clockwise: true)
        path.closePath()

        var shape = SCNShape(path: path, extrusionDepth: depth)
        var origin = SCNVector3Make(0, 0, -50.0) // in front of player
        var node = SCNNode(geometry: shape)
        node.eulerAngles = SCNVector3Make(CFloat(M_PI_2),0,0)
        var localActiveArea = ActiveArea3D(node: node, location:origin, rootNode:self.rootNode)
        
        localHotspot.activeArea = localActiveArea
    }
    
    func render(origin:SCNVector3, orientation:SCNVector3, rootNode:SCNNode) {
        
        isRendered = true
        
        self.origin = origin
        
        // card groups
        handGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Fan, orientation: SCNVector3Make(0, 0, 0), origin:self.origin)
        
        fieldGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Open, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:self.origin)
        
        // objects
        self.rootNode.position = self.origin
        self.rootNode.eulerAngles = orientation
        
        
        var handPlanePath:UIBezierPath = UIBezierPath(rect: CGRectMake(-HAND_PLANE_WIDTH/2, -HAND_PLANE_HEIGHT/2, HAND_PLANE_WIDTH, HAND_PLANE_HEIGHT))
        
        var handPlaneVolume = SCNShape(path: handPlanePath, extrusionDepth: 0)
        handPlane = SCNNode(geometry:handPlaneVolume)
        handPlane.name = "playerHandPlane"
        handPlane.hidden = true
        handPlane.position = SCNVector3Zero
        
        // indicator is a floating sphere
        positionIndicator = SCNNode(geometry: SCNSphere(radius: INDICATOR_SIZE))
        positionIndicator.position = SCNVector3Zero
        
        self.rootNode.addChildNode(positionIndicator)
        self.rootNode.addChildNode(handPlane)
        
        rootNode.addChildNode(self.rootNode)
    }
    
    func playCardToGroup(card:CardNode, group:CardGroup) {
        
        handGroup.removeCard(card)
        handGroup.organize(handGroup.organizationMode, vector: SCNVector3Zero, duration: transitionDuration)
        
        group.addCard(card)
        group.organize(group.organizationMode, vector: SCNVector3Zero, duration: transitionDuration)
    }
    
    func drawCardFromGroup(card:CardNode, group:CardGroup) {
        
        group.removeCard(card)
        group.organize(group.organizationMode, vector: SCNVector3Zero, duration: transitionDuration)
        
        handGroup.addCard(card)
        handGroup.organize(handGroup.organizationMode, vector: SCNVector3Zero, duration: transitionDuration)
    }
    
    func drawCardsFromGroup(drawCount:Int, group:CardGroup){
        
        // draw from top
        
        // draw from bottom
        
    }
    
    
    
    // define hand zone
    
    // define table zone in front of player
    
    // assign user and other identifiers
    
    
    // if player, 
    // attach camera
    
}