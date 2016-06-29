//
//  PDataLoader.swift
//  Car
//
//  Created by michael on 04.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import Foundation

protocol PDataLoaderDelegate {
    func ok()
}

protocol PDataLoader: class {
    /**
     Startet das Laden der Daten
    */
    func begin()
    /**
     Stopt das laden der Daten
    */
    func stop()
    /**
     Ermittelt den Zustand des Systems
     - returns: True wenn Daten geladen werden
    */
    func running() -> Bool
    var delegate: PDataLoaderDelegate? { get set}
}

/**
    Eventnamen für die Benachrichtungen
 */
struct NotificationEvents {
    static let SpeedValue = "SpeedValue"
    static let RPMValue = "RPMValue"
    static let AmbientAirTemp = "AmbientAirTemp"
    static let Vin = "VIN"
    static let EngineCoolant = "EngineCoolant"
}

/**
    UserInfos Schlüssel für die Benachrichtigungen
 */
struct NotificationUserKeys {
    static let SpeedValue = "SpeedValue"
    static let RPMValue = "RPMValue"
    static let AmbientAirTemp = "AmbientAirTemp"
    static let Vin = "VIN"
    static let EngineCoolant = "EngineCoolant"
    
    static let ErrorMessage = "ErrorMessage"
    
    static let ErrorMessageSuccess = "OK"
}