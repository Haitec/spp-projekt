//
//  ObdWifiDataLoader.swift
//  Car
//
//  Created by michael on 22.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import Foundation
import obd2communication

class ObdWifiDataLoader : NSObject, PDataLoader, NSStreamDelegate, ObdSocketDelegate {
    private var obdSocket = ObdSocket()
    
    private var connected: Bool = false
    
    private let host: String
    private var port: Int
    private var timer_fast: NSTimer?
    private var timer_slow: NSTimer?
    
    private struct CONSTANTS {
        static let obdTimeout = 62
        static let fastTimerInterval = 0.5
        static let slowTimerInterval = 5.0
        static let obdDefaultPort = 35000
    }
    
    var delegate: PDataLoaderDelegate?
    
    /**
     Wird aufgerufen wenn ein Verbindungsevent auf dem Socket eintrifft
    */
    func connected(didConnected: Bool) {
        connected = didConnected
        if(connected) {
            start()
        }
    }
    
    init(host hst: String, port prt: Int) {
        host = hst
        port = prt
    }
    
    func running() -> Bool {
        return connected
    }
    
    /**
     Intialisiert die OBD2 Schnittstelle und startet die Timer
    */
    private func start() {
        print("starting")
        let echoOff = EchoOffCommand()
        let tOut = TimeoutCommand(timeout: CONSTANTS.obdTimeout)
        let proto = SelectProtocolCommand(_protocol: ObdProtocols.AUTO)
        let reset = ObdResetCommand()
        
        reset.run(obdSocket)
        echoOff.run(obdSocket)
        tOut.run(obdSocket)
        proto.run(obdSocket)
        
        // Timer für die Abfrage, muss in der MainQueue erledigt werden
        dispatch_async(dispatch_get_main_queue()) {
            self.timer_fast = NSTimer.scheduledTimerWithTimeInterval(CONSTANTS.fastTimerInterval, target: self, selector: #selector(ObdWifiDataLoader.updateFast), userInfo: nil, repeats: true)
            self.timer_slow = NSTimer.scheduledTimerWithTimeInterval(CONSTANTS.slowTimerInterval, target: self, selector: #selector(ObdWifiDataLoader.updateSlow), userInfo: nil, repeats: true)
        }
    }
    
    /**
     Funktion für den SlowTimer
    */
    func updateSlow() {
        let vinCommand = VinCommand()
        let engineCoolantCommand = EngineCoolantTemperatureCommand()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            engineCoolantCommand.run(self.obdSocket)
            var userInfo = [NSObject:AnyObject]()
            if engineCoolantCommand.Error != nil {
                userInfo[NotificationUserKeys.EngineCoolant] = 0.0
                userInfo[NotificationUserKeys.ErrorMessage] = engineCoolantCommand.Error?.getErrorResponse()
            } else {
                userInfo[NotificationUserKeys.EngineCoolant] = engineCoolantCommand.getFormattedResult()
                userInfo[NotificationUserKeys.ErrorMessage] = NotificationUserKeys.ErrorMessageSuccess
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationEvents.EngineCoolant, object: nil, userInfo: userInfo)
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            vinCommand.run(self.obdSocket)
            var userInfo = [NSObject:AnyObject]()
            if vinCommand.Error != nil {
                userInfo[NotificationUserKeys.Vin] = ""
                userInfo[NotificationUserKeys.ErrorMessage] = vinCommand.Error?.getErrorResponse()
            } else {
                userInfo[NotificationUserKeys.Vin] = vinCommand.getFormattedResult()
                userInfo[NotificationUserKeys.ErrorMessage] = NotificationUserKeys.ErrorMessageSuccess
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationEvents.Vin, object: nil, userInfo: userInfo)
        }
    }
    
    /**
     Funktion für den FastTimer
     */
    func updateFast() {
        let rpmCmd = RPMCommand()
        let speedCmd = SpeedCommand()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            speedCmd.run(self.obdSocket)
            
            if speedCmd.Error != nil {
                print(speedCmd.Error!.getMessage())
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationEvents.SpeedValue, object: nil, userInfo: [NotificationUserKeys.RPMValue: 0, NotificationUserKeys.ErrorMessage: speedCmd.Error!.getErrorResponse()])
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationEvents.SpeedValue, object: nil, userInfo: [NotificationUserKeys.SpeedValue: speedCmd.getMetricSpeed(), NotificationUserKeys.ErrorMessage: NotificationUserKeys.ErrorMessageSuccess])
            }
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            rpmCmd.run(self.obdSocket)
            if rpmCmd.Error != nil {
                print(rpmCmd.Error!.getMessage())
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationEvents.RPMValue, object: nil, userInfo: [NotificationUserKeys.RPMValue: 0, NotificationUserKeys.ErrorMessage: rpmCmd.Error!.getErrorResponse()])
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationEvents.RPMValue, object: nil, userInfo: [NotificationUserKeys.RPMValue: rpmCmd.getRPM(), NotificationUserKeys.ErrorMessage: NotificationUserKeys.ErrorMessageSuccess])
                }
                
            }
        }
  
    }
    
    /**
     Verbindet sich mit dem Fahrzeug
    */
    func begin() {
        obdSocket.delegate = self
        if Int32(port) > UINT16_MAX {
            port = CONSTANTS.obdDefaultPort
        }
        obdSocket.setupConnection(host, port: UInt16(port))
    }
    
    /**
     Schliesst die Verbindung und beendet die Timer
    */
    func stop() {
        if timer_fast != nil {
            timer_fast!.invalidate()
        }
        if timer_slow != nil {
            timer_slow!.invalidate()
        }
        if connected {
            obdSocket.close()
        }
        connected = false
    }
}