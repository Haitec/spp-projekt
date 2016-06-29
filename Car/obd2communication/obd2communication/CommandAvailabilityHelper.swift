//
//  CommandAvailabilityHelper.swift
//  obd2communication
//
//  Created by michael on 14.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on CommandAvailabilityHelper from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class CommandAvailabilityHelper {
    private struct CONSTANTS {
        static let ZEROZEROCOMMAND = "00"
    }
    
    /**
     Wandelt den eingegeben Hex String in ein 16 Bit Array um
     - parameter availabilityString: zu überprüfende Zeichenkette
     - returns: Array der enthaltenen Werte
    */
    public static func digestAvailabilityString(availabilityString: String) -> Array<Int>? {
        if availabilityString.characters.count % 8  != 0 {
            return nil
        }
        
        var availabilityArray = Array<Int>()
        for i in 0 ... (availabilityString.characters.count/2-1) {
            let index1 = availabilityString.startIndex.advancedBy(i*2)
            let index2 = availabilityString.startIndex.advancedBy((i*2)+1)
            let firstValue = parseHexChar(availabilityString.characters[index1])
            let secondValue = parseHexChar(availabilityString.characters[index2])
            
            if firstValue == nil || secondValue == nil {
                return nil
            }
            
            availabilityArray.append(firstValue!*16+secondValue!)
        }
        return availabilityArray
    }
    
    /**
     Wandelt einen Character in seinen Hex Wert um
     - parameter hexChar: umzuwandelnder Character
     - returns: Int Wert
    */
    private static func parseHexChar(hexChar: Character) -> Int? {
        switch(hexChar) {
        case "0":
            return 0
        case "1":
            return 1
        case "2":
            return 2
        case "3":
            return 3
        case "4":
            return 4
        case "5":
            return 5
        case "6":
            return 6
        case "7":
            return 7
        case "8":
            return 8
        case "9":
            return 9
        case "A":
            return 10
        case "B":
            return 11
        case "C":
            return 12
        case "D":
            return 13
        case "E":
            return 14
        case "F":
            return 15
        default:
            return nil
        }
    }
    
    /**
     Überprüft ob ein Kommando in dem Array vorhanden ist
     - parameter commandPid: Kommando
     - parameter availabilityArray: Array welches durch digestAvailabilityString geliefert wurde
     - returns: True wenn unterstützt
    */
    public static func isAvailable(commandPid: String, availabilityArray: Array<Int>) -> Bool? {
        if commandPid == CONSTANTS.ZEROZEROCOMMAND {
            return true
        }
        var cmdNumber = Int(commandPid, radix: 16)
        if cmdNumber == nil {
            return nil
        }
        let arrayIndex = (cmdNumber! - 1) / 8
        if arrayIndex > availabilityArray.count - 1 {
            return nil
        }
        
        while(cmdNumber > 8) {
            cmdNumber! -= 8
        }
        
        var requestedAvailability: Int?
        
        switch (cmdNumber!) {
        case 1:
            requestedAvailability = 128
        case 2:
            requestedAvailability = 64
        case 3:
            requestedAvailability = 32
        case 4:
            requestedAvailability = 16
        case 5:
            requestedAvailability = 8
        case 6:
            requestedAvailability = 4
        case 7:
            requestedAvailability = 2
        case 8:
            requestedAvailability = 1
        default:
            return nil
        }
        
        return requestedAvailability! == (requestedAvailability! & availabilityArray[arrayIndex])
    }
    
    /**
     Überprüft ob ein Kommando in dem Array vorhanden ist, kein nil
     - parameter commandPid: Kommando
     - parameter availabilityArray: Array welches durch digestAvailabilityString geliefert wurde
     - parameter safetyReturn: defaultWert für return
     - returns: True wenn unterstützt
     */
    public static func isAvailable(commandPid: String, availabilityArray: Array<Int>, safetyReturn: Bool) -> Bool {
        let value = isAvailable(commandPid, availabilityArray: availabilityArray)
        if value == nil {
            return safetyReturn
        }
        return value!
    }
    
    /**
     Überprüft ob ein Kommando in dem String vorhanden ist
     - parameter commandPid: Kommando
     - parameter availabilityString: String welcher von Obd Interface geliefert wurde
     - returns: True wenn unterstützt
     */
    public static func isAvailable(commandPid: String, availabilityString: String) -> Bool? {
        let arr = digestAvailabilityString(availabilityString)
        if arr == nil {
            return nil
        }
        return isAvailable(commandPid, availabilityArray: arr!)
    }
    
    /**
     Überprüft ob ein Kommando in dem String vorhanden ist, kein nil
     - parameter commandPid: Kommando
     - parameter availabilityString: String welcher von Obd Interface geliefert wurde
     - parameter safetyReturn: defaultWert für return
     - returns: True wenn unterstützt
     */
    public static func isAvailable(commandPid: String, availabilityString: String, safetyReturn: Bool) -> Bool {
        let arr = digestAvailabilityString(availabilityString)
        if arr == nil {
            return safetyReturn
        }
        return isAvailable(commandPid, availabilityArray: arr!, safetyReturn: safetyReturn)
    }
    
}
