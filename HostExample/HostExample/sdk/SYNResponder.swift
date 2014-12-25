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
    case Touches, Networking, Configuration, Presence
}

enum SYNEventSubtype {
    case FoundHost, ConnectedToHost, DisconnectedFromHost
    case CalibratedScreenSize, SyncedClocks
}

class SYNTag:NSObject {
    var id:NSString!
    var data:NSMutableDictionary?
    
    init(id:NSString, data:NSMutableDictionary) {
        self.id = id
        self.data = data
    }
}

class SYNTouch:NSObject {
    
    var phase:SYNTouchPhase!
    var timestamp:NSTimeInterval!
    
    var location:CGPoint!
    var id:Int
    var updated:Bool
    
    var view:UIView!
    
    var RFID:String? = nil
    
    init(timestamp:NSTimeInterval, location:CGPoint, view:UIView, id:Int){

        self.timestamp = timestamp
        self.location = location
        self.id = id
        self.view = view
        
        self.updated = true
        self.phase = SYNTouchPhase.Began
        
        super.init()
    }
    
    func locationInNode(node:SKNode) -> CGPoint {
        //return CGPointMake(0,0)
        
        // assuming self.location has already been translated into UIWindow coordinates
        // with origin at top-left
        
        // assuming 568 x 320 frame
        
        // y-axis for SKNode is inverted from UIWindow/View (origin at bottom-left)
        
        // assuming root node as SKScene
        let window = UIApplication.sharedApplication().keyWindow!
        let height:CGFloat = window.frame.size.height
        
        return CGPointMake(self.location.x, CGFloat(height-self.location.y))
        //return self.location
    }
    
    func locationInView(view:UIView?) -> CGPoint {
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
        self.subtype = subtype
        
        super.init()
    }
    
    func allTouches(){
        
    }
    
    func anyObject(){
        
    }
}

// SYNTouchResponder
// for generic multitouch

// SYNPresenceResponder
// for RFID tags

// SYNNetworkResponder
// for pairing of host device to local SDP and DDP servers
// for communication to cloud server i.e. developer portal provisioning
// for notifications of other player devices connect/disconnet
// will interface with DDP server


class SYNResponder {
    // dispatch touch events to views
    
    var delegate: SYNGestureRecognizerDelegate?
    
    var touches:NSMutableSet
    var touchIDs:NSMutableSet
    
    var tagCache:NSMutableSet
    var tags:NSMutableSet
    
    
    init(){
        self.touchIDs = NSMutableSet(array: [])
        self.touches = NSMutableSet(array: [])
        self.tagCache = NSMutableSet(array: [])
        self.tags = NSMutableSet(array: [])
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
        //println("removeTouch")
        self.touchIDs.removeObject(touch.id)
        self.touches.removeObject(touch)
    }
    
    func resetTouchesForUpdate() {
        for touch in self.touches.allObjects {
            let touch:SYNTouch = touch as SYNTouch
            touch.updated = false
        }
    }
    
    func translatePointForWindow(point:CGPoint, window:UIWindow) -> CGPoint {
        // UIWindow and UIView origin is top-left corner
        // SKNode origin is bottom-left corner
        
        // will receive point within live area
        // on axis from 0-1000
        
        // screen mapping could be:
        // - mirrored (might not fill entire display)
        // - external (should fill entire display)
        
        // if mirrored,
        // get screen size of host device
        // - iPhone5 320 x 568
        
        return CGPointMake(0, 0)
    }
    
    func updateRFIDTagsFromPointData(point:JSON) {
        let rfid = point["rfid"].dictionaryValue
        println("RFI data: \(rfid)")
    }
    
    func updateRFIDTagsFromSet(set:NSSet) {
        
        
        
    }
    
    func updateTouchFromPointData(point:JSON) {
        //println("updateTouchFromPointData ==============")
        //println("point data: \(point)")
        let id:Int = point["id"].integerValue!
        let x:CGFloat = CGFloat(point["x"].integerValue!)
        let y:CGFloat = CGFloat(point["y"].integerValue!)
        
        if let rfid = point["rfid"].dictionaryValue {
            println("Found RFID data on point!")
            self.updateRFIDTagsFromPointData(point)
        }
        
        let globalPoint = CGPointMake(x,y)
        
        // get top-most view containing point
        let view = self.getViewContainingPoint(globalPoint)
        //let localPoint = view.po
        
        // check touchIDs for new,update,delete touches
        if (self.touchIDs.containsObject(id)) {
            // existing touch
            
            
            for touch in touches.allObjects {
                let touch:SYNTouch = touch as SYNTouch
                
                //println("touch id: \(touch.id) | data id: \(id)")
                
                if (touch.id == id) {
                    //println("touch location: \(touch.location) | data location: \(globalPoint)")
                    if (!CGPointEqualToPoint(touch.location, globalPoint)) {
                        touch.location = globalPoint
                        touch.phase = SYNTouchPhase.Moved
                    } else {
                        touch.phase = SYNTouchPhase.Stationary
                    }
                    
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
            
            //println("was touch \(touch.id) updated? \(touch.updated)")
            
            if (!touch.updated) {
                touch.phase = SYNTouchPhase.Ended
                // BROADCAST TOUCHES ENDED
            }
            
        }
        
        // cleanup touches that ended
        for touch in touches.allObjects {
            let touch:SYNTouch = touch as SYNTouch
            
            //println("touch \(touch.id) phase: \(touch.phase)")
            
            if (touch.phase == SYNTouchPhase.Ended) {
                self.removeTouch(touch)
            }
        }
    }
    
    func updatesTouchesFromData(json:JSON) {
        //println("updatesTouchesFromData ==============")
        
        //println("json: \(json)")
        
        if let points:Array = json["points"].arrayValue {
            if (points.count==0) {
                // all touches ended
                
                for touch in touches.allObjects {
                    let touch:SYNTouch = touch as SYNTouch
                    touch.phase = SYNTouchPhase.Ended
                }
                
                // BROADCAST TOUCHES ENDED
                self.clearTouches()
                
            } else {
                // touches have began, moved, or ended
                
                for point in points {
                    self.updateTouchFromPointData(point)
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
        //println("broadcastEvent ===================")
        
        //NSNotificationCenter.defaultCenter().postNotificationName("touches", object:self.touches.anyObject())
        
        // touches event
        self.delegate?.syntouchesBegan!(self.touches, withEvent: event)
        
    }
}