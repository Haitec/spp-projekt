//
//  ObdProtocolCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on ObdProtocolCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation


public class ObdProtocolCommand : ObdCommand {
    override public init(command: String) {
        super.init(command: command)
    }
    
    public init(other: ObdProtocolCommand) {
        super.init(command: other.cmd!)
    }
    
    override func performCalculations() {
        // Nichts
    }
    
    override func fillBuffer() {
        // Keine Rückgabe
    }
    
    override public func getCalculatedResult() -> String? {
        return "\(self.getResult()!)"
    }
}