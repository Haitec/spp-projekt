//
//  RecordViewController.swift
//  Car
//
//  Created by michael on 05.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {

    @IBAction func recordSwitchChanged(sender: UISwitch) {
        if sender.on {
            DataStorage.defaultInstance.startRecording()
        } else {
            DataStorage.defaultInstance.stopRecording()
        }
    }
}
