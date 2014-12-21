//
//  SYNResponder.swift
//  HostExample
//
//  Created by Michael Garrido on 12/20/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit
import Foundation

class SYNResponder {
    // dispatch touch events to views
    
    var delegate: SYNGestureRecognizerDelegate?
    var touches:NSSet!
    
    init(){
        self.touches = NSSet(array: [])
    }
    
    func updatesTouchesFromData(data:NSData) {
        println("updatesTouchesFromData")
        
        let json = JSON(object: data)
        
        // compare cached touches and determine
        // touchesBegan
        // touchesMoved
        // touchesEnded
        
        self.broadcastEvent()
    }
    
    func broadcastEvent(){
        println("broadcastEvent")
        
        let event = SYNEvent()
        self.delegate?.syntouchesBegan!(self.touches, withEvent: event)
        
    }
}