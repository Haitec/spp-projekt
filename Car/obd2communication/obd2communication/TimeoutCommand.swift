//
//  TimeoutCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on TimeoutCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class TimeoutCommand : ObdProtocolCommand {
    private struct CONSTANTS {
        static let COMMAND = "AT ST"
        static let NAME = "TIMEOUT"
    }
    
    public init(timeout: Int) {
        super.init(command: "\(CONSTANTS.COMMAND) \(0xFF & timeout)")
    }
    
    public init(other: TimeoutCommand) {
        super.init(command: other.cmd!)
    }
    
    override public func getFormattedResult() -> String? {
        return getResult()
    }
    
    override public func getName() -> String {
        return CONSTANTS.NAME
    }
}