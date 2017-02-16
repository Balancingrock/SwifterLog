// =====================================================================================================================
//
//  File:       SwifterLog.Network.swift
//  Project:    SwifterLog
//
//  Version:    0.9.19
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/pages/projects/swifterlog/
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
// 0.9.19  - Added new enum to transmission to network.
// 0.9.13  - Upgraded to Xcode 8 beta 6 (Swift 3)
// 0.9.12  - Upgraded to Xcode 8 beta 3 (Swift 3)
// 0.9.11  - Updated for VJson 0.9.8
// 0.9.10  - Small update to accomodate VJson updates
// 0.9.8   - Header update
//         - Renamed to SwifterLog.Network.swift
// 0.9.7   - Initial release
//
// =====================================================================================================================

#if SWIFTERLOG_DISABLE_NETWORK_TARGET
#else

import Foundation
import SwifterJSON
import SwifterSockets


/// The logline as it will be transferred to the network destination

public struct LogLine: CustomStringConvertible {
    
    
    /// Timestamp of the log entry
    
    public let time: Date
    
    
    /// The loglevel of the log entry
    
    public let level: SwifterLog.Level
    
    
    /// The source of the log entry
    
    public let source: String
    
    
    /// The message of the log entry
    
    public let message: String
    
    
    /// The CustomStringConvertible protocol
    
    public var description: String { return SwifterLog.logTimeFormatter.string(from: time) + ", " + level.description + ": " + source + ", " + message }
    
    
    /// The json representation of this struct
    
    public var json: VJson {
        let json = VJson()
        json["LogLine"]["Time"] &= SwifterLog.logTimeFormatter.string(from: time)
        json["LogLine"]["Level"] &= level.rawValue
        json["LogLine"]["Source"] &= source
        json["LogLine"]["Message"] &= message
        return json
    }
    
    
    /// Creates a new logline
    
    public init(time: Date, level: SwifterLog.Level, source: String, message: String) {
        self.time = time
        self.level = level
        self.source = source
        self.message = message
    }
    
    
    /// Creates a new logline from the given JSON code, returns nil if this fails.
    
    public init?(json: VJson?) {
        
        guard let json = json else { return nil }
        
        guard let jTime = (json|"LogLine"|"Time")?.stringValue else { return nil }
        guard let jLevel = (json|"LogLine"|"Level")?.intValue else { return nil }
        guard let jSource = (json|"LogLine"|"Source")?.stringValue else { return nil }
        guard let jMessage = (json|"LogLine"|"Message")?.stringValue else { return nil }
        
        guard let dTime = SwifterLog.logTimeFormatter.date(from: jTime) else { return nil }
        guard let lLevel = SwifterLog.Level(rawValue: jLevel) else { return nil }
        
        self.time = dTime
        self.level = lLevel
        self.source = jSource
        self.message = jMessage
    }
}


/// SwifterLog extension for the networking target.

public extension SwifterLog {
    
    
    /// Tries to opens a client connection to the target. Since the connection attempt will take place asynchronously, the feedback by way of the "networkTarget" variable will be delayed. Checking that variable immediately after a return from this function will most likely fail to deliver the actual status.
    ///
    /// - Parameter target: The network ip address and port number to use.
    
    public func connectToNetworkTarget(_ target: NetworkTarget) {
        if networkQueue == nil {
            // Only create this queue if necessary, and then do it only once.
            networkQueue = DispatchQueue(label: "network-queue")
        }
        networkQueue!.async(execute: { [unowned self] in self.openNetworkConnection(target.address, port: target.port)})
    }
    
    
    /// Closes the connection to the target if it was open. Since the closeing will take place asynchronously, the feedback by way of the "networkTarget" variable will be delayed. Checking that variable immediately after a return from this function will most likely fail to deliver the actual status.
    
    public func closeNetworkTarget() {
        networkQueue!.async(execute: { [unowned self] in self.closeNetworkConnection()})
    }

    
    // Open a network destination
    
    private func openNetworkConnection(_ ipAddress: String, port: String) {
        
        // If there is an open connection, close that first.
        
        if socket != nil {
            close(socket!)
            socket = nil
            _networkTarget = nil
            self.atLevelNotice(source: ProcessInfo.processInfo.processName + ".Swifterlog", message: "Connection to network target closed", targets: [.stdout, .asl, .file])
        }
        
        
        // Try to open a connection
        
        let result = SwifterSockets.connectToTipServer(atAddress: ipAddress, atPort: port)
        
        switch result {
            
        case let .error(msg):
            
            self.atLevelNotice(source: ProcessInfo.processInfo.processName + ".Swifterlog", message: "Could not open connection to network target. Address = \(ipAddress), port = \(port), message = \(msg)", targets: [.stdout, .asl, .file])
            
            
        case let .success(num):
            
            socket = num
            _networkTarget = (ipAddress, port)
            self.atLevelNotice(source: ProcessInfo.processInfo.processName + ".Swifterlog", message: "Openend connection to network target. Address = \(ipAddress), port = \(port)", targets: [.stdout, .asl, .file])
        }
    }
    
    
    // Close an existing network destination if there is one
    //
    // It is currently possible for the socket to be closed even if there are still messages beiing transferred.
    // Most likely this is never of any real importance. If this ever becomes a problem, we deal with it then.
    
    private func closeNetworkConnection() {
        
        _ = SwifterSockets.closeSocket(socket)
        socket = nil
        _networkTarget = nil
        self.atLevelNotice(source: ProcessInfo.processInfo.processName + ".Swifterlog", message: "Network target logging stopped", targets: [.stdout, .asl, .file])
    }
    
    
    // Log information to the network destination (or open cq close that connection)
    
    internal func logToNetwork(_ time: Date, source: String, logLevel: Level, message: String) {
        
        
        // Send the log information to a network destination (if there is one)
        
        if socket != nil {
            
            
            // JSON formatted message
            
            let logline = LogLine(time: time, level: logLevel, source: source, message: message)
            
            
            // Try to transmit it. Use a very short timeout because there can be a lot of messages and the connection should be able to handle a fast succession of messages.
            
            let result = SwifterSockets.tipTransfer(socket: socket!, string: logline.json.description, timeout: 0.1)
            
            switch result {
                
            case .timeout:
                
                self.atLevelError(source: ProcessInfo.processInfo.processName + ".Swifterlog.logToNetwork", message: "Timeout on connection to network target", targets: [.asl, .file, .stdout])
                
                
            case let .error(message: err):
                
                self.atLevelError(source: ProcessInfo.processInfo.processName + ".Swifterlog.logToNetwork", message: "Error on transfer to network target: \(err)", targets: [.asl, .file, .stdout])
                self.closeNetworkConnection()
                
                
            case .ready, .queued: break
                
            case .closed:
                
                self.atLevelError(source: ProcessInfo.processInfo.processName + ".Swifterlog.logToNetwork", message: "Connection to network target unexpectedly closed", targets: [.asl, .file, .stdout])
                self.closeNetworkConnection()
                
            }
        }
    }
}
    
#endif
