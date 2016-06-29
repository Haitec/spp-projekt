//
//  PercentageObdCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on PercentageObdCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Basisklasse für prozentuale Werte
*/
public class PercentageObdCommand : ObdCommand {
    private struct CONSTANTS {
        static let FORMAT_STRING = "%.1f%s"
        static let PERCENTAGE = "%"
    }
    
    var percentage: Double = 0.0
    
    public override init(command: String) {
        super.init(command: command)
    }
    
    public init(other: PercentageObdCommand) {
        super.init(command: other.cmd!)
    }
    
    /**
     Berechnet die Prozentzahl
    */
    override public func performCalculations() {
        percentage = (Double(buffer![2])*100.0) / 255.0
    }
    
    /**
     Liefert das Ergebnis als formatierten String
     - returns: formatierter String
    */
    override public func getFormattedResult() -> String? {
        return NSString(format: CONSTANTS.FORMAT_STRING, percentage, self.getResultUnit()) as String
    }
    
    /**
     Liefert die Prozentzahl
     - returns: Prozent
    */
    public func getPercentage() -> Double {
        return percentage
    }
    
    /**
     Liefert die Einheit (%)
     - returns: String der Einheit
    */
    override public func getResultUnit() -> String {
        return CONSTANTS.PERCENTAGE
    }
    
    /**
     Liefert die Prozentzahl als String
     - returns: Prozentzahl
    */
    override public func getCalculatedResult() -> String? {
        return "\(percentage)"
    }
}