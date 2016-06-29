//
//  RPMCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on RPMCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation


public class RPMCommand : ObdCommand {
    private var rpm: Int = -1
    
    private struct CONSTANTS {
        static let COMMAND = "01 0C"
        static let UNIT = "RPM"
    }
    
    public init() {
        super.init(command: CONSTANTS.COMMAND)
    }
    
    public init(other: RPMCommand) {
        super.init(command: other.cmd!)
    }
    
    /**
     Berechnet die Umdrehungen pro Minute
    */
    override public func performCalculations() {
        guard buffer?.count >= 4 && buffer?[2] != nil && buffer?[3] != nil else {
            print("RPM not valid")
            return
        }
        rpm = (buffer![2] * 256 + buffer![3]) / 4
    }
    
    /**
     Liefert die Umdrehungen pro Minute als formatierter String
     - returns: formatierter String
    */
    override public func getFormattedResult() -> String? {
        return "\(rpm)\(self.getResultUnit())"
    }
    
    /**
     Liefert die Umdrehungen pro Minute als String
     - returns: Umdrehungen pro Minute
    */
    override public func getCalculatedResult() -> String? {
        return "\(rpm)"
    }
    
    /**
     Liefert die Einheit (RPM)
     - returns: RPM
    */
    override public func getResultUnit() -> String {
        return CONSTANTS.UNIT
    }
    
    /**
     Liefert den Namen des Kommandos
     - returns: Name des Kommandos
    */
    override public func getName() -> String {
        return AvailableCommandNames.ENGINE_RPM.getValue()
    }
    
    /**
     Liefert die Umdrehungen pro Minute
     - returns: Umdrehungen pro Minute
    */
    public func getRPM() -> Int {
        return rpm
    }
}