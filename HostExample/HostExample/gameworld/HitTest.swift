//
//  HitTest.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/24/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import SceneKit


class HitTest {
    
    var sceneView:SCNView!
    
    init(sceneView:SCNView) {
        self.sceneView = sceneView
    }
    
    func getResultFromHitTest(location:CGPoint, nodeName:String, searchHiddenNodes:Bool=true) ->SCNHitTestResult? {
        
        //println("getResultFromHitTest")
        
        var match:SCNHitTestResult? = nil
        
        let options:Dictionary = [SCNHitTestIgnoreHiddenNodesKey:!searchHiddenNodes]
        
        let hitResults:NSArray = sceneView.hitTest(location, options: options)!
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
}
