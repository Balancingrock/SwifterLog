// =====================================================================================================================
//
//  File:       SwifterLogNetwork.swift
//  Project:    SwifterLog
//
//  Version:    0.9.7
//
//  Author:     Marinus van der Lugt
//  Website:    http://www.balancingrock.nl/swifterlog
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Swiftrien/SwifterLog
//
//  Copyright:  (c) 2014-2016 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  I strongly believe that the Non Agression Principle is the way for societies to function optimally. I thus reject
//  the implicit use of force to extract payment. Since I cannot negotiate with you about the price of this code, I
//  have choosen to leave it up to you to determine its price. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  whishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to visit the website/blog/google to ensure that you actually pay me and not some imposter)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// This file adds network destination capabilities to the SwifterLog. However that means that it also needs two
// additional frameworks: SwifterJSON and SwifterSockets. Both are available from balancingrock.nl and hosted on github.
//
// Note that the file SwifterLog.swift contains a couple of definitions for storage and two hooks that are unnecessary
// when this file is not used. Simply remove the hooks and (optionally) the declarations from SwifterLog if you do not
// want to include the swifterJSON and SwifterSockets frameworks.
//
// =====================================================================================================================
//
// History:
//
// v0.9.7   Initial release
//
// =====================================================================================================================

import Foundation


/// The logline as it will be transferred to the network destination

public struct LogLine: CustomStringConvertible {
    
    /// Timestamp of the log entry
    let time: NSDate
    
    /// The loglevel of the log entry
    let level: SwifterLog.Level
    
    /// The source of the log entry
    let source: String
    
    /// The message of the log entry
    let message: String
    
    /// The CustomStringConvertible protocol
    public var description: String { return SwifterLog.logTimeFormatter.stringFromDate(time) + ", " + level.description + ": " + source + ", " + message }
    
    /// Creates a json representation of this struct
    var json: VJson {
        let json = VJson.createJsonHierarchy()
        json["LogLine"]["Time"].stringValue = SwifterLog.logTimeFormatter.stringFromDate(time)
        json["LogLine"]["Level"].integerValue = level.rawValue
        json["LogLine"]["Source"].stringValue = source
        json["LogLine"]["Message"].stringValue = message
        return json
    }
    
    /// Creates a new logline
    init(time: NSDate, level: SwifterLog.Level, source: String, message: String) {
        self.time = time
        self.level = level
        self.source = source
        self.message = message
    }
    
    /// Creates a new logline from the given JSON code, returns nil if this fails.
    init?(json: VJson) {
        
        // Prevent the creation of a "LogLine" object in the json input, first test if it exists
        guard json.objectOfType(VJson.JType.OBJECT, atPath: ["LogLine"]) != nil else { return nil }
        
        guard let jTime = json["LogLine"]["Time"].stringValue else { return nil }
        guard let jLevel = json["LogLine"]["Level"].integerValue else { return nil }
        guard let jSource = json["LogLine"]["Source"].stringValue else { return nil }
        guard let jMessage = json["LogLine"]["Message"].stringValue else { return nil }
        
        guard let dTime = SwifterLog.logTimeFormatter.dateFromString(jTime) else { return nil }
        guard let lLevel = SwifterLog.Level(rawValue: jLevel) else { return nil }
        
        self.time = dTime
        self.level = lLevel
        self.source = jSource
        self.message = jMessage
    }
}


public extension SwifterLog {
    
    
    /// Tries to opens a client connection to the target. Since the connection attempt will take place asynchronously, the feedback by way of the "networkTarget" variable will be delayed. Checking that variable immediately after a return from this function will most likely fail to deliver the actual status.
    
    public func connectToNetworkTarget(target: NetworkTarget) {
        if networkQueue == nil {
            // Only create this queue if necessary, and then do it only once.
            networkQueue = dispatch_queue_create("network-queue", DISPATCH_QUEUE_SERIAL)
        }
        dispatch_async(networkQueue!, { [unowned self] in self.openNetworkConnection(target.address, port: target.port)})
    }
    
    
    /// Closes the connection to the target if it was open. Since the closeing will take place asynchronously, the feedback by way of the "networkTarget" variable will be delayed. Checking that variable immediately after a return from this function will most likely fail to deliver the actual status.
    
    public func closeNetworkTarget() {
        dispatch_async(networkQueue!, { [unowned self] in self.closeNetworkConnection()})
    }

    // Open a network destination
    
    private func openNetworkConnection(ipAddress: String, port: String) {
        
        // If there is an open connection, close that first.
        
        if socket != nil {
            close(socket!)
            socket = nil
            _networkTarget = nil
            self.atLevelNotice(source: NSProcessInfo.processInfo().processName + ".Swifterlog", message: "Connection to network target closed", targets: [.STDOUT, .ASL, .FILE])
        }
        
        
        // Try to open a connection
        
        let result = SwifterSockets.initClient(address: ipAddress, port: port)
        
        switch result {
            
        case let .ERROR(msg):
            
            self.atLevelNotice(source: NSProcessInfo.processInfo().processName + ".Swifterlog", message: "Could not open connection to network target. Address = \(ipAddress), port = \(port), message = \(msg)", targets: [.STDOUT, .ASL, .FILE])
            
            
        case let .SOCKET(num):
            
            socket = num
            _networkTarget = (ipAddress, port)
            self.atLevelNotice(source: NSProcessInfo.processInfo().processName + ".Swifterlog", message: "Openend connection to network target. Address = \(ipAddress), port = \(port)", targets: [.STDOUT, .ASL, .FILE])
        }
    }
    
    
    // Close an existing network destination if there is one
    //
    // It is currently possible for the socket to be closed even if there are still messages beiing transferred.
    // Most likely this is never of any real importance. If this ever becomes a problem, we deal with it then.
    
    private func closeNetworkConnection() {
        
        SwifterSockets.closeSocket(socket)
        socket = nil
        _networkTarget = nil
        self.atLevelNotice(source: NSProcessInfo.processInfo().processName + ".Swifterlog", message: "Network target logging stopped", targets: [.STDOUT, .ASL, .FILE])
    }
    
    
    // Log information to the network destination (or open cq close that connection)
    
    internal func logToNetwork(time: NSDate, source: String, logLevel: Level, message: String) {
        
        
        // Send the log information to a network destination (if there is one)
        
        if socket != nil {
            
            
            // JSON formatted message
            
            let logline = LogLine(time: time, level: logLevel, source: source, message: message)
            
            
            // Try to transmit it. Use a very short timeout because there can be a lot of messages and the connection should be able to handle a fast succession of messages.
            
            let result = SwifterSockets.transmit(socket!, string: logline.json.description, timeout: 0.1, telemetry: nil)
            
            switch result {
                
            case .TIMEOUT:
                
                self.atLevelError(source: NSProcessInfo.processInfo().processName + ".Swifterlog.logToNetwork", message: "Timeout on connection to network target", targets: [.ASL, .FILE, .STDOUT])
                
                
            case let .ERROR(message: err):
                
                self.atLevelError(source: NSProcessInfo.processInfo().processName + ".Swifterlog.logToNetwork", message: "Error on transfer to network target: \(err)", targets: [.ASL, .FILE, .STDOUT])
                self.closeNetworkConnection()
                
                
            case .READY: break
                
            case .CLIENT_CLOSED, .SERVER_CLOSED:
                
                self.atLevelError(source: NSProcessInfo.processInfo().processName + ".Swifterlog.logToNetwork", message: "Connection to network target unexpectedly closed", targets: [.ASL, .FILE, .STDOUT])
                self.closeNetworkConnection()
                
            }
        }
    }
}