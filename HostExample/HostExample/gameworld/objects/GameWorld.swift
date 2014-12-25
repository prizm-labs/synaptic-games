//
//  GameWorld.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/17/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class GameWorld {
    
    var rootNode:SCNNode!
    var connectionManager:MultipeerManager!
    
    init(){
        rootNode = SCNNode()
        
        
        
    }
    
    func saveGameState() {
        
        // push data record to server
        
    }
    
    func receiveNodeUpates(report:NSMutableArray) {
        
        // group membership changed
        // i.e. draw to hand, hand to hover, hover to surface
        // updates orientation and starting position
        // updates data record of membership
        
        
        // run batch animation
        // gathering cards into stack
        // adjust fan for potential placement of card
        // card group reorganizes for entering/exiting member
        
        
        // node freely translating (within its current group)
        // player reorganizing hand 
        // player browsing position to play card from hand
        
        
        
        
        // update control permissions
        // i.e. player is manipulating card, so prevent others from doing so
        
    }
    
    
}