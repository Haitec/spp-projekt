//
//  AmbientAirTemperatureCommand.swift
//  obd2communication
//
//  Created by michael on 22.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on AmbientAirTemperatureCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Kommando für die Anfrage der Umgebungstemperatur
*/
public class AmbientAirTemperatureCommand : TemperatureCommand {
    private struct CONSTANTS {
        static let COMMAND = "01 46"
    }
    
    public init() {
        super.init(command: CONSTANTS.COMMAND)
    }
    
    public init(other: AmbientAirTemperatureCommand) {
        super.init(command: other.cmd!)
    }
    
    /**
     Liefert den Namen des Kommandos
     - returns: Name des Kommandos
    */
    public override func getName() -> String {
        return AvailableCommandNames.AMBIENT_AIR_TEMP.getValue()
    }
}