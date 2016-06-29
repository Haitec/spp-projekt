//: Please build the scheme 'ChartsPlayground' first
import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

import Charts

let view = LineChartView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))

view.backgroundColor = UIColor.whiteColor()

XCPlaygroundPage.currentPage.liveView = view

class tTimer {
    var timer: NSTimer? = nil
    var iCount = 0
    
    var lineChartData: LineChartData? = nil
    
    init () {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(tTimer.update), userInfo: nil, repeats: true)
        
        let dataEntries: [ChartDataEntry] = []
        
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawCubicEnabled = true
        lineChartDataSet.drawSteppedEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        
        lineChartData = LineChartData()
        lineChartData?.dataSets.append(lineChartDataSet)
        
    }
    
    @objc func update() {
        view.data?.addXValue("\(Double(iCount)/8.0)")
        view.data?.dataSets[0].addEntry(ChartDataEntry(value: sin(Double(iCount)/8.0), xIndex: iCount))
        iCount += 1
        if iCount > 500 {
            timer?.invalidate()
        }
        //view.animate(yAxisDuration: 2.0)
        view.notifyDataSetChanged()
        view.setVisibleXRange(minXRange: 0, maxXRange:50)
        view.moveViewToX(CGFloat(iCount-51))
        
    }
}

//view.animate(xAxisDuration: 3.0)

let test = tTimer()

view.drawMarkers = false
let left = view.getAxis(ChartYAxis.AxisDependency.Left)

left.axisMaxValue = 2
left.axisMinValue = -2

left.drawLabelsEnabled = false
left.drawAxisLineEnabled = false
left.drawGridLinesEnabled = false
left.drawZeroLineEnabled = true

view.getAxis(ChartYAxis.AxisDependency.Right).enabled = false // no right axis
view.data = test.lineChartData

view.xAxis.drawGridLinesEnabled = false
view.xAxis.drawLabelsEnabled = false







