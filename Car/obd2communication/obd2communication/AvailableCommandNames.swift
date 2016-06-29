//
//  AvailableCommandNames.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on AvailableCommandNames from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public enum AvailableCommandNames: String {
    case AIR_INTAKE_TEMP = "Air Intake Temperature"
    case AMBIENT_AIR_TEMP = "Ambient Air Temperature"
    case ENGINE_COOLANT_TEMP = "Engine Coolant Temperature"
    case BAROMETRIC_PRESSURE = "Barometric Pressure"
    case FUEL_PRESSURE = "Fuel Pressure"
    case INTAKE_MANIFOLD_PRESSURE = "Intake Mainfold Pressure"
    case ENGINE_LOAD = "Engine Load"
    case ENGINE_RUNTIME = "Engine Runtime"
    case ENGINE_RPM = "Engine RPM"
    case SPEED = "Vehicle Speed"
    case MAF = "Mass Air Flow"
    case THROTTLE_POS = "Throttle Position"
    case TROUBLE_CODES = "Trouble Codes"
    case PENDING_TROUBLE_CODES = "Pending Trouble Codes"
    case PERMANENT_TROUBLE_CODES = "Permanent Trouble Codes"
    case FUEL_LEVEL = "Fuel Level"
    case FUEL_TYPE = "Fuel Type"
    case FUEL_CONSUMPTION_RATE = "Fuel Consumption Rate"
    case VIN = "VIN"
    
    
    public func getValue() -> String {
        return rawValue
    }
}