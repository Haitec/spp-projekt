//
//  ChartViewController.swift
//  Car
//
//  Created by michael on 04.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController {


    @IBAction func exportTouched() {
        DataStorage.defaultInstance.export()
    }
}
