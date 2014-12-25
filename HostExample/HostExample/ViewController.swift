//
//  ViewController.swift
//  HostExample
//
//  Created by Michael Garrido on 12/9/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, SYNGestureRecognizerDelegate, GCDAsyncUdpSocketDelegate, NSStreamDelegate {
    
    func initGameWorld() {
        let scene = GameScene(size: self.view.bounds.size)
        let skView = SKView(frame: self.view.bounds)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        
        self.view = skView;
        
        skView.presentScene(scene)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
//        let scene = GameScene(size: self.view.bounds.size)
//        let skView = self.view as SKView
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        skView.ignoresSiblingOrder = true
//        scene.scaleMode = .ResizeFill
//        skView.presentScene(scene)
        
        let app = UIApplication.sharedApplication() as SYNApplication
        app.responder.delegate = self
        
        //udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        //initNetworkCommunication();
        // Find the Linux host on the network
        //udpSocket.connectToHost("10.0.1.23", onPort: 3333, error: nil)
        
        initGameWorld();
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func touchesBegan(touches: NSSet, withEvent event: SYNEvent) {
//        println("touchesBegan")
//    }
    func syntouchesBegan(touches: NSSet, withEvent event: SYNEvent) {
        //println("touchesBegan: \(touches)")
        
        var touch:SYNTouch? = touches.anyObject() as? SYNTouch
        //println("window location: \(touch?.locationInView(nil))")
        //println("view location: \(touch?.locationInView(self.view))")
        var p = touch?.locationInView(nil)
        
        //println("touch in overlay \(p?.x) , \(p?.y)")
    }
    
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

