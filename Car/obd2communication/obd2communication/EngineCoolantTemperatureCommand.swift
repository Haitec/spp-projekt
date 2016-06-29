//
//  EngineCoolantTemperatureCommand.swift
//  obd2communication
//
//  Created by michael on 25.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on EngineCoolantTemperatureCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Kommando für die Motortemperatur
*/
public class EngineCoolantTemperatureCommand : TemperatureCommand {
    private struct CONSTANTS {
        static let COMMAND = "01 05"
    }
    
    public init() {
        super.init(command: CONSTANTS.COMMAND)
    }
    
    public init(other: EngineCoolantTemperatureCommand) {
        super.init(command: other.cmd!)
    }
    
    /**
     Liefert den Namen des Kommandos
     - returns: Name des Kommandos
    */
    public override func getName() -> String {
        return AvailableCommandNames.ENGINE_COOLANT_TEMP.getValue()
    }
}