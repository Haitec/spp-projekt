//
//  SelectProtocolCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on SelectProtocolCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class SelectProtocolCommand : ObdProtocolCommand {
    private final var m_protocol: ObdProtocols
    private struct CONSTANTS {
        static let COMMAND = "AT SP"
        static let NAME = "Select Protocol:"
    }
    
    public init(_protocol: ObdProtocols) {
        self.m_protocol = _protocol
        super.init(command: "\(CONSTANTS.COMMAND) \(_protocol.getValue())")
        
    }
    
    override func getFormattedResult() -> String? {
        return getResult()
    }
    
    override func getName() -> String {
        return "\(CONSTANTS.NAME) \(m_protocol)"
    }
}