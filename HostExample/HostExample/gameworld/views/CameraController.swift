//
//  CameraController.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

class CameraPerspective {
    var orientation:SCNVector3!
    var position:SCNVector3!
    
    var minX:CFloat!
    var maxX:CFloat!
    var minY:CFloat!
    var maxY:CFloat!
    var minZ:CFloat!
    var maxZ:CFloat!
    
    
    var zoomPositionStart:SCNVector3?
    var panPositionStart:SCNVector3?
    

    func initRoot(orientation:SCNVector3, position:SCNVector3) {
        self.orientation = orientation
        self.position = position
        //self.key = key
        
        zoomPositionStart = nil
    }
    
    init(orientation:SCNVector3, position:SCNVector3) {
        initRoot(orientation, position:position)
    }

    
    init(camera:Camera) {
        // copy transform from existing camera
        initRoot(camera.orientationHandle.eulerAngles, position:camera.positionHandle.position)
    }
    
    func transformCamera(camera:Camera) {
        camera.positionHandle.position = self.position
        camera.orientationHandle.eulerAngles = self.orientation
    }
    
    
    func setLimits(x:CFloat,y:CFloat,z:CFloat,X:CFloat,Y:CFloat,Z:CFloat) {
        
        minX = x
        minY = y
        minZ = z
        maxX = X
        maxY = Y
        maxZ = Z
        
    }
    
    func cachePosition(position:SCNVector3){
        
        // save position relative to perspective
        
    }
}


class Camera {
    
    // TODO set camera limits based on table and/or players
    // TABLE_RADIUS 600
    
//    var playerDefaultPerspective = CameraPerspective(orientation: SCNVector3Make(-CFloat(M_PI * 0.15), 0, 0), position: SCNVector3Make(0,150,Float(TABLE_RADIUS*0.75)))
//    
//    // position over table
//    var tableDefaultPerspective = CameraPerspective(orientation: SCNVector3Make(-CFloat(M_PI_2),0,0), position: SCNVector3Make(0, 250, 0))
    
    let MAX_X:CFloat = CFloat(150)
    let MAX_Y:CFloat = CFloat(400)
    let MAX_Z:CFloat = CFloat(450)
    
    let MIN_X:CFloat = CFloat(-150)
    let MIN_Y:CFloat = CFloat(100)
    let MIN_Z:CFloat = CFloat(-450)
    
    
    
    
    var isInteractive = true
    var willChangePerspective = true
    
    var perspectives:NSMutableArray = []
    
    var cameraNode:SCNNode!
    var positionHandle:SCNNode!
    var orientationHandle:SCNNode!
    
    var orientation:SCNVector3!
    var position:SCNVector3!
    
    var orientationMode:OrientationMode
    
    var zoomPositionStart:SCNVector3?
    var panPositionStart:SCNVector3?
    
    enum OrientationMode {
        case PlayerHand, TableOverhead, TablePanorama, Opponent
    }
    // update gesture bindings based on camera orientation mode
    /*
        case PlayerHand
        translate card in vertical plane
    */
    /*
        case TableOverhead
        translate card in horizontal plane
    */
    
    
    init(){
        
        zoomPositionStart = nil
        panPositionStart = nil
    
        // create and add a camera to the scene
        cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        positionHandle = SCNNode()
        positionHandle.position = SCNVector3(x: 0, y: 0, z: 0)
        
        orientationHandle = SCNNode()
        
        positionHandle.addChildNode(orientationHandle)
        orientationHandle.addChildNode(cameraNode)
        
        orientationMode = OrientationMode.PlayerHand
        
        var camera = SCNCamera()
        camera.zFar = 2000
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            camera.yFov = 55
        } else {
            camera.xFov = 75
        }
        
        cameraNode.camera = camera
        
        //TODO setup general transforms
        
        //        _cameraHandleTransforms.insert(_cameraNode.transform, atIndex: 0)
        //
    }
    
    func transform(position:SCNVector3, orientation:SCNVector3, mode:OrientationMode, duration:Float) {
        
        if (!willChangePerspective) {
            return
        }
        
        willChangePerspective = false
        
        self.orientationMode = mode
        
        //self.position = position
        //self.orientation = orientation
        
        if duration>0 {
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(CFTimeInterval(duration))
        }
        
        positionHandle.position = position
        orientationHandle.eulerAngles = orientation
        
        if duration>0 {
            SCNTransaction.setCompletionBlock({ () -> Void in
                self.willChangePerspective = true
            })
            SCNTransaction.commit()
        } else {
            self.willChangePerspective = true
        }
    }
    
    func lookAtNode(target:SCNNode) {
        
        //cameraNode.camera
    }
    
    func setPerspective(){
        
    }
    
    func pan(translation:CGPoint) {
        
        if panPositionStart == nil {
            
            panPositionStart = SCNVector3Make(positionHandle.position.x,positionHandle.position.y,positionHandle.position.z)
        } else {
            
            
            let inputRatio:CFloat = CFloat(1.5)
            
            let deltaA:CFloat = CFloat(translation.x)*inputRatio
            let deltaB:CFloat = CFloat(translation.y)*inputRatio
            
            let x = panPositionStart?.x
            let y = panPositionStart?.y
            let z = panPositionStart?.z
            
            //println("original: \(x), \(y), \(z)")
            
            let computedX = x! - deltaA
            let computedY = y! + deltaB
            let computedZ = z! - deltaB
 
            
            
            // limit camera movement
            var newX:CFloat = CFloat(computedX)
            var newY:CFloat = CFloat(computedY)
            var newZ:CFloat = CFloat(computedZ)
            
            if newX > MAX_X {
                newX = MAX_X
            } else if newX < MIN_X {
                newX = MIN_X
            }
            
            if newY > MAX_Y {
                newY = MAX_Y
            } else if newY < MIN_Y {
                newY = MIN_Y
            }
            
            if newZ > MAX_Z {
                newZ = MAX_Z
            } else if newZ < MIN_Z {
                newZ = MIN_Z
            }
            
            
//            let newY:CFloat = CFloat(computedY) > y! ? min(computedY,MAX_Y) : max(computedY, MIN_Y)
//            let newZ:CFloat = CFloat(computedZ) > z! ? min(computedZ,MAX_Z) : max(computedZ, MIN_Z)
            
            
//            let newX:CFloat = CFloat(computedX)
//            let newY:CFloat = CFloat(computedY)
//            let newZ:CFloat = CFloat(computedZ)
            
            switch orientationMode {
                
            case .TableOverhead:
//                
//                println("TableOverhead")
//                println("computed: \(computedX), \(y!), \(computedZ)")
//                println("new: \(newX), \(y!), \(newZ)")
                
                // natural motion
                positionHandle.position = SCNVector3Make(newX, y!, newZ)
                //positionHandle.position = SCNVector3Make(x! - deltaA, y!, z! - deltaB)
                
                //positionHandle.position = SCNVector3Make(x! + CFloat(translation.x), y!, z! + CFloat(translation.y))
                
            case .PlayerHand:
                
//                println("PlayerHand")
//                println("computed: \(computedX), \(computedY), \(z!)")
//                println("new: \(newX), \(newY), \(z!)")
//                
                // natural motion
                positionHandle.position = SCNVector3Make(newX, newY, z!)
                //positionHandle.position = SCNVector3Make(x! - deltaA, y! + deltaB, z!)
                
                //positionHandle.position = SCNVector3Make(x! + CFloat(translation.x), y! - CFloat(translation.y), z!)
                
            default:
                println()
            }
            
        }

    }
    
    func resetPan() {
        
        println("resetPan")
        panPositionStart = nil
        
    }
    
    
    //func zoom(scale:CFloat) {
    func zoom(rotation:CFloat) {
        
        if zoomPositionStart == nil {
            zoomPositionStart = SCNVector3Make(positionHandle.position.x, positionHandle.position.y, positionHandle.position.z)
        } else {
            
            let inputRatio:CFloat = CFloat(3.5)
            
            let zoomIn = rotation > 0
            //let zoomIn = scale > 1 // zoom mapped to pinch scale
            
            let maxDelta:CFloat = CFloat(300.0)
            var delta:CFloat!
            var zoomPosition:SCNVector3!
            //var delta:CFloat = zoomIn ? -(scale-CFloat(1.0))*maxDelta : (CFloat(1.0)-scale)*maxDelta
            
            
            let x = zoomPositionStart?.x
            let y = zoomPositionStart?.y
            let z = zoomPositionStart?.z
            
            // if playerHand
            switch orientationMode {
                
            case OrientationMode.PlayerHand:
                delta = -(rotation*inputRatio/CFloat(M_PI))*maxDelta
                //delta = zoomIn ? -(rotation/CFloat(M_PI))*maxDelta : (rotation/CFloat(M_PI))*maxDelta
                //delta = zoomIn ? -(scale-CFloat(1.0))*maxDelta : (CFloat(1.0)-scale)*maxDelta
                zoomPosition = SCNVector3Make( CFloat(x!), CFloat(y!), CFloat(z!+delta) )
                
            case OrientationMode.TableOverhead:
                delta = -(rotation*inputRatio/CFloat(M_PI))*maxDelta
                //delta = zoomIn ? -(rotation/CFloat(M_PI))*maxDelta : (rotation/CFloat(M_PI))*maxDelta
                //delta = zoomIn ? -(scale-CFloat(1.0))*maxDelta : (CFloat(1.0)-scale)*maxDelta
                zoomPosition = SCNVector3Make( CFloat(x!), CFloat(y!+delta), CFloat(z!) )
                
            default:
                println("no camera binding")
            }
            
            println("delta z: \(delta)")
            
            positionHandle.position = zoomPosition
            
            // if tableOverhead
            
        }
        
    }
    
    func resetZoom() {
        println("resetZoom")
        zoomPositionStart = nil
    }
    
    // attach to player
    
    // dock a card on edge of view
        // on left edge
        // on right edge
        // on bottom edge
    
    // show edge highlights
    
    /*
    Orientations:
    
    focus hand from afar
    
    focus hand near
    
    focus single card hand
    
    overhead table
        zoom in/out
        focus single card table
    
    focus player
        from afar: hand and field
        focus on hand
        focus on field
    
    
    */
    
}