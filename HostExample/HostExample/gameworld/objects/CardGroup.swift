//
//  CardGroup.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

// custom equivalence test
// http://stackoverflow.com/questions/24019076/generic-type-with-custom-object-in-swift-language

struct CardPlacement {
    var card:CardNode?
    var position:SCNVector3?
    var isFlipped:Bool
}

class CardGroup :Equatable {
    
    enum TransitionType {
        case Direct
    }
    
    enum OrganizationMode {
        case Open
        case Stack
        case Fan
        case Vector
    }
    
    var cards:NSMutableArray = []
    var organizationMode:OrganizationMode
    var orientation:SCNVector3!
    var origin:SCNVector3!
    
    var isFlipped:Bool = false
    
    // origin
    
    init(organizationMode:OrganizationMode, orientation:SCNVector3, origin:SCNVector3){
        
        self.organizationMode = organizationMode
        self.orientation = orientation
        self.origin = origin // within scene.rootNode
        
    }
    
    func addCard(card:CardNode){
        println("addCard")
        if !cards.containsObject(card) {
            
            if card.currentGroup != nil {
                return;
            } else {
                cards.addObject(card)
                card.currentGroup = self
            }
            
        }
        println("card group \(self.cards.count)")
    }
    
    func addCardAtPosition(card:CardNode, position:SCNVector3, isFlipped:Bool)->[CardPlacement] {
        
        println("addCardAtPosition")
        
        addCard(card)
        
        var placements:[CardPlacement] = []
        
        switch organizationMode {
            
        // for open mode
        // card will be added at same point in plane
        // or translated along a normal from position to the plane (i.e. if hovering above table surface)
            
        case .Open:
            println("Open")
            placements.append(CardPlacement(card: card, position: position, isFlipped: isFlipped))
            
        default:
            println("no binding")
            
        }
        
        // for fan mode
        // card will be added at index (among other cards) closest to position
        
        return placements
    }
    
    func addCards(cards:NSMutableArray) {
        println("addCards")
        for card in cards {
            let card:CardNode = card as CardNode
            self.addCard(card)
        }
        println("card group \(self.cards.count)")
    }
    
    
    
    func removeCard(card:CardNode){
        println("removeCard")
        
        if self.cards.containsObject(card) {
            self.cards.removeObject(card)
            
            card.currentGroup = nil
            
        }
        
    }
    
    func removeCards(cards:[CardNode]) {
        println("removeCards")
        for card in cards {
            let card:CardNode = card as CardNode
            removeCard(card)
        }
    }
    
    func commitPlacements(placements:[CardPlacement], duration:CFloat) {
        
        // generate positions for updated cards
 
        // animate cards into position
        
        for placement in placements {
            
            
            let card = placement.card
            let position = placement.position
            let isFlipped = placement.isFlipped
            
            
            // flip card before moving
            
            if (isFlipped != card?.isFlipped) {
                
                println("flipping card into playPoint")
                card?.flip(1.0)
            }
            
            if duration>0 {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(CFTimeInterval(duration))
                SCNTransaction.setCompletionBlock({ () -> Void in
                    //cardNode.updateRenderMode(CardNode.RenderModes.BackOnly)
                    //cardNode.updateRenderMode(CardNode.RenderModes.FrontAndBack)
                    
                })
            }
            
            card?.orientationHandle.eulerAngles = self.orientation
            card?.positionHandle.position = position!
            
            if duration>0 {
                SCNTransaction.commit()
            }
        }
        
    }
    
    func organize(mode:OrganizationMode, vector:SCNVector3, duration:CFloat) {

        organizationMode = mode
        
        
        //TODO refactor into generating placements per mode, then commit placements
        
        switch organizationMode {
            
        case .Open:
            println("Open")
            
            
        case .Stack:
            println("Stack")
            for (index, cardNode) in enumerate(cards) {
                
                var cardNode:CardNode = cards[index] as CardNode

                
                if duration>0 {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(CFTimeInterval(duration))
                    SCNTransaction.setCompletionBlock({ () -> Void in
                        //cardNode.updateRenderMode(CardNode.RenderModes.BackOnly)
                        cardNode.updateRenderMode(CardNode.RenderModes.FrontAndBack)

                    })
                } else {
                    //cardNode.updateRenderMode(CardNode.RenderModes.BackOnly)
                    cardNode.updateRenderMode(CardNode.RenderModes.FrontAndBack)
                }
                
                cardNode.setOrientation(self.orientation)
                //cardNode.rootNode.eulerAngles = self.orientation
                
                // TODO stack along vector
                // like evenly spreading a stack in a direction
                
                // Stack height by index
//                cardNode.rootNode.position = self.origin
//                cardNode.rootNode.position.y = Float(cardNode.size.thickness) * (Float(index)*2.0+0.5)
                
                cardNode.positionHandle.position = self.origin
                cardNode.positionHandle.position.y = Float(cardNode.size.thickness) * (Float(index)*2.0+0.5)
                
                if duration>0 {
                    SCNTransaction.commit()
                }
            }
            
            
        case .Fan:
            println("Fan")
            
            var placements:[CardPlacement] = []
            
            for (index, cardNode) in enumerate(cards) {
                
                var cardNode:CardNode = cards[index] as CardNode
                
                cardNode.updateRenderMode(CardNode.RenderModes.FrontAndBack)
                
                if cards.count==1 {
                    placements.append(CardPlacement(card: cardNode, position: self.origin, isFlipped: cardNode.isFlipped))
                } else {
                    
                    // TODO generate curve path
                    // TODO generate positoions along path, evenly distributed
                    
                    // 0, ... , MAX
                    
                    let targetWidth:CFloat = min( CFloat(cardNode.size.width)*0.75*CFloat(cards.count), CFloat(200.0) )
                    
                    let x = self.origin.x-targetWidth/2.0 + CFloat(index)*(targetWidth/CFloat(cards.count-1))
                    
                    let y = self.origin.y
                    
                    // Offset for stacking
                    let z = self.origin.z + CFloat(cardNode.size.thickness) * (CFloat(index)+0.5)
                    
                    placements.append(CardPlacement(card: cardNode, position: SCNVector3Make(x, y, z), isFlipped: cardNode.isFlipped))
  
                }
                
                // TODO transform these points relative to player's orientation at table
                
                commitPlacements(placements, duration: 1.0)
                
//                if duration>0 {
//                    SCNTransaction.begin()
//                    SCNTransaction.setAnimationDuration(CFTimeInterval(duration))
//                }
//                
//                cardNode.orientationHandle.eulerAngles = self.orientation
//                cardNode.positionHandle.position = self.origin
//                //cardNode.rootNode.eulerAngles = self.orientation
//                
//                if duration>0 {
//                    SCNTransaction.commit()
//                }
                
            }
            
            
        case .Vector:
            println("Vector")
            
        }
        
        
    }
    // orientation
    // flat on table
    // in hand
    
    
    // auto-organize 
    // into even fan
    // into straight line
    
    
    // manipulate
    // spread fan to highlight middle card
    
    // gather and stack
    // shuffle
}

func == (left: CardGroup, right: CardGroup) -> Bool {
    return (ObjectIdentifier(left) == ObjectIdentifier(right))
}

/*
Zones:

on table

in hand

above table

*/

class CardZone {
    
    // orientation
    // horizontal
    
    
    // add card with transition
    // OutAndDown
    // i.e. draw card from deck
    // UpAndIn
    // i.e. play card from hand
    
    // straight vector translation
    
    
    // remove card
}