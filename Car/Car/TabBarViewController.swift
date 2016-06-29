//
//  TabBarViewController.swift
//  Car
//
//  Created by michael on 04.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    private struct CONSTANTS {
        static let HOST_SETTING = "host_preference"
        static let PORT_SETTING = "port_preference"
        
        static let SETTINGSNAME = "Settings"
        static let SETTINGSTYPE = "bundle"
        static let EMPTY = ""
        static let ERROR_NOT_FOUND = "Could not find Settings.bundle"
        static let SETTINGS_FILENAME = "Root.plist"
        static let PREFERENCE_SPECIFIERS = "PreferenceSpecifiers"
        static let KEY = "Key"
        static let DEFAULT_VALUE = "DefaultValue"
        
        static let ALERT_TITLE = "Verbindung nicht möglich"
        static let ALERT_MESSAGE = "Es kann keine Verbindung aufgebaut werden"
        static let ALERT_CANCEL = "Abbrechen"
        static let ALERT_RETRY = "Wiederholen"
    }
    
    private var dataLoader: PDataLoader? = nil
    private var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(TabBarViewController.update), userInfo: nil, repeats: true)       // Timer für die Kontrolle
        }
        
        registerDefaultsFromSettingsBundle()                                                                                                                        // Lädt die Einstellungen
        let host = NSUserDefaults.standardUserDefaults().stringForKey(CONSTANTS.HOST_SETTING)                                                                       // Einstellung für den Host
        let port = NSUserDefaults.standardUserDefaults().stringForKey(CONSTANTS.PORT_SETTING)                                                                       // Einstellung für den Port
        
        let portInt = Int(port!)
        if dataLoader == nil {
            dataLoader = ObdWifiDataLoader(host: host!, port: portInt!)
            //dataLoader = ExampleDataLoader()
            dataLoader?.begin()
        }
    }
    
    /**
     Lädt die gesetzten Einstellungen aus den iOS Einstellungen
    */
    func registerDefaultsFromSettingsBundle() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.synchronize()
        
        let settingsBundle: NSString = NSBundle.mainBundle().pathForResource(CONSTANTS.SETTINGSNAME, ofType: CONSTANTS.SETTINGSTYPE)!
        
        if(settingsBundle.containsString(CONSTANTS.EMPTY)){
            NSLog(CONSTANTS.ERROR_NOT_FOUND);
            return;
        }
        
        let settings = NSDictionary(contentsOfFile: settingsBundle.stringByAppendingPathComponent(CONSTANTS.SETTINGS_FILENAME))!
        let preferences = settings.objectForKey(CONSTANTS.PREFERENCE_SPECIFIERS) as! NSArray;
        
        var defaultsToRegister = [String: AnyObject](minimumCapacity: preferences.count);
        
        for prefSpecification in preferences { if (prefSpecification.objectForKey(CONSTANTS.KEY) != nil) {
            let key = prefSpecification.objectForKey(CONSTANTS.KEY)! as! String
            
            if !key.containsString(CONSTANTS.EMPTY) {
                let currentObject = defaults.objectForKey(key)
                if currentObject == nil {
                    
                    let objectToSet = prefSpecification.objectForKey(CONSTANTS.DEFAULT_VALUE)
                    defaultsToRegister[key] = objectToSet!
                }
            }
            }
        }
        
        defaults.registerDefaults(defaultsToRegister)
        defaults.synchronize()
    }
    
    /**
     Funktion zur Überprüfung ob eine Verbindung zum Auto besteht
    */
    func update() {
        self.timer!.invalidate()
        if !dataLoader!.running() {
            let alertController = UIAlertController(title: CONSTANTS.ALERT_TITLE, message: CONSTANTS.ALERT_MESSAGE, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: CONSTANTS.ALERT_CANCEL, style: .Cancel) { (action) in
                self.dataLoader!.stop()
                
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: CONSTANTS.ALERT_RETRY, style: .Default) { (action) in
                self.dataLoader!.stop()
                self.dataLoader!.begin()
                self.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(TabBarViewController.update), userInfo: nil, repeats: true)
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
            
        }
        return
    }
    
    deinit {
        dataLoader!.stop()
    }
}
