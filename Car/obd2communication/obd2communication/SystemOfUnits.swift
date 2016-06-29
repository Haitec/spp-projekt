//
//  SystemOfUnits.swift
//  obd2communication
//
//  Created by michael on 21.06.16.
//  Copyright © 2016 michael. All rights reserved.
//  Based on SystemOfUnits from pires (https://github.com/pires/obd-java-api)
//

import Foundation

protocol SystemOfUnits {
    /**
     Liefert den imperialen Wert
    */
    func getImperialUnit() -> Double
}