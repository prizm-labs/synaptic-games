//
//  HandManager.swift
//  CardPlay
//
//  Created by Michael Garrido on 10/15/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import SpriteKit

struct Layout {
    

    func distributePositionsAlongVector(){
        
    }
    
    func distributePositionsAlongVector(vector:SCNVector3, count:Int, origin:SCNVector3, cardWidth:Float) -> [Float] {
        println("distributePositionsAcrossAxis")
        var positions:[Float] = []
        
        for index in 1...count {
            println("position \(index)")
        }
        
        //
        
        var position:SCNVector3 = origin
        var value:Float!
        
        
        println("adding position \(position)")
        
        
        return positions
    }
    
    
}