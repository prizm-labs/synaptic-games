//
//  Delegates.swift
//  HostExample
//
//  Created by Michael Garrido on 12/19/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit
import Foundation

@objc protocol SYNGestureRecognizerDelegate {
    
    //let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
    
    optional func syntouchesBegan(touches:NSSet, withEvent event:SYNEvent)
    optional func touchesMoved(touches:NSSet, withEvent event:SYNEvent)
    optional func touchesEnded(touches:NSSet, withEvent event:SYNEvent)
    optional func touchesCancelled(touches:NSSet, withEvent event:SYNEvent)
    
    //func broadcastEvent()
    //    touchesBegan:withEvent: method when one or more fingers touch down on the screen.
    //    touchesMoved:withEvent: method when one or more fingers move.
    //    touchesEnded:withEvent: method when one or more fingers lift up from the screen.
    //    touchesCancelled:withEvent: method when the touch sequence is canceled by a system event, such as an incoming phone call.
}

class SYNGestureRecognizer {
    var delegate:SYNGestureRecognizerDelegate?
}