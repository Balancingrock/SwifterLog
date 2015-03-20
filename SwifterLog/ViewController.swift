//
//  ViewController.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 20/03/15.
//  Copyright (c) 2015 Marinus van der Lugt. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        log.logfileMaxSizeInBytes = 1024
        log.logfileMaxNumberOfFiles = 5
        
        log.aslFacilityRecordAtAndAboveLevel = SwifterLog.Level.DEBUG
        log.logfileRecordAtAndAboveLevel = SwifterLog.Level.DEBUG
        log.stdoutPrintAtAndAboveLevel = SwifterLog.Level.DEBUG
        
        log.atLevelDebug(id: 0, source: "SwifterLog", message: "message debug")
        log.atLevelInfo(id: 1, source: "SwifterLog", message: "message info")
        log.atLevelNotice(id: 2, source: "SwifterLog", message: "message notice")
        log.atLevelWarning(id: 3, source: "SwifterLog", message: "message warning")
        log.atLevelError(id: 4, source: "SwifterLog", message: "message error")
        log.atLevelCritical(id: 5, source: "SwifterLog", message: "message critical")
        log.atLevelAlert(id: 6, source: "SwifterLog", message: "message alert")
        log.atLevelEmergency(id: 7, source: "SwifterLog", message: "message emergency")
        
        log.aslFacilityRecordAtAndAboveLevel = SwifterLog.Level.WARNING
        log.logfileRecordAtAndAboveLevel = SwifterLog.Level.WARNING
        log.stdoutPrintAtAndAboveLevel = SwifterLog.Level.WARNING
        
        log.atLevelDebug(id: 0, source: "SwifterLog", message: "should not see this: message debug")
        log.atLevelInfo(id: 1, source: "SwifterLog", message: "should not see this: message info")
        log.atLevelNotice(id: 2, source: "SwifterLog", message: "should not see this: message notice")
        log.atLevelWarning(id: 3, source: "SwifterLog", message: "message warning")
        log.atLevelError(id: 4, source: "SwifterLog", message: "message error")
        log.atLevelCritical(id: 5, source: "SwifterLog", message: "message critical")
        log.atLevelAlert(id: 6, source: "SwifterLog", message: "message alert")
        log.atLevelEmergency(id: 7, source: "SwifterLog", message: "message emergency")
        
        log.aslFacilityRecordAtAndAboveLevel = SwifterLog.Level.NONE
        log.stdoutPrintAtAndAboveLevel = SwifterLog.Level.NONE
        log.logfileRecordAtAndAboveLevel = SwifterLog.Level.DEBUG
        
        for i in 1 ... 5000 {
            log.atLevelCritical(id: 5, source: "SwifterLog", message: "message critical \(i)")
        }

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
            
        }
    }


}

