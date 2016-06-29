//
//  TemperatureCommand.swift
//  obd2communication
//
//  Created by michael on 25.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on TemperatureCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Basisklasse für Temperaturkommandos
*/
public class TemperatureCommand : ObdCommand, SystemOfUnits {
    
    public var temperature = 0.0
    
    private struct CONSTANTS {
        static let SUBSTRACT = 40.0
        static let FAHRENHEIT_MULTIPLIKATOR = 1.8
        static let FAHRENHEIT_ADDITION = 32
        static let FAHRENHEIT = "°F"
        static let CELSIUS = "°C"
        
        static let KELVINOFFSET = 273.15
    }
    
    override public init(command: String) {
        super.init(command: command)
    }
    
    /**
     Berechnet die Temperatur
    */
    override func performCalculations() {
        guard buffer?.count > 2 else {
            print("Buffer not correct")
            return
        }
        temperature = Double(buffer![2]) - CONSTANTS.SUBSTRACT
    }
    
    /**
     Liefert die Temperatur als formatierten String
     - returns: formatierter String
    */
    override public func getFormattedResult() -> String? {
        return useImperialUnits() ? "\(getImperialUnit())\(getResultUnit())" : "\(temperature)\(getResultUnit())"
    }
    
    /**
     Liefert die Temperatur als String
     - returns: Temperatur als String
    */
    override public func getCalculatedResult() -> String? {
        return useImperialUnits() ? "\(getImperialUnit()))" : "\(temperature))"
    }
    
    /**
     Liefert die Einheit der Temperatur
     - returns: Einheit der Temperatur
    */
    override public func getResultUnit() -> String {
        return useImperialUnits() ? CONSTANTS.FAHRENHEIT : CONSTANTS.CELSIUS
    }
    
    /**
     Liefert die Temperatur in Fahrenheit
     - returns: Temperatur als Fahrenheit
    */
    public func getImperialUnit() -> Double {
        return Double(temperature) * CONSTANTS.FAHRENHEIT_MULTIPLIKATOR + CONSTANTS.FAHRENHEIT_MULTIPLIKATOR
    }
    
    /**
     Liefert die Temperatur in Kelvin
     - returns: Temperatur in Kelvin
    */
    public func getKelvin() -> Double {
        return temperature + CONSTANTS.KELVINOFFSET
    }
}