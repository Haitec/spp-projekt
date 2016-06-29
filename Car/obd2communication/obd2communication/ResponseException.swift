//
//  ResponseException.swift
//  obd2communication
//
//  Created by michael on 22.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on ResponseException from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class ResponseException {
    private var message: String = ""
    private var response: String = ""
    private var command: String = ""
    private var matchRegex: Bool = false
    
    private struct CONSTANTS {
        static let REGEXP_WHITESPACE = "(\\s)|(\\.)"
        static let EMPTY = ""
        static let FORMAT_STRING = "Error running %s, rsponse %s"
    }
    
    required public init() {
        
    }
    
    init(message msg: String) {
        self.message = msg
    }
    
    init(message msg: String, matchRegex matchReg: Bool) {
        self.message = msg
        self.matchRegex = matchReg
    }
    
    private static func clean(s: String?) -> String {
        let regExpWhiteSpaces = try? NSRegularExpression(pattern: CONSTANTS.REGEXP_WHITESPACE, options: .CaseInsensitive)
        guard regExpWhiteSpaces != nil && s != nil else {
            return CONSTANTS.EMPTY
        }
        return regExpWhiteSpaces!.stringByReplacingMatchesInString(s!, options: .WithTransparentBounds, range: NSMakeRange(0, s!.characters.count), withTemplate: "")
    }
    
    public func isError(response resp: String) -> Bool {
        self.response = resp
        let regExp = try? NSRegularExpression(pattern: ResponseException.clean(message), options: .CaseInsensitive)
        guard regExp != nil else {
            fatalError("Error Message Expression failed")
        }
        let cleanResponse = ResponseException.clean(response)
        let numberMatches = regExp!.numberOfMatchesInString(cleanResponse, options: .WithTransparentBounds, range: NSMakeRange(0, cleanResponse.characters.count))
        if matchRegex {
            return numberMatches == 1
        } else {
            if numberMatches > 0 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    public func setCommand(command cmd: String) {
        self.command = cmd
    }
    
    public func getErrorResponse() -> String {
        return ResponseException.clean(response)
    }
    
    public func getMessage() -> String {
        return NSString(format: CONSTANTS.FORMAT_STRING, command, response) as String
    }
}