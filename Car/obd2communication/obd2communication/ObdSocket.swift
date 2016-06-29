//
//  obdSocket.swift
//  obd2communication
//
//  Created by michael on 25.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

public protocol ObdSocketDelegate {
    func connected(didConnected: Bool)
}

/**
 Socket für die synchrone OBD2 Kommunikation
*/
public class ObdSocket : GCDAsyncSocketDelegate {
    private struct CONSTANTS {
        static let TIMEOUT_INFINITE = -1.0
        static let BUFFER_OFFSET = 0
        static let DEFAULT_TAG = 0
        
        static let CONNECT_TIMEOUT = 5
    }
    private let sem = Semaphore(value: 0)
    private let semConnected = Semaphore(value: 0)
    public var socket:GCDAsyncSocket! = nil
    public var delegate: ObdSocketDelegate?
    
    public init() {
        
    }
    
    /**
     Schliesst die Verbindung
    */
    public func close() {
        
        socket.disconnect()
    }
    
    /**
     Liest einen String bis zum erscheinen des Charakters.
     - parameter character: String welcher enthalten sein muss
     - parameter timeOutSeconds: Timeout wie lange versucht werden soll Daten zu lesen
    */
    func readUntilCharacterOccured(character: String, timeOutSeconds: Double) -> String? {
        let recv = NSMutableData()
        while true {
            let data = NSMutableData()
            socket.readDataWithTimeout(NSTimeInterval(CONSTANTS.TIMEOUT_INFINITE), buffer: data, bufferOffset: UInt(CONSTANTS.BUFFER_OFFSET), tag: CONSTANTS.DEFAULT_TAG)
            if sem.wait(Int64(timeOutSeconds) * Int64(NSEC_PER_SEC)) {
                return nil
            }
            recv.appendData(data)
            let str = String(data: recv, encoding: NSUTF8StringEncoding)
            if str!.containsString(character) {
                return str!
            }
        }
    }
    
    /**
     Versucht eine Verbindung aufzubauen
     - parameter host: zu verbindender Host
     - parameter port: zu verwendender Port
    */
    public func setupConnection(host: String, port: UInt16) {
        
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0))
        do {
            try self.socket!.connectToHost(host, onPort: port, withTimeout: NSTimeInterval(CONSTANTS.CONNECT_TIMEOUT))
        }
        catch {
            print("oops")
        }
        //semConnected.wait()
    }
    
    /**
     wird aufgerufen wenn die Verbindung aufgebaut wurde, oder ein Fehler eingetreten ist
    */
    @objc public func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16) {
        
        print("Connected to \(host) on port \(p).")
        
        self.socket = socket
        
        semConnected.signal()
        if delegate != nil {
            delegate?.connected(socket.isConnected)
        }
    }
    
    /**
     Sendet eine Nachricht
     - parameter msg: String der Nachricht
    */
    public func send(msg: String) {
        let data = Array<UInt8>(msg.utf8)
        send(data)
    }
    
    /**
     Sendet eine Nachricht
     - parameter msgBytes: [UInt8] der Nachricht
     */
    public func send(msgBytes: [UInt8]) {
        
        let msgData = NSData(bytes: msgBytes, length: msgBytes.count)
        socket.writeData(msgData, withTimeout: NSTimeInterval(CONSTANTS.CONNECT_TIMEOUT), tag: CONSTANTS.DEFAULT_TAG)
    }
    
    /**
     wird aufgerufen wenn Daten gelesen wurden
    */
    @objc public func socket(socket : GCDAsyncSocket!, didReadData data:NSData!, withTag tag:Int){
        sem.signal()
        
    }
}

struct Semaphore {
    
    let semaphore: dispatch_semaphore_t
    
    init(value: Int = 0) {
        semaphore = dispatch_semaphore_create(value)
    }
    
    // Blocks the thread until the semaphore is free and returns true
    // or until the timeout passes and returns false
    func wait(nanosecondTimeout: Int64) -> Bool {
        return dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, nanosecondTimeout)) != 0
    }
    
    // Blocks the thread until the semaphore is free
    func wait() {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    // Alerts the semaphore that it is no longer being held by the current thread
    // and returns a boolean indicating whether another thread was woken
    func signal() -> Bool {
        return dispatch_semaphore_signal(semaphore) != 0
    }
}