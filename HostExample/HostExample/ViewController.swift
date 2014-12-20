//
//  ViewController.swift
//  HostExample
//
//  Created by Michael Garrido on 12/9/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GCDAsyncUdpSocketDelegate, NSStreamDelegate {

//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    var udpSocket: GCDAsyncUdpSocket!
    
    var inputStream:NSInputStream!
    var outputStream:NSOutputStream!
    var bundleCache:NSMutableArray = NSMutableArray()
    
    var streamCache:NSString? = nil
    var streamFeed:NSString? = nil
    
    var synSocket:SYNSocket!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        //println("current run loop: \(NSRunLoop.currentRunLoop())")
        
//        synSocket = SYNSocket(host: "10.0.1.23", OnPort: 1337)
//        //synSocket.connect()
//        
//        synSocket.inputStream.delegate = self
//        synSocket.outputStream.delegate = self
//        
//        synSocket.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
//        synSocket.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
//        synSocket.inputStream.open()
//        synSocket.outputStream.open()
        
        //println("current run loop: \(NSRunLoop.currentRunLoop())")
        //initNetworkCommunication();
        // Find the Linux host on the network
        //udpSocket.connectToHost("10.0.1.23", onPort: 3333, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initNetworkCommunication() {
    
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, "10.0.1.23", 1337, &readStream, &writeStream)
        
        // Documentation suggests readStream and writeStream can be assumed to
        // be non-nil. If you believe otherwise, you can test if either is nil
        // and implement whatever error-handling you wish.
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        inputStream.open()
        outputStream.open()
    
    }
    
    //- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
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
//    
//    NSLog(@"stream event %i", streamEvent);
//    
//    switch (streamEvent) {
//    
//    case NSStreamEventOpenCompleted:
//    NSLog(@"Stream opened");
//    break;
//    case NSStreamEventHasBytesAvailable:
//    
//    if (theStream == inputStream) {
//				
//				uint8_t buffer[1024];
//				int len;
//				
//				while ([inputStream hasBytesAvailable]) {
//    len = [inputStream read:buffer maxLength:sizeof(buffer)];
//    if (len > 0) {
//    
//    NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
//    
//    if (nil != output) {
//    
//    NSLog(@"server said: %@", output);
//    [self messageReceived:output];
//    
//    }
//    }
//				}
//    }
//    break;
//    
//    
//    case NSStreamEventErrorOccurred:
//    
//    NSLog(@"Can not connect to the host!");
//    break;
//    
//    case NSStreamEventEndEncountered:
//    
//    [theStream close];
//    [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    [theStream release];
//    theStream = nil;
//    
//    break;
//    default:
//    NSLog(@"Unknown event");
//    }
//    
//    }
    
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        println("udp didConnectToAddress: \(address)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        println("udp didReceiveData")
        
        var msg:NSString? = NSString(data: data, encoding: NSUTF8StringEncoding);
        
        if ((msg) != nil) {
            println("udp datagram:\(msg)")
        } else {
            println("udp datagram error")
        }
    }
//    - (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
//    {
//    // You could add checks here
//    }
//    
//    - (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
//    {
//    // You could add checks here
//    }
//    
//    - (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
//    fromAddress:(NSData *)address
//    withFilterContext:(id)filterContext
//    {
//    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    if (msg)
//    {
//    [self logMessage:FORMAT(@"RECV: %@", msg)];
//    }
//    else
//    {
//    NSString *host = nil;
//    uint16_t port = 0;
//    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
//    
//    [self logInfo:FORMAT(@"RECV: Unknown message from: %@:%hu", host, port)];
//    }
//    }

}

