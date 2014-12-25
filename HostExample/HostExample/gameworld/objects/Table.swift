//
//  Table.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class Table {
    
    
    // dimensions
    var radius:CGFloat!
    var depth:CGFloat!
    
    // tabletop, circle
    var rootNode:SCNNode!
    var tableNode:SCNNode!
    //
    
    var players:[Player] = []
    
    init(radius:CGFloat,depth:CGFloat){
        
        self.radius = radius
        self.depth = depth
        
        rootNode = SCNNode()
        
        var tablePath:UIBezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.radius, height: self.radius), cornerRadius: self.radius)
        
        var tableGeometry = SCNShape(path: tablePath, extrusionDepth: self.depth)

        var tableMaterial = SCNMaterial()
        //tableMaterial.diffuse.contents =  "green-felt.jpg"
//        tableMaterial.diffuse.contents = UIImage(named:"green-felt.jpg")
        tableMaterial.diffuse.contents = UIColor.grayColor()
        tableMaterial.locksAmbientWithDiffuse = true
        tableMaterial.diffuse.wrapS = SCNWrapMode.Repeat
        tableMaterial.diffuse.wrapT = SCNWrapMode.Repeat
        tableMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        tableGeometry.firstMaterial = tableMaterial
        
        tableNode = SCNNode(geometry: tableGeometry)
        tableNode.name = "table"
        tableNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
        tableNode.physicsBody?.restitution = 1.0
        tableNode.eulerAngles = SCNVector3Make(CFloat(M_PI/2), 0, 0)
        tableNode.pivot = SCNMatrix4MakeTranslation(CFloat(self.radius)*0.5, CFloat(self.radius)*0.5, 0)
        
        rootNode.position.y -= CFloat(self.depth/2.0)
        
        rootNode.addChildNode(tableNode)
    }
    
    
    func generatePlayerPositions(playerCount:Int){
        
        //spawnPlayer(SCNVector3Zero)
        
    }
    
    
    func spawnPlayer(origin:SCNVector3) {
        
        
        
    }
    
    
    // player count
    
    // spawn player
    
    // arrange players around table
    
    
    
    // set play point
    // highlight play point
    
        // spawn deck
    
        // place a card
        // place a deck
    
    
    
}