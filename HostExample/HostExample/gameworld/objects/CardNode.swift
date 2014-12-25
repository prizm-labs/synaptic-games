//
//  CardNode.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class CardSize {
    
    
    var height:CGFloat!
    var width:CGFloat!
    var cornerRadius:CGFloat!
    var thickness:CGFloat!
    
    init(height:CGFloat, width:CGFloat, cornerRadius:CGFloat, thickness:CGFloat) {
        self.height = height
        self.width = width
        self.cornerRadius = cornerRadius
        self.thickness = thickness
    }
    
    func scale(ratio:CGFloat) {
        self.height = ratio*self.height
        self.width = ratio*self.width
        self.cornerRadius = ratio*self.cornerRadius
        self.thickness = ratio*self.thickness
    }
}

class RootNode:SCNNode {
    
    var parentObject:CardNode!
    
    init(parentObject:CardNode) {
        super.init()
        self.parentObject = parentObject
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class CardNode {
    
    enum RenderModes {
        case FrontAndBack
        case FrontOnly
        case BackOnly
        case BodyOnly
    }
    
    var isFlipped = false
    var gesturesDisabled = false
    
    var size:CardSize!
    
    var orientation:SCNVector3!
    
    //var rootNode:SCNNode!
    var rootNode:RootNode!
    
    var positionHandle:SCNNode!
    var orientationHandle:SCNNode!
    
    var currentRenderMode = RenderModes.FrontAndBack
    var currentGroup:CardGroup? = nil
    
    var _cardBack:SCNNode!
    var _cardFront:SCNNode!
    var _cardBody:SCNNode!
    
    
    init(size:CardSize, cardFrontImage:UIImage, cardBackImage:UIImage){
        
        
        self.size = size
        
        self.orientation = SCNVector3Zero
        
        //rootNode = SCNNode()
        rootNode = RootNode(parentObject: self)
        
        positionHandle = SCNNode()
        orientationHandle = SCNNode()
        
        var cardPath:UIBezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: size.cornerRadius)
    
        var cardVolume = SCNShape(path: cardPath, extrusionDepth: size.thickness)
        var cardFrontPlane = SCNShape(path: cardPath, extrusionDepth: 0)
        var cardBackPlane = SCNShape(path: cardPath, extrusionDepth: 0)
        
        _cardBack = SCNNode(geometry: cardBackPlane)
        _cardBack.name = "cardBack"
        _cardBack.pivot = SCNMatrix4MakeTranslation(CFloat(size.width)*0.5, CFloat(size.height)*0.5, 0)
        //cardBack.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR), CFloat(CARD_HEIGHT*CARD_RESIZE_FACTOR), 0)
        
        var backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = cardBackImage
        backMaterial.locksAmbientWithDiffuse = true
        backMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        _cardFront = SCNNode(geometry: cardFrontPlane)
        _cardFront.name = "cardFront"
        _cardFront.pivot = SCNMatrix4MakeTranslation(CFloat(size.width)*0.5, CFloat(size.height)*0.5, 0)
        
        var frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents =  cardFrontImage
        frontMaterial.locksAmbientWithDiffuse = true
        frontMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        var cardPlaneOffset = CFloat(size.thickness) / 2.0 + 0.01
        
        _cardFront.geometry?.firstMaterial = frontMaterial
        _cardFront.position = SCNVector3Make(0, 0, cardPlaneOffset)
        
        _cardBack.geometry?.firstMaterial = backMaterial
        _cardBack.position = SCNVector3Make(0, 0, -cardPlaneOffset)
        _cardBack.eulerAngles = SCNVector3Make(0, CFloat(M_PI), 0)
        //_cardBack.rotation = SCNVector4Make(0, 1.0, 0, CFloat(M_PI))
        
        
        _cardBody = SCNNode(geometry: cardVolume);
        _cardBody.name = "cardBody"
        _cardBody.pivot = SCNMatrix4MakeTranslation(CFloat(size.width)*0.5, CFloat(size.height)*0.5, 0)
        //        cardNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        //        cardNode.physicsBody?.restitution = 0.01
        //        cardNode.physicsBody?.mass = 5
        //        cardNode.physicsBody?.angularVelocity = SCNVector4Make(5, 1, 1, 1)
        
        rootNode.addChildNode(_cardBody)
        rootNode.addChildNode(_cardFront)
        rootNode.addChildNode(_cardBack)
        
        orientationHandle.addChildNode(rootNode)
        positionHandle.addChildNode(orientationHandle)
        
        //updateRenderMode(currentRenderMode)
        
    }
    
    func setOrientation(orientation:SCNVector3) {
        
        // define the plane for card transform: top-right corner
        // direction = x-axis positive, front facing
        // orientation = y-axis positive, front facing
        
        
        // define transform for face-up in plane
        // define transform for face-down in plane
        
        println("setOrientation: \(orientation.x), \(orientation.y), \(orientation.z)")
        self.orientation = orientation
        //rootNode.eulerAngles = orientation
        orientationHandle.eulerAngles = orientation
    }
    
    func flip(duration:Float) {
        
        if gesturesDisabled {
            return
        }
        
        gesturesDisabled = true
            
        println("card:flip, \(rootNode.rotation), \(rootNode.eulerAngles)")
        
        //TODO check if render mode should be updated
        //i.e. should identity be revealed?
        
        if duration>0 {
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(CFTimeInterval(duration))
            
            SCNTransaction.setCompletionBlock({ () -> Void in
                var rotationNeutral:CFloat = self.isFlipped ? CFloat(M_PI) : 0
                self.rootNode.rotation = SCNVector4Make(0, 1.0, 0, rotationNeutral)
                
                self.gesturesDisabled = false
            })
        }
        
        isFlipped = !isFlipped
        
        var rotation:CFloat = isFlipped ? CFloat(M_PI-0.01) : CFloat(2*M_PI-0.01)
        
        // Flip across relative y-axis, facing UP
        rootNode.rotation = SCNVector4Make(0, 1.0, 0, rotation)

        if duration>0 {
            SCNTransaction.commit()
        }
        
    }
    
    func updateRenderMode(mode:RenderModes){
        
        // case: front and back only
        // when card is floating/moving in space
        
        // case: front and body only
        // when card is face-up on table
        
        // case: back and body only
        // when card is face-down on table
        // when card is partiallly overlapped in stack
        
        // case: body only
        // when card is fully overlapped in stack
        
        println("updateRenderMode")
        
        currentRenderMode = mode
        
        switch currentRenderMode {
            
        case .FrontAndBack:
            println("FrontAndBack")
            _cardFront.hidden = false
            _cardBack.hidden = false
            _cardBody.hidden = true
            
        case .FrontOnly:
            println("FrontOnly")
            _cardFront.hidden = false
            _cardBack.hidden = true
            //_cardBody.hidden = false
            _cardBody.hidden = true
            
        case .BackOnly:
            println("BackOnly")
            _cardFront.hidden = true
            _cardBack.hidden = false
            //_cardBody.hidden = false
            _cardBody.hidden = true
            
        case .BodyOnly:
            println("BodyOnly")
            _cardFront.hidden = true
            _cardBack.hidden = true
            _cardBody.hidden = false

            
        }
        
    }

}