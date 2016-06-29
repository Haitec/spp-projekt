//
//  VinCommand.swift
//  obd2communication
//
//  Created by michael on 25.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on VinCommand from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class VinCommand : PersistentCommand {
    var vin: String = ""
    
    public init() {
        super.init(command: "09 02")
    }
    
    public init(other: VinCommand) {
        super.init(command: other.cmd!)
    }
    
    override func performCalculations() {
        let result = getResult()
        var workingData: String = ""
        if(result!.containsString(":")) {
            let regExpDots = try? NSRegularExpression(pattern: ".:", options: .CaseInsensitive)
            let regExpMatcher = try? NSRegularExpression(pattern: "[^a-z0-9 ]", options: [])
            workingData = regExpDots!.stringByReplacingMatchesInString(result!, options: .WithTransparentBounds, range: NSMakeRange(0, result!.characters.count), withTemplate: "")
            let hexString: String = convertHexToString(workingData)
            let matches = regExpMatcher?.numberOfMatchesInString(hexString, options: [], range: NSMakeRange(0, hexString.characters.count))
            if matches > 0 {
                let regExp049 = try? NSRegularExpression(pattern: "0:49", options: [])
                workingData = regExp049!.stringByReplacingMatchesInString(workingData, options: [], range: NSMakeRange(0, workingData.characters.count), withTemplate: "")
                workingData = regExpDots!.stringByReplacingMatchesInString(workingData, options: .WithTransparentBounds, range: NSMakeRange(0, workingData.characters.count), withTemplate: "")
            }
        } else {
            let regExp49020 = try? NSRegularExpression(pattern: "49020.", options: [])
            workingData = regExp49020!.stringByReplacingMatchesInString(result!, options: .WithTransparentBounds, range: NSMakeRange(0, result!.characters.count), withTemplate: "")
        }
        let regExpUtf = try? NSRegularExpression(pattern: "[\\u0000-\\001F]", options: [])
        let hexOutput = convertHexToString(workingData)
        vin = regExpUtf!.stringByReplacingMatchesInString(hexOutput, options: .WithTransparentBounds, range: NSMakeRange(0, hexOutput.characters.count), withTemplate: "")
    }
    
    override public func getFormattedResult() -> String? {
        return "\(vin)"
    }
    
    override public func getName() -> String {
        return AvailableCommandNames.VIN.getValue()
    }
    
    override public func getCalculatedResult() -> String? {
        return getFormattedResult()
    }
    
    override func fillBuffer() {
    }
    
    func convertHexToString(hex: String) -> String {
        var output = ""
        if hex.characters.count % 2 != 0 {
            fatalError("hexValue is wrong")
        }
        
        var beginPos: Int = 0
        var endPos: Int = 2
        var startIndex = hex.startIndex.advancedBy(beginPos)
        if hex.startIndex.distanceTo(hex.endIndex) < endPos {
            return ""
        }
        var endIndex = hex.startIndex.advancedBy(endPos)
        while (endIndex <= hex.endIndex) {
            
            if hex.startIndex.distanceTo(rawData!.endIndex) < endPos {
                break
            }
            
            startIndex = hex.startIndex.advancedBy(beginPos)
            endIndex = hex.startIndex.advancedBy(endPos)
            
            if endIndex > rawData!.endIndex {
                break
            }
            
            let range = startIndex ..< endIndex
            let data = hex.substringWithRange(range)
            let intData = Int(data, radix: 16)
            if intData != nil {
                output.append(Character(UnicodeScalar(intData!)))
            }
            
            beginPos = endPos
            endPos += 2
        }
        
        return output
    }
}