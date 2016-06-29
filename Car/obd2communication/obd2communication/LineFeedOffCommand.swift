//
//  LineFeedOffCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on LineFeedOffCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class LineFeedOffCommand : ObdProtocolCommand {
    private struct CONSTANTS {
        static let COMMAND = "AT L0"
        static let NAME = "Line Feed Off"
    }
    public init() {
        super.init(command: CONSTANTS.COMMAND)
    }
    
    public init(other: LineFeedOffCommand) {
        super.init(command: other.cmd!)
    }
    
    override public func getFormattedResult() -> String? {
        return getResult()
    }
    
    override public func getName() -> String {
        return CONSTANTS.NAME
    }
}