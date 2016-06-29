//
//  UnkownErrorException.swift
//  obd2communication
//
//  Created by michael on 22.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on UnkownErrorException from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class UnkownErrorException : ResponseException {
    private struct CONSTANTS {
        static let ERROR_NAME = "ERROR"
    }
    public required init()
    {
        super.init(message: CONSTANTS.ERROR_NAME)
    }
}