//
//  UnableToConnect.swift
//  obd2communication
//
//  Created by michael on 22.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on UnableToConnectException from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public class UnableToConnectException : ResponseException {
    private struct CONSTANTS {
        static let ERROR_NAME = "UNABLE TO CONNECT"
    }
    public required init()
    {
        super.init(message: CONSTANTS.ERROR_NAME)
    }
}