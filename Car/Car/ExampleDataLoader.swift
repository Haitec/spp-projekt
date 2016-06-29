//
//  ExampleDataLoader.swift
//  Car
//
//  Created by michael on 04.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import Foundation
import Darwin

class ExampleDataLoader: PDataLoader {
    
    private var timer: NSTimer? = nil
    private var value = 750.0
    private var increase = 0.001
    private var test = false
    
    var delegate: PDataLoaderDelegate?
    
    func running() -> Bool {
        return true
    }
    
    func begin() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(ExampleDataLoader.update), userInfo: nil, repeats: true)
    }
    func stop() {
        guard timer != nil else {
            return
        }
        timer!.invalidate()
    }
    
    @objc func update() {
        if value < 400 {
            value = 400
            increase = 0.001
        }
        let RPMValue = test ? 800+(random() % 500) : 0
        let SpeedValue = Int((Double(100)/Double(1800)) * Double(RPMValue))
        
        test = !test
        
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationEvents.RPMValue, object: nil, userInfo: [NotificationUserKeys.RPMValue: RPMValue, NotificationUserKeys.ErrorMessage: NotificationUserKeys.ErrorMessageSuccess])
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationEvents.SpeedValue, object: nil, userInfo: [NotificationUserKeys.SpeedValue: SpeedValue, NotificationUserKeys.ErrorMessage: NotificationUserKeys.ErrorMessageSuccess])
        //value += sin(Double(increase))
        //increase += increase
    }
}