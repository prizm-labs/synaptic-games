//
//  SYNApplication.swift
//  HostExample
//
//  Created by Michael Garrido on 12/19/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit
import Foundation

class SYNApplication: UIApplication, NSStreamDelegate
{
    var synSocket:SYNSocket!
    
    var inputStream:NSInputStream!
    var outputStream:NSOutputStream!
    var bundleCache:NSMutableArray = NSMutableArray()
    
    var streamCache:NSString? = nil
    var streamFeed:NSString? = nil
    
//    override func sendEvent(event: UIEvent)
//    {
//        println("send event \(event)") // this is an example
//        // ... dispatch the message...
//        
//        super.sendEvent(event)
//    }
    
    func initSynSocket(){
        
        synSocket = SYNSocket(host: "10.0.1.23", OnPort: 1337)
        //synSocket.connect()
        
        synSocket.inputStream.delegate = self
        synSocket.outputStream.delegate = self
        
        synSocket.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        synSocket.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        synSocket.inputStream.open()
        synSocket.outputStream.open()
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch(eventCode) {
        case NSStreamEvent.OpenCompleted:
            print("Stream opened");
            break;
        case NSStreamEvent.HasBytesAvailable:
            
            if (aStream == synSocket.inputStream) {
                
                var buffer = [UInt8](count: 1024, repeatedValue: 0)
                while synSocket.inputStream.hasBytesAvailable {
                    let result: Int = synSocket.inputStream.read(&buffer, maxLength: buffer.count)
                    
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