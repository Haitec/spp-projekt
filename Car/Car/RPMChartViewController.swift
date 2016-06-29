//
//  RPMChartViewController.swift
//  Car
//
//  Created by michael on 05.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit
import Charts

class RPMChartViewController: UIViewController {
    
    private struct CONSTANTS {
        static let LABEL = "RPM"
    }
    
    @IBOutlet weak var lineChartView: LineChartView! {
        didSet {
            initLineChart()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RPMChartViewController.handleNotificationEvent(_:)), name: NotificationEvents.RPMValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RPMChartViewController.handleDataRecordingNotification(_:)), name: DataRecording.DataRecording, object: nil)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: LineChart Funktionen
    
    /**
     Initialisiert das ChartView
     */
    private func initLineChart() {
        guard lineChartView != nil else {
            return
        }
        var dataEntries: [ChartDataEntry] = []
        
        var xVals: [String] = []
        if DataStorage.defaultInstance.RPMValues != nil {
            var i = 0
            let data = DataStorage.defaultInstance.RPMValues!.sort() { $0.0 < $1.0 }                                //muss sortiert werden, da sonst die Daten undefiniert geladen werden
            for (key, value) in data {
                print("\(key): \(value)")
                dataEntries.append(ChartDataEntry(value: Double(value), xIndex: key))
                i += 1
                xVals.append("\(i)")
            }
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: CONSTANTS.LABEL)
        
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawCubicEnabled = true
        lineChartDataSet.drawSteppedEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.lineWidth = 3
        lineChartDataSet.colors[0] = UIColor.orangeColor()
        
        let lineChartData = LineChartData(xVals: xVals, dataSets: [lineChartDataSet])
        
        lineChartView.data = lineChartData
        
        let YAxisLeft = lineChartView.getAxis(ChartYAxis.AxisDependency.Left)
        lineChartView.xAxis.drawGridLinesEnabled = true
        lineChartView.xAxis.drawLabelsEnabled = true
        
        lineChartView.xAxis.setLabelsToSkip(500)
        
        YAxisLeft.drawLabelsEnabled = true
        YAxisLeft.drawAxisLineEnabled = false
        YAxisLeft.drawGridLinesEnabled = true
        YAxisLeft.drawZeroLineEnabled = true
        
        lineChartView.getAxis(ChartYAxis.AxisDependency.Right).enabled = false
    }
    
    // MARK: Benachrichtigungsfunktionen
    
    /**
     Verarbeitet die Benachrichtigungen ob die Aufnahme läuft
     - parameter notification: gesendete Benachrichtigung
     */
    func handleDataRecordingNotification(notification: NSNotification) {
        guard lineChartView != nil && DataStorage.defaultInstance.isRecording else {
            return
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
        initLineChart()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RPMChartViewController.handleNotificationEvent(_:)), name: NotificationEvents.RPMValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RPMChartViewController.handleDataRecordingNotification(_:)), name: DataRecording.DataRecording, object: nil)
    }
    
    /**
     Verarbeitet die Benachrichtigungen über ein neuen Wert
     - parameter notification: gesendete Benachrichtigung
     */
    func handleNotificationEvent(notification: NSNotification) {
        guard lineChartView?.lineData != nil  && DataStorage.defaultInstance.isRecording else {
            return
        }
        if notification.name == NotificationEvents.RPMValue {
            if let response =  notification.userInfo?[NotificationUserKeys.RPMValue] as? Int {
                lineChartView.lineData?.dataSets[0].addEntry(ChartDataEntry(value: Double(response), xIndex: lineChartView.lineData!.dataSets[0].entryCount))
                lineChartView.lineData?.addXValue("\(lineChartView.lineData!.dataSets[0].entryCount)")
                lineChartView.lineData?.dataSets[0].calcMinMax(start: 0, end: lineChartView.lineData!.dataSets[0].entryCount-1)
                lineChartView.leftAxis.resetCustomAxisMax()
                lineChartView.getAxis(ChartYAxis.AxisDependency.Left).calcMinMax(min: 0, max: lineChartView.lineData!.dataSets[0].yMax)
                lineChartView.leftAxis.axisMaxValue = lineChartView.chartYMax
                lineChartView.leftAxis.axisMinValue = -5
                
                lineChartView.notifyDataSetChanged()
            }
        }
    }
}
