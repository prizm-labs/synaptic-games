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
    var socket:SYNSocket!
    var responder:SYNResponder!
    
    var meteor:MeteorResponder!
    
    var inputStream:NSInputStream!
    var outputStream:NSOutputStream!
    var bundleCache:NSMutableArray = NSMutableArray()
    
    var streamCache:NSString? = nil
    var streamFeed:NSString? = nil
    
    var secondWindow:UIWindow!
    
    var meteorClient:MeteorClient!

//    override func sendEvent(event: UIEvent)
//    {
//        println("send event \(event)") // this is an example
//        // ... dispatch the message...
//        
//        super.sendEvent(event)
//    }
    func handleScreenDidConnectNotification(notification:NSNotification) {
        let screens:NSArray = UIScreen.screens()
        
        if (screens.count > 1)
        {
            // Get the screen object that represents the external display.
            let secondScreen:UIScreen = screens.objectAtIndex(1) as UIScreen
            // Get the screen's bounds so that you can create a window of the correct size.
            let screenBounds:CGRect = secondScreen.bounds
            
            println("second screen bounds: \(screenBounds)")
            
            self.secondWindow = UIWindow(frame: screenBounds)
            self.secondWindow.screen = secondScreen
            
            // Set up initial content to display...
            // Show the window.
            self.secondWindow.hidden = false
        }
    }
    
    func handleScreenDidDisconnectNotification(notification:NSNotification) {
        
    }
    
    func initMeteor() {
        
        meteor = MeteorResponder()
        
        // Override point for customization after application launch. creates our singleton
        meteorClient = initialiseMeteor("pre2", "wss://ddptester.meteor.com/websocket");
        
        meteorClient.addSubscription("things")
        meteorClient.addSubscription("lists")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection", name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection", name: MeteorClientDidDisconnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveUpdate:", name: "added", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveUpdate:", name: "removed", object: nil)
        
    }
    
    func reportConnection() {
        println("================> connected to server!")
        
        meteor.delegate?.didConnect()
    }
    
    func reportDisconnection() {
        println("================> disconnected from server!")
        
        meteor.delegate?.didDisconnect()
    }
    
    func didReceiveUpdate(notification:NSNotification) {
        println("didReceiveUpdate: \(notification)")
        //self.tableview.reloadData()
        
        meteor.delegate?.didReceiveUpdate()
    }

    
    func initSecondScreen() {
        
        let center:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector:"handleScreenDidConnectNotification", name: UIScreenDidConnectNotification, object: nil)
        center.addObserver(self, selector:"handleScreenDidConnectNotification", name: UIScreenDidConnectNotification, object: nil)
        
//        - (void)setUpScreenConnectionNotificationHandlers
//            {
//                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//                
//                [center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
//                name:UIScreenDidConnectNotification object:nil];
//                [center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
//                name:UIScreenDidDisconnectNotification object:nil];
//        }
 
    }
    
    func initSynSocket(){
        
        responder = SYNResponder()
        
        socket = SYNSocket(host: "10.0.1.23", OnPort: 1337)
        //synSocket.connect()
        
        socket.inputStream.delegate = self
        socket.outputStream.delegate = self
        
        socket.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        socket.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        socket.inputStream.open()
        socket.outputStream.open()
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch(eventCode) {
            
        case NSStreamEvent.ErrorOccurred:
            print("ErrorOccurred")
            
            println("error: \(aStream.streamError)")
            
            break;
        case NSStreamEvent.OpenCompleted:
            print("Stream opened");
            break;
        case NSStreamEvent.HasBytesAvailable:
            
            if (aStream == socket.inputStream) {
                
                var buffer = [UInt8](count: 1024, repeatedValue: 0)
                while socket.inputStream.hasBytesAvailable {
                    let result: Int = socket.inputStream.read(&buffer, maxLength: buffer.count)
                    
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
            println("eventCode: \(eventCode.rawValue)")
            println("stream: \(aStream)")
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
        var dataToJson = JSON(data: data)
        parseMessage(dataToJson)
    }
    
    func parseMessage(json:JSON) {
        println("parseMessage \(json)")
        
        // if touch events
        responder.updatesTouchesFromData(json)
        
        if let fseq = json["fseq"].integerValue {
            println("SwiftyJSON: \(fseq)")
        }
    }
    
    func dispatchEvent() {
        
        // get UIWindow
        
        // translate touch point to window coordinate system
        // may not be 1920 x 1080...
        
        // get topmost
        
    }

    
}