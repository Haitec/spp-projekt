//
//  ObdMultiCommand.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on ObdMultiCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Klasse um mehrere OBD2 Kommandos zu senden
*/
public class ObdMultiCommand {
    private struct CONSTANTS {
        static let EMPTY = ""
        static let COMMA_SEPERATOR = ", "
    }
    private var commands: Array<ObdCommand>
    
    public init() {
        commands = Array<ObdCommand>()
    }
    
    /**
     Fügt ein Kommando zur Anfrage hinzu
     - parameter command: hinzuzufügendes Kommando
    */
    public func add(command: ObdCommand) {
        commands.append(command)
    }
    
    /**
     Entfernt ein Kommando aus der Anfrage
     - parameter command: zu entfernendes Kommando
     */
    public func remove(command: ObdCommand) {
        let index = commands.indexOf(command)
        guard index != nil else {
            return
        }
        commands.removeAtIndex(index!)
    }
    
    /**
     Sendet die Kommandos
     - parameter socket: Socketverbindung zum OBD2 Interface
    */
    public func sendCommands(socket: ObdSocket) {
        for command in commands {
            command.run(socket)
        }
    }
    
    /**
     Liefert das formatierte Ergebnis der Anfragen
     - returns: erhaltene Antworten des Kommandos
    */
    public func getFormattedResult() -> String? {
        var res: String = CONSTANTS.EMPTY
        for command in commands {
            guard command.getFormattedResult() != nil else {
                return nil
            }
            res.appendContentsOf(command.getFormattedResult()!)
            res.appendContentsOf(CONSTANTS.COMMA_SEPERATOR)
        }
        return res
    }
}