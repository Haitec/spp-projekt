//
//  TableDataViewController.swift
//  Car
//
//  Created by michael on 24.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit

class TableDataViewController: UITableViewController {

    private struct CONSTANTS {
        static let RPM = "RPM"
        static let SPEED = "Speed"
        static let VIN = "VIN"
        static let ENGINE_COOLANT = "Engine Coolant"
        static let EMPTY = ""
        static let CELLNAME = "DataCell"
        static let CELLGROUPNAME = "Fahrzeugwerte"
        
        static let NUMBERSECTIONS = 1
        static let SECTION1 = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        // Hinzufügen der Benachrichtigungen
        registerNewData(CONSTANTS.RPM, notificationName: NotificationEvents.RPMValue)
        registerNewData(CONSTANTS.SPEED, notificationName: NotificationEvents.SpeedValue)
        registerNewData(CONSTANTS.VIN, notificationName: NotificationEvents.Vin)
        registerNewData(CONSTANTS.ENGINE_COOLANT, notificationName: NotificationEvents.EngineCoolant)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private var values = [String:String]()
    private var titles = [String:String]()
    private var index = Array<String>()
    
    // MARK: Verarbeitung der Benachrichtigungen
    
    /**
     Fügt den Empfang von neuen Benachrichtungen hinzu
     - parameter title: Titel für die Tabelle
     - parameter notificationName: Name der Benachrichtigung
    */
    private func registerNewData(title: String, notificationName: String) {
        values[notificationName] = CONSTANTS.EMPTY
        titles[notificationName] = title
        index.append(notificationName)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableDataViewController.handleNotificationEvent(_:)), name: notificationName, object: nil)

    }
    
    /**
     Aktualisiert den Wert für die Benachrichtigung
     - parameter notificationName: Empfangene Benachrichtigung
     - parameter value: Empfangener Wert durch die Benachrichtigung
    */
    private func newDataReceived(notificationName: String, value: String) {
        values[notificationName] = value
        tableView.reloadData()
    }
    
    /**
     Verarbeitet die Benachrichtigung
     - parameter notification: Empfangene Benachrichtigung
    */
    func handleNotificationEvent(notification: NSNotification) {
        
        
        if (notification.userInfo![NotificationUserKeys.ErrorMessage] as! String) != NotificationUserKeys.ErrorMessageSuccess {
            newDataReceived(notification.name, value: notification.userInfo![NotificationUserKeys.ErrorMessage] as! String)
        } else {
            let arr = Array((notification.userInfo! as! [String:AnyObject]).keys)
            for key in arr {
                if key != NotificationUserKeys.ErrorMessage {
                    newDataReceived(notification.name, value: "\(notification.userInfo![key]!)")
                }
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return CONSTANTS.NUMBERSECTIONS
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == CONSTANTS.SECTION1 {
            return titles.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CONSTANTS.CELLNAME, forIndexPath: indexPath)
        let row = indexPath.row
        // Configure the cell...
        if indexPath.section == CONSTANTS.SECTION1 {
            let name = index[row]
            let title = titles[name]
            let detail = values[name]
            cell.textLabel!.text = title
            cell.detailTextLabel!.text = detail
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == CONSTANTS.SECTION1 {
            return CONSTANTS.CELLGROUPNAME
        }
        
        return nil
    }
}
