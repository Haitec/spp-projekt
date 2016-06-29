//
//  ObdCommand.swift
//  obd2communication
//
//  Created by michael on 14.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on ObdCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

/**
 Basisklasse für die OBD2 Kommandos
*/
public class ObdCommand: Hashable {
    
    private struct CONSTANTS {
        static let CARRIAGE_RETURN = "\r"
        
        static let REGEXP_WHITESPACES = "\\s"
        static let REGEXP_BUSINIT = "(BUS INIT)|(BUSINIT)|(\\.)|(\\\\)"
        static let REGEXP_SEARCHING = "(SEARCHING)|(>)|(\\?)"
        static let BYTE_LENGTH = 2
        static let BYTE_START = 0
        static let HEX_BASIS = 16
        
        static let TERMINATOR = ">"
        
        static let EMPTY = ""
        
        static let BUFFERSIZE = 500
        
        static let ERROR = "ERROR"
    }
    
    var cmd: String? = nil
    var rawData: String? = nil
    private var start: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
    private var end: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
    var buffer: Array<Int>? = nil
    private var imperialUnits: Bool = false
    
    private var m_Error: ResponseException?
    
    public var Error: ResponseException? {
        return m_Error
    }
    
    public static let Mutex = 0
    
    public init(command: String) {
        cmd = command
        buffer = Array<Int> ()
    }
    
    public convenience init(other: ObdCommand) {
        self.init(command: other.cmd!)
    }
    
    private init() {
    }
    
    
    /**
     Lädt die Daten vom OBD2 Interface
     - parameter socket: Socketverbindung zum OBD2 Interface
    */
    public func run(socket: ObdSocket) {
        objc_sync_enter(ObdCommand.Mutex)                                                   // Betreten des kritischen Bereichs
        m_Error = nil
        start = NSDate.timeIntervalSinceReferenceDate()
        sendCommand(socket)
        readResult(socket)
        end = NSDate.timeIntervalSinceReferenceDate()
        objc_sync_exit(ObdCommand.Mutex)                                                    // Verlassen des kritischen Bereichs
    }
    
    /**
     Sendet das Kommando an das OBD2 Interface
     - parameter out: Socketverbindung zum OBD2 Interface
    */
    func sendCommand(out: ObdSocket) {
        guard cmd != nil else {
            fatalError("command is nil")
        }
        let send: String = cmd! + CONSTANTS.CARRIAGE_RETURN
        out.send(send)
    }
    
    /**
     Sendet das Kommando erneut
     - parameter out: Socketverbindung zum OBD2 Interface
    */
    func resendCommand(out: ObdSocket) {
        let send: String = CONSTANTS.CARRIAGE_RETURN
        out.send(send)
    }
    
    /**
     Liest die Antwort vom OBD2 Interface
     - parameter inp: Socketverbindung zum OBD2 Interface
    */
    func readResult(inp: ObdSocket) {
        readRawData(inp)
        if checkForErrors() {
            return
        }
        fillBuffer()
        performCalculations()
    }
    
    
    /**
     Überprüft ob bei der Anfrage ein Fehler aufgetreten ist
     - returns: True wenn ein Fehler eingetreten ist
    */
    func checkForErrors() -> Bool {
        let ERROR_CLASSES: Array<ResponseException.Type> = [UnableToConnectException.self, BusInitException.self, MissunderstoodException.self, NoDataException.self, UnkownErrorException.self, UnsupportedCommandException.self]
        guard rawData != nil else {
            return false
        }
        for a in ERROR_CLASSES {
            let b = a.init()
            if(b.isError(response: rawData!)) {
                m_Error = b
                m_Error?.setCommand(command: getName())
                return true
            }
        }
        m_Error = nil
        return false
    }
    
    /**
     Wandelt den empfangenen Wert um. Muss von Kindklassen implementiert werden
    */
    func performCalculations() {
        fatalError("performCalculations must be implemented")
    }
    
    /**
     Bereitet den empfangenen String auf und wandelt diesen in ein Array um
    */
    func fillBuffer() {
        guard rawData != nil && buffer != nil else {
            fatalError("no rawData or buffer")
        }
        let regExpWhiteSpaces = try? NSRegularExpression(pattern: CONSTANTS.REGEXP_WHITESPACES, options: .CaseInsensitive)
        let regExpBusData = try? NSRegularExpression(pattern: CONSTANTS.REGEXP_BUSINIT, options: .CaseInsensitive)
        
        if regExpWhiteSpaces == nil || regExpBusData == nil {
            fatalError("Regular Expressions cannot be initalized")
        }
        
        rawData = regExpWhiteSpaces!.stringByReplacingMatchesInString(rawData!, options: .WithTransparentBounds, range: NSMakeRange(0, rawData!.characters.count), withTemplate: CONSTANTS.EMPTY)
        rawData = regExpBusData!.stringByReplacingMatchesInString(rawData!, options: .WithTransparentBounds, range: NSMakeRange(0, rawData!.characters.count), withTemplate: CONSTANTS.EMPTY)
        
        buffer?.removeAll()
        
        var beginPos: Int = CONSTANTS.BYTE_START
        var endPos: Int = CONSTANTS.BYTE_LENGTH
        if rawData == nil {
            fatalError("Regular Expression failed")
        }
        if (rawData!.startIndex.distanceTo(rawData!.endIndex) % CONSTANTS.BYTE_LENGTH != 0) {
            return
        }
        var startIndex = rawData!.startIndex.advancedBy(beginPos)
        if rawData!.startIndex.distanceTo(rawData!.endIndex) < endPos {
            return
        }
        var endIndex = rawData!.startIndex.advancedBy(endPos)
        while (endIndex <= rawData!.endIndex) {
            
            if rawData!.startIndex.distanceTo(rawData!.endIndex) < endPos {
                return
            }
            
            startIndex = rawData!.startIndex.advancedBy(beginPos)
            endIndex = rawData!.startIndex.advancedBy(endPos)
            //let range = Range<String.CharacterView.Index>(start: startIndex!, end: endIndex!)
            if endIndex > rawData!.endIndex {
                return
            }
            let range = startIndex ..< endIndex
            let data = rawData?.substringWithRange(range)
            if data == nil {
                fatalError("Data nil")
            } else {
            }
            let intData = Int(data!, radix: CONSTANTS.HEX_BASIS)
            if intData != nil {
                buffer!.append(intData!)
            }
            
            beginPos = endPos
            endPos += CONSTANTS.BYTE_LENGTH
        }
    }
    
    /**
     Liest die Daten vom OBD2 Interface
     - parameter inp: Socketverbindung zum OBD2 Interface
    */
    func readRawData(inp: ObdSocket) {
        let regExpWhiteSpaces = try? NSRegularExpression(pattern: CONSTANTS.REGEXP_WHITESPACES, options: .CaseInsensitive)
        let regExpBusData = try? NSRegularExpression(pattern: CONSTANTS.REGEXP_SEARCHING, options: .CaseInsensitive)
        
        if regExpWhiteSpaces == nil || regExpBusData == nil {
            fatalError("Regular Expressions cannot be initalized")
        }
        
        let bufferSize = CONSTANTS.BUFFERSIZE
        var inputBuffer = Array<UInt8>(count:bufferSize, repeatedValue: 0)
        
        var responseString: String? = CONSTANTS.EMPTY
        responseString = inp.readUntilCharacterOccured(CONSTANTS.TERMINATOR, timeOutSeconds: 6)
        rawData = responseString
        guard rawData != nil else {
            rawData = "ERROR"
            return
        }
        rawData = regExpWhiteSpaces!.stringByReplacingMatchesInString(rawData!, options: .WithTransparentBounds, range: NSMakeRange(0, rawData!.characters.count), withTemplate: CONSTANTS.EMPTY)
        rawData = regExpBusData!.stringByReplacingMatchesInString(rawData!, options: .WithTransparentBounds, range: NSMakeRange(0, rawData!.characters.count), withTemplate: CONSTANTS.EMPTY)
        
    }
    
    /**
     Liefert das Ergebnis des Kommandos
     - returns: Empfangene Daten
    */
    func getResult() -> String? {
        return rawData
    }
    
    /**
     Liefert das formatiertes Ergebnis des Kommandos
     - returns: formatiertes Ergebnis
    */
    func getFormattedResult() -> String? {
        fatalError("getFormattedResult must be implemented")
    }
    
    /**
     Liefert das berechnete Ergebnis des Kommandos
     - returns: berechnete Ergebnis
    */
    func getCalculatedResult() -> String? {
        fatalError("getCalculatedResult must be implemented")
    }
    
    /**
     Liefert den Puffer der Daten
     - returns: Puffer mit den empfangene Daten
    */
    func getBuffer() -> Array<Int>? {
        return buffer
    }
    
    /**
     Sollen imperiale Einheiten verwendet werden
     - returns: True wenn imperiale Einheiten verwendet werden sollen
    */
    func useImperialUnits() -> Bool {
        return imperialUnits
    }
    
    /**
     Liefert die Einheit des Kommandos
     - returns: String der Einheit
    */
    func getResultUnit() -> String {
        return ""
    }
    
    /**
     Setzt ob imperiale Einheiten verwendet werden sollen
     - parameter isImperial: imperiale Einheiten verwenden
    */
    func useImperialUnits(isImperial: Bool) {
        imperialUnits = isImperial
    }
    
    /**
     Liefert die benötigte Zeit für die Anfrage
     - returns: benötigte Zeit für die Anfrage
    */
    public func getResponseTimeDelay() -> NSTimeInterval {
        return end - start
    }
    
    /**
     Liefert den Namen des Kommandos
     - returns: Name des Kommandos
    */
    func getName() -> String {
        return cmd!
    }
    
    /**
     Liefert den Startzeitpunkt
     - returns: Startzeitpunkt
    */
    func getStart() -> NSTimeInterval {
        return start
    }
    
    /**
     Setzt den Startzeitpunkt
     - parameter time: Startzeitpunkt
    */
    func setStart(time: NSTimeInterval) {
        start = time
    }
    
    /**
     Liefert den Endzeitpunkt
     - returns: Endzeitpunkt
    */
    func getEnd() -> NSTimeInterval {
        return end
    }
    
    /**
     Setzt den Endzeitpunkt
     - parameter time: Endzeitpunkt
    */
    func setEnd(time: NSTimeInterval) {
        end = time
    }
    
    /**
     Liefert die PID
     - returns: PID
    */
    final func getCommandPID() -> String? {
        let beginPos = 0
        let endPos = 3
        let startIndex = rawData!.characters.startIndex.advancedBy(beginPos)
        let endIndex = rawData!.characters.startIndex.advancedBy(endPos)
        return cmd?.substringWithRange(startIndex..<endIndex)
    }
    
    /**
     Liefert den Hashwert
     - returns: Hashwert als Int
    */
    public var hashValue: Int {
        guard cmd != nil else {
            fatalError("Command not set")
        }
        return cmd!.hashValue
    }
    
    /**
     Vergleicht die ObdCommands
     - parameter object: anderes Objekt
     - returns: True wenn gleich
    */
    public func equals(_ object: ObdCommand) -> Bool {
        guard let rhs = object as? ObdCommand else {
            return false
        }
        let lhs = self
        
        return lhs.getCommandPID() == rhs.getCommandPID()
    }
    
}

public func ==(lhs: ObdCommand, rhs: ObdCommand) -> Bool {
    return lhs.getCommandPID() == rhs.getCommandPID()
}