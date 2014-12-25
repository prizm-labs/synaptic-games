//
//  MeteorResponder.swift
//  HostExample
//
//  Created by Michael Garrido on 12/21/14.
//  Copyright (c) 2014 Michael Garrido. All rights reserved.
//

import Foundation

protocol MeteorDelegate {
    
    func didConnect()
    func didDisconnect()
    
    func websocketReady()
    func didReceiveUpdate()
}

class MeteorResponder {
    var delegate:MeteorDelegate?
    
    init(){
        
    }
}