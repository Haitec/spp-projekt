//
//  DataStorage.swift
//  Car
//
//  Created by michael on 05.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import Foundation

class DataStorage {
    
    private struct CONSTANTS {
        static let COLUMN_TITLES = "SPEED,RPM\n"
        static let DATE_FORMAT = "YY-MM-dd HHmm"
        static let EXTENSION = ".csv"
        static let NEWLINE = "\n"
    }
    
    private var _isRecording: Bool = false
    
    var SpeedValues: [Int:Int]?
    var RPMValues: [Int:Int]?
    
    /**
     Zeigt an ob die Aufnahme läuft
    */
    var isRecording: Bool {
        return _isRecording
    }
    
    /**
     Standardinstanz von DataStorage
    */
    static let defaultInstance = DataStorage()
    
    
    /**
     Wertet die Benachrichtigungen aus
     - parameter notification: gesendete Benachrichtigung
    */
    @objc func handleNotificationEvent(notification: NSNotification) {
        if notification.name == NotificationEvents.SpeedValue {
            if SpeedValues != nil {
                if let response = notification.userInfo?[NotificationUserKeys.SpeedValue] as? Int {
                    SpeedValues![SpeedValues!.count] = response
                }
                
            }
        } else if notification.name == NotificationEvents.RPMValue {
            if RPMValues != nil {
                if let response = notification.userInfo?[NotificationUserKeys.RPMValue] as? Int {
                    RPMValues![RPMValues!.count] = response
                }
                
            }
        }
    }
    
    /**
     Exportiert die aktuell aufgenommen Daten in den App Ordner: YYYY-MM-dd HHmm.csv
    */
    func export() {
        guard SpeedValues != nil && RPMValues != nil else {
            return
        }
        let data_speed = SpeedValues!.sort() { $0.0 < $1.0 }
        let data_rpm = RPMValues!.sort() { $0.0 < $1.0 }
        
        var arrSpeed = Array<Int>()
        var arrRpm = Array<Int>()
        
        for (_, value) in data_speed {
            arrSpeed.append(value)
        }
        for (_, value) in data_rpm {
            arrRpm.append(value)
        }
        
        while arrRpm.count < arrSpeed.count {
            arrRpm.append(0)
        }
        while arrSpeed.count < arrRpm.count {
            arrSpeed.append(0)
        }
        var data = CONSTANTS.COLUMN_TITLES
        for i in 0..<arrSpeed.count {
            data += "\(arrSpeed[i]),\(arrRpm[i])\(CONSTANTS.NEWLINE)"
        }
        
        let formatter = NSDateFormatter()
        
        formatter.dateFormat = CONSTANTS.DATE_FORMAT
        
        let filename = formatter.stringFromDate(NSDate())
        
        let documentsPath : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        
        let url: NSURL! = NSURL(fileURLWithPath: "\(documentsPath)").URLByAppendingPathComponent("\(filename)\(CONSTANTS.EXTENSION)")
        do {
            try data.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
        }
    }
    
    /**
     Startet die Aufnahme
    */
    func startRecording() {
        SpeedValues = [Int:Int]()
        RPMValues = [Int:Int]()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataStorage.handleNotificationEvent(_:)), name: NotificationEvents.SpeedValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataStorage.handleNotificationEvent(_:)), name: NotificationEvents.RPMValue, object: nil)
        
        _isRecording = true
        NSNotificationCenter.defaultCenter().postNotificationName(DataRecording.DataRecording, object: nil, userInfo: [DataRecordingUserKeys.State: isRecording])
    }
    
    /**
     Stoppt die Aufnahme
    */
    func stopRecording() {
        _isRecording = false
        NSNotificationCenter.defaultCenter().postNotificationName(DataRecording.DataRecording, object: nil, userInfo: [DataRecordingUserKeys.State: isRecording])
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


struct DataRecording {
    static let DataRecording = "Recording"
}

struct DataRecordingUserKeys {
    static let State = "State"
}