//
//  AirIntakeTemperatureCommand.swift
//  obd2communication
//
//  Created by michael on 25.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on AirIntakeTemperatureCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Kommando für die Ansaugtemperatur
*/
public class AirIntakeTemperatureCommand : TemperatureCommand {
    private struct CONSTANTS {
        static let COMMAND = "01 0F"
    }
    public init() {
        super.init(command: CONSTANTS.COMMAND)
    }
    
    public init(other: AirIntakeTemperatureCommand) {
        super.init(command: other.cmd!)
    }
    
    /**
     Liefert den Namen des Kommandos
     - returns: Name des Kommandos
    */
    public override func getName() -> String {
        return AvailableCommandNames.AIR_INTAKE_TEMP.getValue()
    }
}