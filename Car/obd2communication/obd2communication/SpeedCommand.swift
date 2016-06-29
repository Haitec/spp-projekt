//
//  SpeedCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on SpeedCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Kommando für die Geschwindigkeitsabfrage (01 0D)
*/
public class SpeedCommand : ObdCommand, SystemOfUnits {
    private struct CONSTANTS {
        static let COMMAND = "01 0D"
        static let FORMATSTRING = "%.2f%s"
        static let METRICUNIT = "km/h"
        static let IMPERIALUNIT = "mph"
    }
    
    private var metricSpeed: Int = 0
    
    public init() {
        super.init(command: CONSTANTS.COMMAND)
    }
    
    public init(other: SpeedCommand) {
        super.init(command: other.cmd!)
    }
    
    /**
     Berechnet die Geschwindigkeit aus dem gelieferten Werten
    */
    override public func performCalculations() {
        guard buffer?.count > 2 && buffer?[2] != nil else {
            print("speed not valid")
            return
        }
        metricSpeed = buffer![2]
    }
    
    /**
     Liefert das Ergebnis in km/h
     - returns: Geschwindigkeit in km/h
    */
    public func getMetricSpeed() -> Int {
        return metricSpeed
    }
    
    /**
     Liefert das Ergebnis in mph
     - returns: Geschwindigkeit in mph
    */
    public func getImperialSpeed() -> Double {
        return getImperialUnit()
    }
    
    /**
     Liefert das Ergebnis in mph
     - returns: Ergebnis in mph
    */
    public func getImperialUnit() -> Double {
        return Double(metricSpeed) * 0.621371192
    }
    
    /**
     Liefert das Ergebnis als formatierter String mit Einheit
     - returns: formatierter String mit Einheit
    */
    override public func getFormattedResult() -> String? {
        return useImperialUnits() ? NSString(format: CONSTANTS.FORMATSTRING, getImperialSpeed(), self.getResultUnit()) as String : "\(metricSpeed)\(self.getResultUnit())"
    }
    
    /**
     Liefert die Einheit des Ergebnis mph oder km/h
    */
    override public func getResult() -> String? {
        return useImperialUnits() ? CONSTANTS.IMPERIALUNIT : CONSTANTS.METRICUNIT
    }
    
    /**
     Liefert den Namen des Kommandos
    */
    override public func getName() -> String {
        return AvailableCommandNames.SPEED.getValue()
    }
}