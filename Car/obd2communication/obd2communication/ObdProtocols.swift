//
//  ObdProtocols.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on ObdProtocols from pires (https://github.com/pires/obd-java-api)
//

import Foundation

public enum ObdProtocols: String {
    
    case AUTO = "0"
    case SAE_J1850_PWM = "1"
    case SAE_J1850_VPW = "2"
    case ISO_9141_2 = "3"
    case ISO_14230_4_KWP = "4"
    case ISO_14230_4_KWP_FAST = "5"
    case ISO_15765_4_CAN = "6"
    case ISO_15765_4_CAN_B = "7"
    case ISO_15765_4_CAN_C = "8"
    case ISO_15765_4_CAN_D = "9"
    case SAE_J1939_CAN = "A"
    case USER1_CAN = "B"
    case USER2_CAN = "C"
    
    public func getValue() -> String {
        return rawValue
    }
}