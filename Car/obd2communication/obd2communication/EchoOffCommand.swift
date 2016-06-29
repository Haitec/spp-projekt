//
//  EchoOffCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on EchoOffCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation


public class EchoOffCommand : ObdProtocolCommand {
    private struct CONSTANTS {
        static let COMMAND = "AT E0"
        static let NAME = "Echo Off"
    }
    public init() {
        super.init(command: CONSTANTS.COMMAND)
    }
    
    public init(other: EchoOffCommand) {
        super.init(command: other.cmd!)
    }
    
    override public func getFormattedResult() -> String? {
        return getResult()
    }
    
    override public func getName() -> String {
        return CONSTANTS.NAME
    }
}