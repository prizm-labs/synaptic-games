//
//  SYNResponder.swift
//  HostExample
//
//  Created by Michael Garrido on 12/20/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit

enum SYNTouchPhase {
    case Began, Moved, Stationary, Ended, Cancelled
}

enum SYNEventType {
    case Touches, Pairing, Configuration
}

enum SYNEventSubtype {
    case FoundHost, ConnectedToHost, DisconnectedFromHost
    case CalibratedScreenSize, SyncedClocks
}

class SYNTouch:NSObject {
    
    var phase:SYNTouchPhase!
    var timestamp:NSTimeInterval!
    
    var location:CGPoint!
    var id:Int
    var updated:Bool
    
    var view:UIView!
    
    init(timestamp:NSTimeInterval, location:CGPoint, view:UIView, id:Int){

        self.timestamp = timestamp
        self.location = location
        self.id = id
        self.view = view
        self.updated = true
        
        super.init()
    }
    
    func locationInNode(node:SKNode) -> CGPoint {
        //return CGPointMake(0,0)
        return self.location
    }
    
    func locationInView(view:UIView) -> CGPoint {
        //return CGPointMake(0,0)
        return self.location
    }
    
    func previousLocationInView(view:UIView) -> CGPoint {
        return CGPointMake(0,0)
    }
}

class SYNEvent:NSObject {

    var type:SYNEventType
    var subtype:SYNEventSubtype?
    var touches:NSSet?
    
    init(type:SYNEventType, subtype:SYNEventSubtype?){
        
        self.type = type
        self.subtype = subtype!
        
        super.init()
    }
    
    func allTouches(){
        
    }
    
    func anyObject(){
        
    }
}

class SYNResponder {
    // dispatch touch events to views
    
    var delegate: SYNGestureRecognizerDelegate?
    var touches:NSMutableSet
    var touchIDs:NSMutableSet
    
    init(){
        self.touchIDs = NSMutableSet(array: [])
        self.touches = NSMutableSet(array: [])
    }
    
    func getViewContainingPoint(point:CGPoint) -> UIView {
        let app = UIApplication.sharedApplication()
        let rootViewController = app.keyWindow?.rootViewController!
        let view = rootViewController?.view!
        return view!
    }
    
    func clearTouches() {
        self.touchIDs.removeAllObjects()
        self.touches.removeAllObjects()
    }
    
    func removeTouch(touch:SYNTouch) {
        self.touchIDs.removeObject(touch.id)
        self.touches.removeObject(touch)
    }
    
    func resetTouchesForUpdate() {
        for touch in self.touches.allObjects {
            let touch:SYNTouch = touch as SYNTouch
            touch.updated = false
        }
    }
    
    func translatePointForWindow(point:CGPoint) -> CGPoint {
        // UIWindow and UIView origin is top-left corner
        // SKNode origin is bottom-left corner
        
        return CGPointMake(0, 0)
    }
    
    func updatesTouchesFromData(data:NSData) {
        println("updatesTouchesFromData")
        
        let json = JSON(object: data)
        
        let points:Array = json["points"].arrayValue!
        
        if (points.count==0) {
            // all touches ended
            self.clearTouches()
            
        } else {
            // touches have began, moved, or ended
            
            for point in points {
                
                println("point data: \(point)")
                let id:Int = point["id"].integerValue!
                let x:CGFloat = CGFloat(point["x"].integerValue!)
                let y:CGFloat = CGFloat(point["y"].integerValue!)
                
                
                
                
                let globalPoint = CGPointMake(x,y)
                
                // get top-most view containing point
                let view = self.getViewContainingPoint(globalPoint)
                //let localPoint = view.po
                
                // check touchIDs for new,update,delete touches
                if (self.touchIDs.containsObject(id)) {
                    // existing touch
                    
                    for touch in touches.allObjects {
                        let touch:SYNTouch = touch as SYNTouch
                        
                        if (touch.id == id) {
                            touch.location = globalPoint
                            touch.updated = true
                        }
                    }
                    
                    // BROADCST TOUCHES MOVED
                    
                } else {
                    // a new touch!
                    self.touchIDs.addObject(id)
                    
                    let touch = SYNTouch(timestamp: NSTimeInterval(), location: globalPoint, view: view, id: id)
                    
                    self.touches.addObject(touch)
                    
                    // BROADCAST TOUCHES BEGAN
                }
                
                
                // check for deleted points
                for touch in touches.allObjects {
                    let touch:SYNTouch = touch as SYNTouch
                    
                    if (!touch.updated) {
                        self.removeTouch(touch)
                        
                        // BROADCAST TOUCHES ENDED
                    }
                    
                }
                
                
                
            }
        }
        
        
        // Set timestamps for touches
        
        // Set timestamp for event
        
        // compare cached touches and determine
        // touchesBegan
        // touchesMoved
        // touchesEnded
        
        
        // Do touches of touches{PHASE} event only contain touches with the corresponding {PHASE}?
        
        
        let event = SYNEvent(type:SYNEventType.Touches, subtype:nil)
        
        // TODO set delay for event dispatch
        // based on diference between fseq of last data and current data???
        // and
        
        self.broadcastEvent(event)
    }
    
    func broadcastEvent(event:SYNEvent){
        println("broadcastEvent")
        
        
        self.delegate?.syntouchesBegan!(self.touches, withEvent: event)
        
    }
}