//
//  SwifterLogUnitTests.swift
//  SwifterLogUnitTests
//
//  Created by Marinus van der Lugt on 29/05/16.
//  Copyright © 2016 Marinus van der Lugt. All rights reserved.
//

import XCTest

class SwifterLogUnitTests: XCTestCase, SwifterlogCallbackProtocol {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        log.callbackAtAndAboveLevel = SwifterLog.Level.DEBUG
        log.stdoutPrintAtAndAboveLevel = SwifterLog.Level.DEBUG
        log.aslFacilityRecordAtAndAboveLevel = SwifterLog.Level.NONE
        log.networkTransmitAtAndAboveLevel = SwifterLog.Level.NONE
        log.fileRecordAtAndAboveLevel = SwifterLog.Level.NONE
        log.registerCallback(self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // Will be set in callback protocol
    
    var resultMessage: String?
    
    
    // Will be set in callback protocol
    
    var resultLevel: SwifterLog.Level?
    
    
    // Callback protocol
    
    func logInfo(time: NSDate, level: SwifterLog.Level, source: String, message: String) {
        resultLevel = level
        resultMessage = message
    }
    
    
    func testIntLog() {
        
        let i: Int = 6
        
        log.atLevelDebug(source: "", message: i)
        
        sleep(1) // Give the callback some time
        
        XCTAssertEqual(resultMessage, "\(i)")
    }
    
    func testStringLog() {
        
        let str = "any String really"
        
        log.atLevelWarning(source: "", message: str)
        
        sleep(1) // Give the callback some time
        
        XCTAssertEqual(resultMessage, "\(str)")
    }

    func testClassLog() {
        
        class TestClass: ReflectedStringConvertible {
            var a: Int = 5
            var b: String = "B"
        }
        
        let c = TestClass()
        
        log.atLevelInfo(source: "", message: c)
        
        sleep(1) // Give the callback some time
        
        XCTAssertEqual(resultMessage, "\(c)")
    }
    
    func testArrayLog() {
        
        let arr = [1, 2, 3]
        
        log.atLevelInfo(source: "", message: arr)
        
        sleep(1) // Give the callback some time
        
        XCTAssertEqual(resultMessage, "\(arr)")
    }

    func testDictLog() {
        
        let dict = ["MyKey" : 12.34]
        
        log.atLevelInfo(source: "", message: dict)
        
        sleep(1) // Give the callback some time
        
        XCTAssertEqual(resultMessage, "\(dict)")

    }
}
