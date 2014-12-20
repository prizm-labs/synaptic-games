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

class SYNSocket: NSObject, NSStreamDelegate {
    
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
        
        // Documentation suggests readStream and writeStream can be assumed to
        // be non-nil. If you believe otherwise, you can test if either is nil
        // and implement whatever error-handling you wish.
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        //self.host = host
        //self.port = port
        
        super.init()
    }
    
//    init(fromString string: NSString) {
//        self.someProperty = string
//        super.init()
//    }
//    
//    convenience override init() {
//        self.init(fromString:"John") // calls above mentioned controller with default name
//    }
//    
    func connect() {
        
        println("SYNSocket connect")
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
//       self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
//       self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
//        self.inputStream.open()
//        self.outputStream.open()
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch(eventCode) {
        case NSStreamEvent.OpenCompleted:
            print("Stream opened");
            break;
        case NSStreamEvent.HasBytesAvailable:
            
            if (aStream == inputStream) {
                
                var buffer = [UInt8](count: 1024, repeatedValue: 0)
                while inputStream.hasBytesAvailable {
                    let result: Int = inputStream.read(&buffer, maxLength: buffer.count)
                    
                    //var output:NSString = NSString(bytes: buffer, length: result, encoding: NSASCIIStringEncoding)!
                    var output:NSString = NSString(bytes: buffer, length: result, encoding: NSUTF8StringEncoding)!
                    
                    println("message: \(output)")
                    
                    if (!output.isEqualToString("Echo server")) {
                        
                        parseBundlesFromBuffer(output)
                        println("bundle cache: \(bundleCache)")
                        
                        for (index, bundle) in enumerate(bundleCache) {
                            parseEventsFromBundle(bundle as NSString)
                        }
                        
                    }
                    
                    // prepare for next bundle(s)
                    bundleCache.removeAllObjects()
                }
            }
            break;
        default:
            print("Unknown event")
        }
        
    }
    
    func parseBundlesFromBuffer(rawString:NSString) {
        
        // if incomplete bundle, add rawString to it
        //var feed:NSString = (streamCache != nil) ? streamCache! + rawString : rawString
        streamFeed = (streamCache != nil) ? streamCache! + rawString : rawString
        
        println("feed from buffer:")
        println("\(streamFeed)")
        
        var continueParsingBundles = true
        
        while(continueParsingBundles) {
            continueParsingBundles = parseStreamIntoBundle()
        }
    }
    
    func parseStreamIntoBundle() -> Bool {
        
        // find start of packet
        // find end of packet
        var terminator:NSRange = streamFeed!.rangeOfString("]}")
        
        if (terminator.location == NSNotFound) {
            // repeat until
            // can't find end of packet (incomplete bundle)
            streamCache = NSString(string: streamFeed!)
            println("!!!!! incomplete feed !!!!!:")
            println("\(streamCache)")
            
            return false
        }
        
        // create substring
        var bundle:NSString = streamFeed!.substringWithRange(NSMakeRange(0,terminator.location+2))
        println("bundle parsed: \(bundle)")
        
        streamFeed = streamFeed!.substringFromIndex(terminator.location+2)
        println("feed after bundle removed: \(streamFeed)")
        
        // add to cache
        bundleCache.addObject(bundle)
        
        // repeat until
        // end of next packet is end of raw string
        if (streamFeed?.length == 0) {
            streamCache = nil
            println("packet ended with complete bundle")
            return false
        }
        
        return true;
    }
    
    func parseEventsFromBundle(bundle:NSString) {
        //var data:NSData = output.dataUsingEncoding(NSASCIIStringEncoding)!
        var data:NSData = bundle.dataUsingEncoding(NSUTF8StringEncoding)!
        //data = data.subdataWithRange(NSMakeRange(0, data.length-1))
        
        parseMessage(data)
    }
    
    func parseMessage(data:NSData) {
        let json = JSON(data: data)
        println("parseMessage \(json)")
        if let fseq = json["fseq"].integerValue {
            println("SwiftyJSON: \(fseq)")
        }
    }
}