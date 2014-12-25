//
//  GameViewController.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/13/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

import CoreMotion

import Foundation

import MultipeerConnectivity

class GameViewController: UIViewController,
    UIGestureRecognizerDelegate,
    SCNSceneRendererDelegate, SCNPhysicsContactDelegate,
    MCBrowserViewControllerDelegate, MCSessionDelegate  {
    
    
    
    let ORB_RADIUS = CGFloat(15)
    let CARD_WIDTH = CGFloat(500)
    let CARD_HEIGHT = CGFloat(726)
    let CARD_RADIUS = CGFloat(20)
    let CARD_DEPTH = CGFloat(2.5)
    
    let CARD_RESIZE_FACTOR = CGFloat(0.1)
    
    let TABLE_RADIUS = CGFloat(600.0)
    let TABLE_DEPTH = CGFloat(50.0)
    
    var handPosition:SCNVector3!
    var handCards:NSMutableArray = NSMutableArray()
    var deckCards:NSMutableArray = NSMutableArray()
    
    var cardAtlas:[String: String]!
    var cardManifest:[[String]] = [[String]]()
    
    var _hitTest:HitTest!
    
    var _scene:SCNScene!
    
    var uiOverlay:SKScene!
    
    var _cameraNode:SCNNode!
    var _cameraHandle:SCNNode!
    var _cameraOrientation:SCNNode!
    
    var camera:Camera!
    var perspectives:NSMutableArray = NSMutableArray()
    
    // Gestures
    var gestureLibrary:[String:UIGestureRecognizer]!
    
    var _cameraHandleTransforms = [SCNMatrix4](count:10, repeatedValue:SCNMatrix4(m11: 0.0, m12: 0.0, m13: 0.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 0.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 0.0))
    
    
    var _ambientLightNode:SCNNode!
    
    var _spotlightParentNode:SCNNode!
    var _spotlightNode:SCNNode!
    
    var _floorNode:SCNNode!
    
    var _playerOrb:SCNNode!
    
    var cardNodes:[CardNode] = [CardNode]()
    
    var cardGroups:NSMutableArray = NSMutableArray()
    
    var players:NSMutableArray = NSMutableArray()
    
    
    var activeObject:SCNNode?
    var activeObjectOrigin:SCNVector3?
    var activeCard:CardNode?
    
    var activePlayPoint:PlayPoint?
    
    // Accelerometer
    var motionManager:CMMotionManager!
    
    
    
    let serviceType = "LCOC-Chat"
    
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    
    @IBOutlet var chatView: UITextView!
    @IBOutlet var messageField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCBrowserViewController(serviceType:serviceType,
            session:self.session)
        
        self.browser.delegate = self;
        
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType,
            discoveryInfo:nil, session:self.session)
        
        // tell the assistant to start advertising our fabulous chat
        self.assistant.start()

        
        setup()
    }
    
    
    func showBrowser() {
        // Show the browser view controller
        self.presentViewController(self.browser, animated: true, completion: nil)
    }

    
    // MC DELEGATE FUNCTIONS
    
    func browserViewControllerDidFinish(
        browserViewController: MCBrowserViewController!)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(
        browserViewController: MCBrowserViewController!)  {
            // Called when the browser view controller is cancelled
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!,
        fromPeer peerID: MCPeerID!)  {
            // Called when a peer sends an NSData to us
            
            var msg = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("didReceiveData \(msg)");
            
            
            
            // This needs to run on the main queue
            dispatch_async(dispatch_get_main_queue()) {
                
                var msg = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                
                //self.updateChat(msg!, fromPeer: peerID)
            }
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(session: MCSession!,
        didStartReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(session: MCSession!,
        didFinishReceivingResourceWithName resourceName: String!,
        fromPeer peerID: MCPeerID!,
        atURL localURL: NSURL!, withError error: NSError!)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!,
        withName streamName: String!, fromPeer peerID: MCPeerID!)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!,
        didChangeState state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
            
    }

    
    
    // ACCELEROMETER FUNCTIONS
    
    func parseAcceleration(data:CMAccelerometerData){
        
        let acceleration = data.acceleration
        
        //println("parseAcceleration x:\(acceleration.x), y:\(acceleration.y), z:\(acceleration.z)")

        var activePerspective:CameraPerspective?
        
        // landscape
        // x = 1    vertical   perpendicular to tabletop
        // x = 0    horizontal parallel to tabletop
        
        let x = acceleration.x
        //let threshold = 0.8
        let threshold = 0.6
        let buffer = 0.2
        
        var targetOrientationMode:Camera.OrientationMode
        
        if x < threshold && x > -threshold {
            //println("switch to horizontal")
            activePerspective = perspectives[1] as? CameraPerspective
            //camera.orientationMode = Camera.OrientationMode.TableOverhead
            targetOrientationMode = Camera.OrientationMode.TableOverhead
            
        } else {
            //println("switch to vertical")
            activePerspective = perspectives[0] as? CameraPerspective
            //camera.orientationMode = Camera.OrientationMode.PlayerHand
            targetOrientationMode = Camera.OrientationMode.PlayerHand

        }
        
        
        // portrait 
        // y = -1   vertical   perpendicular to tabletop
        // y = 0    horizontal parallel to tabletop
        
        if -acceleration.y>0.8 && -acceleration.y<1.2 {
            //println("switch to horizontal")
        } else {
            //println("switch to vertical")
        }
        
        
        
        //if activePerspective? !== nil {
        
        if camera.orientationMode != targetOrientationMode && camera.willChangePerspective {
            
//            var cameraPanGesture = gestureLibrary["OnPanTranslateCamera"] as UIGestureRecognizer?
//            cameraPanGesture?.enabled = false
//            cameraPanGesture?.enabled = true
//            
//            println("trigger camera perspective switch")
            
            //camera.orientationMode = targetOrientationMode
            //activePerspective?.transformCamera(self.camera)
            
            let position = activePerspective?.position
            let orientation = activePerspective?.orientation
            
            camera.transform(position!, orientation: orientation!, mode:targetOrientationMode, duration: 0.3)
            //camera.transform(position!, orientation: orientation!, mode:targetOrientationMode, duration: 0)
            
            // TODO update gestures???
            //updateGestures()
        }
        
        
    }
    
    func setupAccelerometer() {
        println("setupAccelerometer")
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: { (accelerometerData, error) -> Void in
            self.parseAcceleration(accelerometerData)
        })
        
//        if (motionManager.accelerometerAvailable) {
//            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue()) {
//                (data, error) in
//                
//                println("accelerometer \(data.acceleration)")
//                let currentX = monkey.position.x
//                let currentY = monkey.position.y
//                if(data.acceleration.y < -0.25) { // tilting the device to the right
//                    var destX = (CGFloat(data.acceleration.y) * CGFloat(kPlayerSpeed) + CGFloat(currentX))
//                    var destY = CGFloat(currentY)
//                    motionManager.accelerometerActive == true;
//                    let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 1)
//                    monkey.runAction(action)
//                } else if (data.acceleration.y > 0.25) { // tilting the device to the left
//                    var destX = (CGFloat(data.acceleration.y) * CGFloat(kPlayerSpeed) + CGFloat(currentX))
//                    var destY = CGFloat(currentY)
//                    motionManager.accelerometerActive == true;
//                    let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 1)
//                    monkey.runAction(action)
//                }
//            }
//            
//        }
        
    }
    
    func setupGestures() {
        
        
        let sceneView = self.view as SCNView
        
        
        
        // HitTest manager
        _hitTest = HitTest(sceneView:sceneView)
        
        
        // TODO double tap to flip card over
        //let doubleTapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        
        
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        //let tapGesture = UITapGestureRecognizer(target: self, action: "moveCamera")
        
        let tap1F3TGesture = UITapGestureRecognizer(target: self, action: "handleTap1F3T:")
        tap1F3TGesture.numberOfTapsRequired = 2
        tap1F3TGesture.numberOfTouchesRequired = 1
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
        
        let pan1FGesture = UIPanGestureRecognizer(target: self, action: "handlePan1F:")
        pan1FGesture.minimumNumberOfTouches = 1
        pan1FGesture.maximumNumberOfTouches = 1
        
        let pan3FGesture = UIPanGestureRecognizer(target: self, action: "handlePan3F:")
        pan3FGesture.minimumNumberOfTouches = 2
        pan3FGesture.maximumNumberOfTouches = 2
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        
        
        // pinch gesture
        // zoom camera in and out
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        //pinchGesture.requireGestureRecognizerToFail(pan3FGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: "handleRotation:")
        
        gestureLibrary = [
            "OnTapHighlightObject": tapGesture,
            "OnPanTranslateCamera":pan3FGesture,
            "OnPinchZoomCamera":pinchGesture
        ]
        
        let gestureRecognizers = NSMutableArray()
        //gestureRecognizers.addObject(tapGesture)
        //gestureRecognizers.addObject(panGesture)
        gestureRecognizers.addObject(pan1FGesture)
        gestureRecognizers.addObject(pan3FGesture)
        //gestureRecognizers.addObject(rotationGesture)
        //gestureRecognizers.addObject(pinchGesture)
        
        gestureRecognizers.addObject(tap1F3TGesture)
        gestureRecognizers.addObject(longPressGesture)
//        gestureRecognizers.addObject(swipeGesture)
        
        if let existingGestureRecognizers = sceneView.gestureRecognizers {
            gestureRecognizers.addObjectsFromArray(existingGestureRecognizers)
        }
        sceneView.gestureRecognizers = gestureRecognizers
        
    }
    
    func updateGestures(){
        
        switch camera.orientationMode {
            
        case .PlayerHand:
            println("PlayerHand")
            // 1F pan on object to translate in vertical plane
            
//            let gestureRecognizers = NSMutableArray()
//            gestureRecognizers.addObject(tapGesture)
//            gestureRecognizers.addObject(panGesture)
            
        case .TableOverhead:
            println("TableOverhead")
            // 1F pan on object to translate in horizontal plane
            
        case .TablePanorama:
            println("TablePanorama")
            //
            
        case .Opponent:
            println("Opponent")
            
        }
        
        
        // TODO determine object specific bindings???
        
    }
    
    func setup() {
        
        // retrieve the SCNView
        let sceneView = view as SCNView
        
        sceneView.backgroundColor = SKColor.whiteColor()
    
        uiOverlay = UIOverlayScene(size: view.bounds.size)
        
        sceneView.overlaySKScene = uiOverlay
        
        // cache for binding objects to gestures
        activeObject = nil
        activeCard = nil
        
        // Get cards manifest

        var error: NSError?

        let filePath = NSBundle.mainBundle().pathForResource("card-manifest", ofType: "json")
        
        println("sprite manifest path \(filePath)")
        
        let jsonData = NSData(contentsOfFile:filePath!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)
        
        println("sprite manifest \(jsonData)")
        
        let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as NSDictionary
        
        println("sprite manifest \(jsonDict)")
        
        if ((jsonDict["images"]) != nil) {
            
            cardAtlas = jsonDict["images"] as Dictionary
//            for (key, image) in cardAtlas {
//                println("\(key) : \(image)")
//            }
        }

        if ((jsonDict["cards"]) != nil) {
            cardManifest = jsonDict["cards"] as Array
        }
        
        
        setupScene()
        
        _scene.physicsWorld.speed = 2.0;
        _scene.physicsWorld.gravity = SCNVector3Make(0, -70, 0)
        
        sceneView.scene = _scene;
        
        sceneView.delegate = self
        //sceneView.jitteringEnabled = true
        
        sceneView.pointOfView = _cameraNode
        //sceneView.allowsCameraControl = true
        
        sceneView.showsStatistics = true
        

        setupGestures()

        
//        var overlay = SpriteKitOverlayScene
//        sceneView.overlaySKScene = overlay
        //        // retrieve the SCNView
        //        let scnView = self.view as SCNView
        //
        //        // set the scene to the view
        //        scnView.scene = scene
        //
        //        // allows the user to manipulate the camera
        //        scnView.allowsCameraControl = true
        //
        //        // show statistics such as fps and timing information
        //        scnView.showsStatistics = true
        //
        //        // configure the view
        //        scnView.backgroundColor = UIColor.blackColor()
        //
    }
    
    func setupScene() {
        
        _scene = SCNScene()
        
        setupPlayerCamera()
        // Accelerometer bound to... camera?
        setupAccelerometer()
        setupEnvironment()
        setupSceneElements()
        setupInitialLighting()
        
        
        //        // create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.dae")
        //

        //
        //        // retrieve the ship node
        //        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        //        
        //        // animate the 3d object
        //        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        //
    }
    
    func setupPlayerCamera() {
        
        camera = Camera()
        
        _scene.rootNode.addChildNode(camera.positionHandle)
        _cameraNode = camera.cameraNode
        
        // position default behind player
        var playerDefaultPerspective = CameraPerspective(orientation: SCNVector3Make(-CFloat(M_PI * 0.15), 0, 0), position: SCNVector3Make(0,150,Float(TABLE_RADIUS*0.75)))
        
        // position over table
        var tableDefaultPerspective = CameraPerspective(orientation: SCNVector3Make(-CFloat(M_PI_2),0,0), position: SCNVector3Make(0, 400, 0))
        
        self.perspectives.addObject(playerDefaultPerspective)
        self.perspectives.addObject(tableDefaultPerspective)
        
        //camera.transform(SCNVector3Make(0,150,Float(TABLE_RADIUS*0.75)), orientation: SCNVector3Make(-CFloat(M_PI * 0.15), 0, 0))
    }
    
    func setupEnvironment() {

        
        // Floor
        var floor = SCNFloor()
        floor.reflectionFalloffEnd = 0
        floor.reflectivity = 0
        
        var tableMaterial = SCNMaterial()
        //tableMaterial.diffuse.contents =  "green-felt.jpg"
        tableMaterial.diffuse.contents = UIImage(named:"green-felt.jpg")
        tableMaterial.locksAmbientWithDiffuse = true
        tableMaterial.diffuse.wrapS = SCNWrapMode.Repeat
        tableMaterial.diffuse.wrapT = SCNWrapMode.Repeat
        tableMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        floor.firstMaterial = tableMaterial
        
        _floorNode = SCNNode()
        _floorNode.geometry = floor
        _floorNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: nil)
        _floorNode.physicsBody?.restitution = 1.0
        
        _floorNode.position.y -= 200.0
        
        _scene.rootNode.addChildNode(_floorNode)
        
        var table = Table(radius: 600.0, depth: 50.0)
        
        _scene.rootNode.addChildNode(table.rootNode)
        
        
        // Create hidden wall planes for each player's hand 
        
    }
    
    func setupSceneElements() {
        
        //        _playerOrb = SCNNode(geometry: SCNSphere(radius: ORB_RADIUS))
        //        //_playerOrb.geometry.firstMaterial.diffuse.contents = SKColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        //        _playerOrb.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        //        _playerOrb.physicsBody?.restitution = 0.9
        //
        //        _playerOrb.position = SCNVector3Make(0, 0, 0)
        //        _playerOrb.position.y += CFloat(ORB_RADIUS * 8)
        //
        //        _scene.rootNode.addChildNode(_playerOrb)
        
        
        //        var cardNode = createCard("ace_of_spades.png", cardBackImage:"back-default.png")
        //        cardNode.position = SCNVector3Make(0, 0, 0)
        //        cardNode.position.y += 50
        //        _scene.rootNode.addChildNode(cardNode)
        
        //cardNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: CGFloat(M_PI), z: 0, duration: 4)))
        
        
        // Deck of cards
        var size = CardSize(height: CARD_HEIGHT, width: CARD_WIDTH, cornerRadius: CARD_RADIUS, thickness: CARD_DEPTH)
        size.scale(CARD_RESIZE_FACTOR)
        
        var deck = Deck(atlas:cardAtlas,manifest:cardManifest,size:size,origin:SCNVector3Make(0, 0, 0))
        // Deck default group as stack
        var deckStackGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Stack, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:SCNVector3Make(0, 0, 0))
        
        deck.setGroup(deckStackGroup)
        deck.spawn(_scene.rootNode)
        
        cardGroups.addObject(deckStackGroup)
        
        
        // table default group
        var tableOpenGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Open, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:SCNVector3Make(0, 0, CFloat(TABLE_RADIUS/2)) )
        
        // general table surface
        var tableSurfaceGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Open, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:SCNVector3Make(0, 0, 0))
        
        // hover group
        var tableHoverGroup = CardGroup(organizationMode: CardGroup.OrganizationMode.Open, orientation: SCNVector3Make(CFloat(M_PI/2), 0, 0), origin:SCNVector3Make(0, 150.0, 0))
        
        
        cardGroups.addObject(tableOpenGroup)
        
        
        // Players
        var player = addPlayer("player1")
    
        updatePlayers()
        //player.render(SCNVector3Make(0, 50, Float(TABLE_RADIUS*0.5)), rootNode:_scene.rootNode)
        
        
        // Play point
        var playPoint = PlayPoint(position: SCNVector3Make(0, 0, 200), group: tableOpenGroup, isFlipped:true)
        
        activePlayPoint = playPoint
        
        _scene.rootNode.addChildNode(playPoint.rootNode)
        
        
        // Draw card
        player.drawCardFromGroup(deck.cards[0] as CardNode, group: deck.group)
        
        
        
    }
    
    func setupInitialLighting() {
        
        _ambientLightNode = SCNNode()
        
        var ambientLight = SCNLight()
        ambientLight.type = SCNLightTypeAmbient
        ambientLight.color = SKColor(white: 0.8, alpha: 0.8)
        _ambientLightNode.light = ambientLight
        
        _scene.rootNode.addChildNode(_ambientLightNode)
        
        _spotlightParentNode = SCNNode()
        _spotlightParentNode.position = SCNVector3Make(0, 90, 20)
        
        _spotlightNode = SCNNode()
        _spotlightNode.rotation = SCNVector4Make(1, 0, 0, CFloat(-M_PI_4))
        
        var spotlight = SCNLight()
        spotlight.type = SCNLightTypeSpot
        spotlight.color = SKColor(white: 1.0, alpha: 1.0)
        spotlight.castsShadow = true
        spotlight.shadowColor = SKColor(white: 0, alpha: 0.5)
        spotlight.zNear = 30
        spotlight.zFar = 800
        spotlight.shadowRadius = 1.0
        spotlight.spotInnerAngle = 15
        spotlight.spotOuterAngle = 70
        
        _spotlightNode.light = spotlight
        _cameraNode.addChildNode(_spotlightParentNode)
        _spotlightParentNode.addChildNode(_spotlightNode)
        
        
    }
    
    func createCard (cardFrontImage:String, cardBackImage:String) -> SCNNode {
        
        var cardPath:UIBezierPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: CARD_WIDTH*CARD_RESIZE_FACTOR, height: CARD_HEIGHT*CARD_RESIZE_FACTOR), cornerRadius: CARD_RADIUS*CARD_RESIZE_FACTOR)
        
        var cardVolume = SCNShape(path: cardPath, extrusionDepth: CARD_DEPTH*CARD_RESIZE_FACTOR)
        var cardFrontPlane = SCNShape(path: cardPath, extrusionDepth: 0)
        var cardBackPlane = SCNShape(path: cardPath, extrusionDepth: 0)
        
        var cardContainer = SCNNode()
        
        var cardBack = SCNNode(geometry: cardBackPlane)
        cardBack.name = "back"
        cardBack.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR)*0.5, 0, 0)
        //cardBack.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR), CFloat(CARD_HEIGHT*CARD_RESIZE_FACTOR), 0)
        
        var backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = cardBackImage
        backMaterial.locksAmbientWithDiffuse = true
        backMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        var cardFront = SCNNode(geometry: cardFrontPlane)
        cardFront.name = "front"
        cardFront.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR)*0.5, 0, 0)
        
        var frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents =  cardFrontImage
        frontMaterial.locksAmbientWithDiffuse = true
        frontMaterial.diffuse.mipFilter = SCNFilterMode.Linear
        
        var cardPlaneOffset = CFloat(CARD_DEPTH*CARD_RESIZE_FACTOR) / 2.0 + 0.01
        
        cardFront.geometry?.firstMaterial = frontMaterial
        cardFront.position = SCNVector3Make(0, 0, cardPlaneOffset)
        
        cardBack.geometry?.firstMaterial = backMaterial
        cardBack.position = SCNVector3Make(0, 0, -cardPlaneOffset)
        cardBack.eulerAngles = SCNVector3Make(0, CFloat(M_PI), 0)
        cardBack.rotation = SCNVector4Make(0, 1.0, 0, CFloat(M_PI))
        
        
        var cardBody = SCNNode(geometry: cardVolume);
        cardBody.name = "body"
        cardBody.pivot = SCNMatrix4MakeTranslation(CFloat(CARD_WIDTH*CARD_RESIZE_FACTOR)*0.5, 0, 0)
        //        cardNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: nil)
        //        cardNode.physicsBody?.restitution = 0.01
        //        cardNode.physicsBody?.mass = 5
        //        cardNode.physicsBody?.angularVelocity = SCNVector4Make(5, 1, 1, 1)
        
        cardContainer.addChildNode(cardBody)
        cardContainer.addChildNode(cardFront)
        cardContainer.addChildNode(cardBack)
        
        //cardFront.hidden = true;
        
        return cardContainer
    }
    
    func bindObjectToPan(object:SCNNode, recognizer:UIGestureRecognizer) {
        
        
        
    }
    
    //PRAGMA MARK GestureRecognizers
    
    func handleLongPress(recognizer:UILongPressGestureRecognizer) {
        println("handleLongPress")
        
        // long press on card, change to activation mode
        // long press on single card , flip

        // in open table group or
        
        // long press on deck
        
        // single tap on original activated card, deactivate card
        
        let scnView = self.view as SCNView
        
        // check what nodes are tapped
        let p = recognizer.locationInView(scnView)
        let object:SCNNode? = getObjectFromHitTest(p)
        
        if object !== nil {
            
            let cardNode = findActiveObject(object!) as CardNode?
            
            if cardNode != nil {
                cardNode?.flip(1.0)
            }
        }
        
    }
    
    func handleSwipe(recognizer:UISwipeGestureRecognizer) {
        println("handleSwipe")
    }
    
    func handleRotation(recognizer:UIRotationGestureRecognizer) {
        
        
        println("handleRotation: \(recognizer.rotation) , \(recognizer.velocity)")
        
        let rotation:CFloat = CFloat(recognizer.rotation)
        
        camera.zoom(rotation)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            println("rotation Gesture ended")
            camera.resetZoom()
        }
    }
    
    func handlePinch(recognizer:UIPinchGestureRecognizer) {
        
        println("handlePinch, scale:\(recognizer.scale)")
        
        let scale:CFloat = CFloat(recognizer.scale)
        
        camera.zoom(scale)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            println("pinch Gesture ended")
            camera.resetZoom()
        }
    }
    
    func handleTap1F3T(recognizer: UIGestureRecognizer) {
        
        println("handleTap 1F 3T")
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        
        // check what nodes are tapped
        let p = recognizer.locationInView(scnView)
        //        if let hitResults = scnView.hitTest(p, options: nil) {
        //            highlightObject(hitResults)
        //        }
        
        println("point \(p)")
        
        //https://developer.apple.com/library/mac/documentation/SceneKit/Reference/SCNHitTestResult_Class/index.html#//apple_ref/occ/cl/SCNHitTestResult
        
        let result:SCNHitTestResult? = getResultFromHitTest(p, nodeName: "table")
        
        if result != nil {
            println("world coordinates: \(result?.worldCoordinates)")
            
            let position:SCNVector3? = result?.worldCoordinates
            
//            var playPoint = SCNNode(geometry: SCNSphere(radius: ORB_RADIUS))
//            playPoint.position = position!
//            _scene.rootNode.addChildNode(playPoint)
            
            activePlayPoint?.updatePosition(position!)
            //TODO create active edge linked to play point
        }
        
    }
    
    
    func handleTap(recognizer: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        
        // check what nodes are tapped
        let p = recognizer.locationInView(scnView)
        //        if let hitResults = scnView.hitTest(p, options: nil) {
        //            highlightObject(hitResults)
        //        }
        
       
        
        
        
        let object:SCNNode? = getObjectFromHitTest(p)
        
        if object !== nil {
            
            let cardNode = findActiveObject(object!) as CardNode?
            
            if cardNode != nil {
                cardNode?.flip(1.0)
            }
        }
        
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            println("tapGesture ended")
            
            //releaseActiveObject()
            
        }
        
    }
    
    func releaseActiveObject(){
        
        println("releaseActiveObject")
        
        activeObject = nil
        activeObjectOrigin = nil
        activeCard = nil
    }
    
    func findActiveObject(object:SCNNode) -> CardNode? {
        
        if object.name == "cardFront" || object.name == "cardBack" {
            
            let rootNode = object.parentNode as? RootNode
            return rootNode?.parentObject
            
        } else {
            return nil
        }
    }
    
    func setActiveObject(object:SCNNode) {
            
        // if card, bind to root node
        if object.name == "cardFront" || object.name == "cardBack" {
        //if object.name == "cardFront" || object.name == "cardBack" || object.name == "cardBody" {
            // cache object
            
            
            println("setActiveObject")
            
            var rootNode = object.parentNode as? RootNode
            activeCard = rootNode?.parentObject
            
            activeObject = activeCard?.positionHandle
            activeObjectOrigin = activeCard?.positionHandle?.position
            
            //                    activeObject = object?.parentNode
            //                    activeObjectOrigin = object?.parentNode?.position
            
            //activeObjectOrigin = SCNVector3Make(CFloat(object?.position.x), CFloat(object?.position.y), CFloat(object?.position.z))
            
        }

    }
    
    enum ActiveEdgeLocation {
        case None, Top, Right, Bottom, Left
    }
    
    struct HotspotResult {
        var location:CGPoint
        var activeEdgeLocation:ActiveEdgeLocation
        var hotspot:Hotspot? = nil
    }
    
    func checkPanObjectNearEdge(location:CGPoint)->HotspotResult {
        
        //TODO change buffer size based on...
        // device idiom iPad / iPhone
        // user preferences
        var buffer:CGFloat!
        let size:CGSize = self.view.frame.size
        
        //var isNearEdge = false
        var edgeLocation:ActiveEdgeLocation = ActiveEdgeLocation.None
        
        if UIDevice.currentDevice().userInterfaceIdiom ==  UIUserInterfaceIdiom.Pad {
            buffer = CGFloat(100)
        } else if UIDevice.currentDevice().userInterfaceIdiom ==  UIUserInterfaceIdiom.Phone {
            buffer = CGFloat(50)
        }
        
        if location.x < buffer {
            println("left edge")
            edgeLocation = ActiveEdgeLocation.Left
            //isNearEdge = true
        }
        if location.x > size.width-buffer {
            println("right edge")
            edgeLocation = ActiveEdgeLocation.Right
            //isNearEdge = true
        }
        
        if location.y < buffer {
            println("top edge")
            edgeLocation = ActiveEdgeLocation.Top
            //isNearEdge = true
        }
        if location.y > size.height-buffer {
            println("bottom edge")
            edgeLocation = ActiveEdgeLocation.Bottom
            //isNearEdge = true
        }
        
        return HotspotResult(location: location, activeEdgeLocation: edgeLocation, hotspot:nil)
        //return isNearEdge
    }
    
    func handlePan1F(recognizer:UIPanGestureRecognizer) {
        
        let translation:CGPoint = recognizer.translationInView(self.view)
        println("handlePan \(translation)")
        
        camera.willChangePerspective = false
        
        let sceneView = self.view as SCNView
        // check what nodes are tapped
        let p = recognizer.locationInView(sceneView)
        
        //TODO !!! translate object to raycast intersection with object's plane
        if camera.orientationMode == Camera.OrientationMode.PlayerHand {
            
        }
        
        // Check if touchDownInside card
        

        
        var object:SCNNode? = getObjectFromHitTest(p)
        
        if object !== nil && activeObject == nil {
            println("pan inside object")
            
            setActiveObject(object!)
        }
        
        if activeObject != nil {
            // manipulate object
            
            // check active edge
            let hotspotResult = checkPanObjectNearEdge(p)
            
            if hotspotResult.activeEdgeLocation != ActiveEdgeLocation.None {

                println("activate pending hotspot")
                
            }
            
            
            
            let x = activeObjectOrigin?.x
            let y = activeObjectOrigin?.y
            let z = activeObjectOrigin?.z
            
            var newPosition:SCNVector3?
            var result:SCNHitTestResult?
            
            switch camera.orientationMode {
                
            case .TableOverhead:
                //activeObject?.position = SCNVector3Make(x! + CFloat(translation.x), y!, z! + CFloat(translation.y))
                
                result = _hitTest.getResultFromHitTest(p, nodeName: "table", searchHiddenNodes: true)
                
                if result != nil {
                    newPosition = result?.worldCoordinates
                    activeObject?.position = newPosition!
                    //TODO create active edge linked to play point
                }
                
                // test card is held over active area
                result = _hitTest.getResultFromHitTest(p, nodeName: "activeArea", searchHiddenNodes: true)
                
                if result != nil {
                    
                    println("object over active area!")
                    
                    
                    
                }
                
            case .PlayerHand:
                
                //println("pan in hand perspective")
                
                result = _hitTest.getResultFromHitTest(p, nodeName: "playerHandPlane", searchHiddenNodes: true)
                
                if result != nil {
                    newPosition = result?.worldCoordinates
                    activeObject?.position = newPosition!
                    //TODO create active edge linked to play point
                }

                //activeObject?.position = SCNVector3Make(x! + CFloat(translation.x), y! - CFloat(translation.y), z!)
                
            default:
                println()
            }
            
            
            
            
            //                activeObject.position?.x = activeObjectOrigin.x? + CFloat(translation.x)
            //                activeObject?.position.y = CFloat(activeObjectOrigin?.y+translation.y)
            
        }
        
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            println("panGesture ended")
            
            let hotspotResult = checkPanObjectNearEdge(p)
            
            if hotspotResult.activeEdgeLocation != ActiveEdgeLocation.None && activeObject != nil {
                
                // confirm activeObject to pending hotspot
                switch camera.orientationMode {
                    
                case .TableOverhead:
                    println("sending card to hand")
                    // Draw card
                    let player = players[0] as Player
                    let cardGroup = activeCard?.currentGroup! // could be deck or field group
                    
                    player.drawCardFromGroup(activeCard!, group: cardGroup!)
                    
                case .PlayerHand:
                    println("sending card to field")
                        
                    // play card to field via playPoint
                    if activePlayPoint != nil {
                        
                        var isFlipped:Bool = false
                        
                        // play card face up, if released on top edge
                        if hotspotResult.activeEdgeLocation == ActiveEdgeLocation.Top {
                            isFlipped = true
                        
                        // play card face down, if released on bottom edge
                        } else if hotspotResult.activeEdgeLocation == ActiveEdgeLocation.Bottom {
                            
                        }
                        
                        activePlayPoint?.receiveCard(activeCard!, isFlipped:isFlipped)
                        
                    } else {
                        // play card to deck
                        let player = players[0] as Player
                        let cardGroup = cardGroups[0] as CardGroup
                        player.playCardToGroup(activeCard!, group: cardGroup)
                    }
                    
                    
                default:
                    println("no hotspot binding")
                    
                }
                
            } else if activeObject != nil {
                
                if camera.orientationMode == Camera.OrientationMode.TableOverhead {
                    
                    // if card was in deck group
                    // remove card from deck group
                    // add to open table group
                    // lay card to rest on table
                    
                    //let currentGroup = activeCard?.currentGroup!
                    
                    let deckDefaultGroup = cardGroups[0] as CardGroup
                    let tableOpenGroup = cardGroups[1] as CardGroup
                    
                    if activeCard?.currentGroup! == deckDefaultGroup {
                        
                        println("removing card from deck group")
                        
                        deckDefaultGroup.removeCard(activeCard!)
                        tableOpenGroup.addCard(activeCard!)
                    }
                }
                
                
            }
            
            camera.willChangePerspective = true
            releaseActiveObject()
            
        }

    }
    
    func handlePan3F(recognizer:UIPanGestureRecognizer) {
        
        let translation:CGPoint = recognizer.translationInView(self.view)
        println("handlePan 3F\(translation)")
        
        // prevent camera transition while gesture updating
        camera.willChangePerspective = false
        
        camera.pan(translation)

        if recognizer.state == UIGestureRecognizerState.Ended {
            println("pan 3F ended")
            camera.resetPan()
            camera.willChangePerspective = true
        }
        
    }
    
    func handlePan(recognizer:UIPanGestureRecognizer) {
        
        let fingers = recognizer.numberOfTouches()
        
        switch fingers {
        
        case 1:
            //recognizer.enabled = true
            handlePan1F(recognizer)
            
        case 3:
            //recognizer.enabled = true
            handlePan3F(recognizer)
            
        case 2:
            recognizer.enabled = false
            recognizer.enabled = true
        
        default:
            println("no pan handler")
        }
        
    }
    
    func getResultFromHitTest(location:CGPoint, nodeName:String) ->SCNHitTestResult? {
        
        println("getNodeFromHitTest")
        
        var match:SCNHitTestResult? = nil
        let sceneView = self.view as SCNView
        
        let hitResults:NSArray = sceneView.hitTest(location, options: nil)!
        //println("hit objects: \(hitResults)")
        
        if hitResults.count>0 {
            
            for hitResult in hitResults {
                
                let node:SCNNode = hitResult.node! as SCNNode
                
                if node.name==nodeName {
                    match = hitResult as? SCNHitTestResult
                }
            }
            
        }
        
        return match
    }
    
    func getObjectFromHitTest(location:CGPoint) ->SCNNode? {
        
        var result:SCNNode?
        let sceneView = self.view as SCNView
        
        let hitResults:NSArray = sceneView.hitTest(location, options: nil)!
        //println("hit objects: \(hitResults)")
        
        if hitResults.count>0 {
            println("first object")
            result = hitResults[0].node! as SCNNode
        } else {
            println("no objects")
            result = nil
        }
    
        return result
    }

    
    //func highlightObject(hitResults:NSArray) {
    func highlightObject(hitResult:AnyObject?) {
        
        // check that we clicked on at least one object
        //if hitResults.count > 0 {
        if hitResult !== nil {
            
            // retrieved the first clicked object
            //let result: AnyObject! = hitResults[0]
            let result = hitResult as SCNNode
            
            // get its material
            let material = result.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // on completion - unhighlight
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }

    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        var touch:UITouch? = touches.anyObject() as? UITouch
        println("window location: \(touch?.locationInView(nil))")
        println("view location: \(touch?.locationInView(self.view))")
        var p = touch?.locationInNode(uiOverlay)
       
        println("touch in overlay \(p?.x) , \(p?.y)")
        
        var node:SKNode? = uiOverlay.nodeAtPoint(p!)
        var name:String? = node?.name
        
        if (node !== nil && name? !== nil) {
            
            switch name! {
                
                case "btn:connect":
                    showBrowser()
                
                case "btn:player/add":
                    
                    let playerId = players.count+1
                    
                    addPlayer("player"+String(playerId))
                    
                    updatePlayers()
                
                
                default:
                    break
            }
        
        }
        
    }
    
    func calculatePlayerOrigins(count:Int, radius:Float, origin:SCNVector3) -> [SCNNode] {
        
        println("calculatePlayerPositions")
        
        var positions:[SCNNode] = []
        var angles:[Float] = []
        // +z maps to -y for points along circle
        
        let interval = Float(2.0*M_PI)/Float(count)
        println(interval)
        
        for index in 0...count-1 {
            angles.append( Float(index)*Float(interval) )
        }
        
        println("angles: \(angles)")
        
         // add PI to angles, since user's position is always at (0,1*radius) or (0,?,-1*radius)
        for angle in angles {
            
            let theta = Float(angle) + Float(M_PI_2)
            println("theta: \(theta)")
            
            let x = radius * cosf(theta) + origin.x
            let z = radius * sinf(theta) + origin.z
            
            var newOrigin = SCNNode()
            var facingRotation = SCNVector3Make(0, -CFloat(angle), 0)
            // face inward towards table center, and lay parallel to table
            newOrigin.position = SCNVector3Make(x, origin.y, z)
            newOrigin.eulerAngles = facingRotation
            
            positions.append(newOrigin)

        }
        
        return positions
    }
    
    func updatePlayers(){
        
        var origins = calculatePlayerOrigins(players.count, radius: Float(TABLE_RADIUS/2), origin: SCNVector3Zero)
        
        // is player rendered
        
        println("updatePlayers: \(players.count)")
        
        for (index, p) in enumerate(players) {
            
            let player = p as Player
            
            let origin = origins[index] as SCNNode
            
            if (player.isRendered) {
                player.updateOrigin(origin.position, orientation:origin.eulerAngles)
            } else {
                player.render(origin.position, orientation:origin.eulerAngles, rootNode: _scene.rootNode)
                player.setupDefaultHotspots()
            }
            
            
        }
        
        
        // get current number of players
        // calculate player positions around table
        
        // place player indicators at each position
        
        //player.render(SCNVector3Make(0, 50, Float(TABLE_RADIUS*0.5)), rootNode:_scene.rootNode)
    }
    
    func addPlayer(id:String) -> Player {
        
        var player = Player(id:id)
        players.addObject(player)
        
        return player
    }
    
    func moveCamera() {
        
        SCNTransaction.begin()
        SCNTransaction.setAnimationDuration(1.0)
        
        SCNTransaction.setCompletionBlock() {
            println("camera moved");
        }
        
        _cameraNode.position.z -= 100
        
        SCNTransaction.commit()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            //return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
            return Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue) | Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
