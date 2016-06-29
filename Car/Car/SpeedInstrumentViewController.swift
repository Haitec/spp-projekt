//
//  AnalogInstrumentViewController.swift
//  Car
//
//  Created by michael on 03.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit

class SpeedInstrumentViewController: UIViewController, AnalogInstrumentViewDataSource {

    private struct CONSTANTS {
        static let SPEED_STEP_SETTING = "speed_step_preference"
        static let SPEED_SETTING = "speed_preference"
        static let DEFAULT_SPEED = 220
        static let LINES_PER_MARK = 5
        static let LINE_MODULO = 2
    }
    
    var speed: Int = 0 { didSet {
        guard analogView != nil else {
            return
        }
            dispatch_async(dispatch_get_main_queue()) {
                self.analogView.animateArrow()
            }
        }
    }
    
    private var steps: Int = 10
    private var anglePerKmh: CGFloat? = nil
    
    @IBOutlet weak var analogView: AnalogInstrumentView! {
        didSet {
            let stepString = NSUserDefaults.standardUserDefaults().stringForKey(CONSTANTS.SPEED_STEP_SETTING)                   // Laden der Einstellungen für Steps
            if stepString != nil {
                steps = Int(stepString!) ?? steps
            }
            let maxSpeed = NSUserDefaults.standardUserDefaults().stringForKey(CONSTANTS.SPEED_SETTING)                          // Laden der Einstellungen für die maximale Geschwindigkeit
            let maxSpeedInt = Int(maxSpeed ?? "") ?? CONSTANTS.DEFAULT_SPEED
            let bigLine = Double(analogView.stopAngle-analogView.startAngle)/(Double(maxSpeedInt)/Double(steps))                // Berechnen des Winkels für die größeren Linien
            analogView.BigLineIncrease = CGFloat(bigLine)
            analogView.SmallLineIncrease = CGFloat(bigLine/Double(CONSTANTS.LINES_PER_MARK))                                    // Anzahl der kleinen Striche auf 5 pro große Linie
            anglePerKmh = analogView.BigLineIncrease/CGFloat(steps)                                                             // Berechnen des Winkels pro km/h
            analogView.dataSource = self
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SpeedInstrumentViewController.handleNotificationEvent(_:)), name: NotificationEvents.SpeedValue, object: nil)
    }
    
    /**
     Verarbeitet die Notification
     - parameter: die gesendete Notification
    */
    func handleNotificationEvent(notification: NSNotification) {
        if notification.name == NotificationEvents.SpeedValue {
            if let response =  notification.userInfo?[NotificationUserKeys.SpeedValue] as? Int {
                speed = response
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: AnalogInstrumentDataSource
    
    func textForLine(sender: AnalogInstrumentView, LineNumber: Int) -> String? {
        if LineNumber % CONSTANTS.LINE_MODULO == 0 {
            return "\(LineNumber * steps)"
        }
        return ""
    }
    
    func arrowAngle(sender: AnalogInstrumentView) -> CGFloat {
        guard anglePerKmh != nil else {
            return 0.0
        }
        return (CGFloat(speed)*anglePerKmh!)
    }

}
