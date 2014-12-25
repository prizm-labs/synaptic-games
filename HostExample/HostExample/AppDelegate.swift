//
//  AppDelegate.swift
//  HostExample
//
//  Created by Michael Garrido on 12/9/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //http://stackoverflow.com/questions/24819240/swift-using-objective-c-class
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var synApplication:SYNApplication = application as SYNApplication
            synApplication.initSynSocket()
        
        }
//        var host:String = "10.0.1.23";
//        var port:UInt16 = 1337;

//        var host:String = "www.google.com";
//        var port:UInt16 = 80;
//
//        var tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
//        var error:NSError? = nil;
//        
//
////        if (tcpSocket.connectToAddress(<#remoteAddr: NSData!#>, withTimeout: <#NSTimeInterval#>, error: <#NSErrorPointer#>))
//        
//        if (tcpSocket.connectToHost(host, onPort: port, error: &error))
//        {
//            print("Error connecting to host:\(error)");
//        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    //#pragma mark Socket Delegate
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("didConnectToHost \(host) \(port)");
    }
    
//    - (void)socketDidSecure:(GCDAsyncSocket *)sock
//    {
//    DDLogInfo(@"socketDidSecure:%p", sock);
//    self.viewController.label.text = @"Connected + Secure";
//    
//    NSString *requestStr = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nHost: %@\r\n\r\n", HOST];
//    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [sock writeData:requestData withTimeout:-1 tag:0];
//    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
//    }
//    
//    - (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
//    {
//    DDLogInfo(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
//    }
    
//    - (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//    {
//    DDLogInfo(@"socket:%p didReadData:withTag:%ld", sock, tag);
//    
//    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    DDLogInfo(@"HTTP Response:\n%@", httpResponse);
//    
//    }
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        var response:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!;
        print("didReadData \(response)");
    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        print("didDisconnect \(sock)");
    }
    
//    - (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
//    {
//    DDLogInfo(@"socketDidDisconnect:%p withError: %@", sock, err);
//    self.viewController.label.text = @"Disconnected";
//    }

}

