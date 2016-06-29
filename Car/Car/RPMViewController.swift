//
//  RPMViewController.swift
//  Car
//
//  Created by michael on 03.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit

class RPMViewController: UIViewController, AnalogInstrumentViewDataSource {
    
    private struct CONSTANTS {
        static let TEXTFIELD = "x 1000 RPM"
        static let SCALEFACTOR = 1000
        static let LINES_PER_MARK = 5
        
        static let RPM_SETTING = "rpm_preference"
        static let RED_RPM_SETTING = "red_rpm_preference"
    }
    
    private var anglePerRpm: CGFloat? = nil
    private var steps: CGFloat = 0.5
    private var RPMValue: Int = 0 { didSet {
        guard analogView != nil else {
            return
        }
            dispatch_async(dispatch_get_main_queue()) {
                self.analogView.animateArrow()
            }
        }
    }
    
    @IBOutlet weak var analogView: AnalogInstrumentView! {
        didSet {
            // Anmerkungen: SpeedInstrumentViewController.analogView
            let maxSpeed = NSUserDefaults.standardUserDefaults().stringForKey(CONSTANTS.RPM_SETTING)
            let maxSpeedInt = Int(maxSpeed!)!
            let bigLine = Double(analogView.stopDangerAngle-analogView.startAngle)/(Double(maxSpeedInt)/Double(steps*CGFloat(CONSTANTS.SCALEFACTOR)))
            analogView.BigLineIncrease = CGFloat(bigLine)
            analogView.SmallLineIncrease = CGFloat(bigLine/Double(CONSTANTS.LINES_PER_MARK))
            analogView.dataSource = self
            analogView.text = CONSTANTS.TEXTFIELD
            anglePerRpm = analogView.BigLineIncrease/CGFloat(steps*CGFloat(CONSTANTS.SCALEFACTOR))
            let redStart = Double(anglePerRpm!) * (Double(NSUserDefaults.standardUserDefaults().stringForKey(CONSTANTS.RED_RPM_SETTING) ?? "") ?? Double(analogView.stopAngle))
            analogView.startDangerAngle = CGFloat(redStart) + analogView.startAngle
            analogView.stopAngle = analogView.startDangerAngle
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RPMViewController.handleNotificationEvent(_:)), name: NotificationEvents.RPMValue, object: nil)
    }
    
    func handleNotificationEvent(notification: NSNotification) {
        if notification.name == NotificationEvents.RPMValue {
            if let response =  notification.userInfo?[NotificationUserKeys.RPMValue] as? Int {
                RPMValue = response
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: AnalogInstrumentDataSource

    func textForLine(sender: AnalogInstrumentView, LineNumber: Int) -> String? {
        if fmod(Double(steps)*Double(LineNumber), 1) == 0 {                        // Entfernen der .0 bei ganzen Zahlen
            //return "\(Int(steps)*LineNumber)"
            return "\(Int(Double(steps)*Double(LineNumber)))"
        }
        return ""
        //return "\(steps*CGFloat(LineNumber))"
    }
    func arrowAngle(sender: AnalogInstrumentView) -> CGFloat {
        guard anglePerRpm != nil else {
            return 0.0
        }
        return anglePerRpm! * CGFloat(RPMValue)
    }

}
