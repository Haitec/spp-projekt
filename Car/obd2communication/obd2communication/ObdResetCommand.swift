//
//  ObdResetCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on ObdResetCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class ObdResetCommand : ObdProtocolCommand {
    private struct CONSTANTS {
        static let COMMAND = "AT Z"
        static let NAME = "Reset OBD"
    }
    public init() {
        super.init(command: CONSTANTS.COMMAND)
    }
    
    public init(other: ObdResetCommand)
    {
        super.init(command: other.cmd!)
    }
    
    public override func getFormattedResult() -> String? {
        return getResult()
    }
    
    public override func getName() -> String {
        return CONSTANTS.NAME
    }
}