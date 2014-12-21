//
//  SynapticDelegate.swift
//  HostExample
//
//  Created by Michael Garrido on 12/19/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import UIKit

//class SYNResponder {}

class SYNSocket: NSObject {
    
    var inputStream:NSInputStream!
    var outputStream:NSOutputStream!
    var bundleCache:NSMutableArray = NSMutableArray()
    
    var streamCache:NSString? = nil
    var streamFeed:NSString? = nil

//    var host:String!
//    var port:UInt32!
    
    init(host:String, OnPort port:UInt32) {
        
        println("SYNSocket init")
        
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, "10.0.1.23", 1337, &readStream, &writeStream)
        //CFStreamCreatePairWithSocketToHost(nil, "192.168.1.165", 1337, &readStream, &writeStream)
        
        // Documentation suggests readStream and writeStream can be assumed to
        // be non-nil. If you believe otherwise, you can test if either is nil
        // and implement whatever error-handling you wish.
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        //self.host = host
        //self.port = port
        
        super.init()
    }
    
}