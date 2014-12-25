//
//  PlayPoint.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/23/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit
import UIKit

class PlayPoint {
    
    var rootNode:SCNNode!
    var indicatorNode:SCNNode!
    var highlightNode:SCNNode!
    
    var currentGroup:CardGroup? = nil
    
    var isFlipped = false
    
    let ORB_RADIUS:CGFloat = CGFloat(10.0)
    
    // animate creation
    // set detection radius
    // show dormant indicator
    
    // link active edge
    
    // detect pending object
    // show active indicator, about to receive object
    // show action path into point
    
    // release pending object
    // show dormant indicator
    
    // commit object
    // animate object to point
    // release object
    
    // animate destruction
    
    init(position:SCNVector3, group:CardGroup, isFlipped:Bool){
        
        rootNode = SCNNode()
        
        currentGroup = group
        
        indicatorNode = SCNNode(geometry: SCNSphere(radius: ORB_RADIUS))
        rootNode.addChildNode(indicatorNode)
        
        rootNode.position = position
        
        // card will take orientation from group
        
        self.isFlipped = isFlipped
    }
    
    func updatePosition(position:SCNVector3) {
        
        rootNode.position = position
        
        //TODO animate indicator feedback: pulsing, glowing
        
    }
    
    func receiveCard(card:CardNode, isFlipped:Bool) {
        
        card.currentGroup?.removeCard(card)
        
        let placements = currentGroup?.addCardAtPosition(card, position: rootNode.position, isFlipped: isFlipped)
        
        currentGroup?.commitPlacements(placements!, duration: 1.0)
    }
    
}

class GhostAction {
    
    // origin
    // destination
    
    // path 
    
    // ghost object
    
}