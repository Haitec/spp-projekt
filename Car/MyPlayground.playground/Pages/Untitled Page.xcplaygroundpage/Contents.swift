import Foundation
import UIKit
import obd2communication

let x: SpeedCommand = SpeedCommand()

let y: RPMCommand = RPMCommand()

let echoOff = EchoOffCommand()

let lfOff = LineFeedOffCommand()
let tOut = TimeoutCommand(timeout: 62)
let proto = SelectProtocolCommand(_protocol: ObdProtocols.AUTO)
let reset = ObdResetCommand()

let value = AmbientAirTemperatureCommand()



var inputStream: NSInputStream?
var outputStream: NSOutputStream?
print("test")
NSStream.getStreamsToHostWithName("192.168.0.10", port: 35000, inputStream: &inputStream, outputStream: &outputStream)



if inputStream != nil && outputStream != nil {
    print("connecting")
    inputStream!.open()
    outputStream!.open()
    guard inputStream != nil && outputStream != nil else {
        fatalError("stop")
    }
    print("start running \(inputStream)")
    reset.run(inputStream, out: outputStream)
    echoOff.run(inputStream, out: outputStream)
    //echoOff.run(inputStream, out: outputStream)
    //echoOff.run(inputStream, out: outputStream)
    tOut.run(inputStream, out: outputStream)
    proto.run(inputStream, out: outputStream)
    print("send request")
    y.run(inputStream, out: outputStream)
    if y.Error != nil {
        print("RPM: " + y.Error!.getMessage())
    }
    
    print("RPM: \(y.getRPM())")
    x.run(inputStream, out: outputStream)
    if x.Error != nil {
        print("Speed: " + y.Error!.getMessage())
    }
    print("Speed: \(x.getMetricSpeed())")
    value.run(inputStream, out: outputStream)
    if value.Error != nil {
        print("AmbientAir: " + value.Error!.getMessage())
    }
    //print("\(x.getMetricSpeed())")
    inputStream?.close()
    outputStream?.close()
} else {
    print("Cannot Connect")
}


//print("\(ObdProtocols.AUTO)")

x.getName()
y.getName()
