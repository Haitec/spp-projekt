//
//  PersistentCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on PersistentCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Basisklasse für Kommandos welche ihren Wert nicht ändern
*/
public class PersistentCommand : ObdCommand {
    private static var knownValues: [String:String] = [:]
    private static var knownBuffers: [String:Array<Int>] = [:]
    
    private struct CONSTANTS {
        static let SEPERATOR = "."
    }
    
    override public init(command: String) {
        super.init(command: command)
    }
    
    public init(other: ObdCommand) {
        super.init(command: other.cmd!)
    }
    
    /**
     Setzt die persistierten Werte zurück
    */
    public static func reset() {
        knownValues = [:]
        knownBuffers = [:]
    }
    
    /**
     Überprüft ob ein Kommando bereits enthalten ist
    */
    public static func knows(cmd: ObdCommand.Type) -> Bool {
        let str = String(cmd).componentsSeparatedByString(CONSTANTS.SEPERATOR).last!
        
        if knownValues[str as String] == nil {
            return false
        } else {
            return true
        }
    }
    
    /**
     liest das Ergebnis vom OBD2 Interface und persistiert das Ergebnis
     - parameter inp: Socketverbindung zum OBD2 Interface
    */
    override public func readResult(inp: ObdSocket) {
        super.readResult(inp)
        if checkForErrors() {
            return
        }
        let str = String(self).componentsSeparatedByString(CONSTANTS.SEPERATOR).last!
        PersistentCommand.knownValues[str] = rawData
        PersistentCommand.knownBuffers[str] = Array<Int>(buffer!)
        print(str)
    }
    
    /**
     Führt das Kommando aus
     - parameter socket: Socketverbindung zum OBD2 Interface
    */
    override public func run(socket: ObdSocket) {
        let str = String(self).componentsSeparatedByString(CONSTANTS.SEPERATOR).last!
        
        if(PersistentCommand.knownValues[str] == nil) {
            super.run(socket)
        } else {
            rawData = PersistentCommand.knownValues[str]
            buffer = PersistentCommand.knownBuffers[str]
            performCalculations()
        }
    }
}