//
//  UnsupportedCommandException.swift
//  obd2communication
//
//  Created by michael on 22.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on UnsupportedCommandException from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class UnsupportedCommandException : ResponseException {
    private struct CONSTANTS {
        static let ERROR_NAME = "7F 0[0-A] 1[1-2]"
    }
    public required init()
    {
        super.init(message: CONSTANTS.ERROR_NAME, matchRegex: true)
    }
}