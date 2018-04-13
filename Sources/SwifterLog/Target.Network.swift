// =====================================================================================================================
//
//  File:       Target.Network.swift
//  Project:    SwifterLog
//
//  Version:    1.1.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2017 Marinus van der Lugt, All rights reserved.
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
//  I strongly believe that voluntarism is the way for societies to function optimally. Thus I have choosen to leave it
//  up to you to determine the price for this code. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you can also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
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
// Purpose:
//
// Writes the log entries to a remote server.
//
// =====================================================================================================================
//
// History:
// 1.1.0 -  Initial release in preperation for v2.0.0
//
// =====================================================================================================================

#if SWIFTERLOG_DISABLE_NETWORK_TARGET
#else

import Foundation
import VJson
import SwifterSockets


/// The logline as it will be transferred to the network destination

public struct LogLine: CustomStringConvertible {
    
    
    /// Timestamp of the log entry
    
    public let time: Date
    
    
    /// The loglevel of the log entry
    
    public let level: Level
    
    
    /// The source of the log entry
    
    public let source: Source
    
    
    /// The message of the log entry
    
    public let message: Any?
    
    
    /// The CustomStringConvertible protocol
    
    public var description: String { return "\(logTimeFormatter.string(from: time)), \(level): \(source), \(message ?? "")" }
    
    
    /// The json representation of this struct
    
    public var json: VJson {
        let json = VJson()
        json["LogLine"]["Time"] &= logTimeFormatter.string(from: time)
        json["LogLine"]["Level"] &= level.json
        json["LogLine"]["Source"] &= source.json
        json["LogLine"]["Message"] &= "\(message ?? "")"
        return json
    }
    
    
    /// Creates a new logline
    
    public init(_ entry: Entry) {
        self.time = entry.timestamp
        self.level = entry.level
        self.source = entry.source
        self.message = entry.message
    }
    
    
    /// Creates a new logline from the given JSON code, returns nil if this fails.
    
    public init?(json: VJson?) {
        
        guard let json = json else { return nil }
        
        guard let jTime = (json|"LogLine"|"Time")?.stringValue else { return nil }
        guard let jLevel = (json|"LogLine"|"Level") else { return nil }
        guard let jSource = (json|"LogLine"|"Source") else { return nil }
        guard let jMessage = (json|"LogLine"|"Message")?.stringValue else { return nil }
        
        guard let dTime = logTimeFormatter.date(from: jTime) else { return nil }
        guard let lLevel = Level.factory(jLevel) else { return nil }
        guard let sSource = Source(json: jSource) else { return nil }
        
        self.time = dTime
        self.level = lLevel
        self.source = sSource
        self.message = jMessage
    }
}


public class Network: Target {
    
    
    // Send logging messages to a network destination using this. This decouples the log messages on this machine from the traffic conditions to another machine.
    
    private var networkQueue: DispatchQueue?

    
    /// Transmit a new entry if the level and filter let is pass.
    
    public override func process(_ entry: Entry) {
        
        // Dispatch it so a blocked network does not impact the application or SwifterLog.
        
        networkQueue?.async {
            [weak self] in
            self?.logToNetwork(entry)
        }
    }
    
    
    /// Associates a tuple with a network destination.
    
    public typealias NetworkTarget = (address: String, port: String)
    
    
    /// The most recent value of the network target that was set using the function "connectToNetworkTarget".
    ///
    /// Will be nil if the target is unreachable or once a "closeNetworkTarget" was executed.
    ///
    /// - Note: There will be a delay between calling connectToNetworkTarget and closeNetworkTarget and the updating of this variable. Thus checking this variable immediately after a return from either function will most likely fail to deliver the actual status.
    
    public var networkTarget: NetworkTarget? { return _networkTarget }
    
    private var _networkTarget: NetworkTarget?

    
    // The socket for the network target
    
    private var socket: Int32?

    
    /// Tries to opens a client connection to the target. Since the connection attempt will take place asynchronously, the feedback by way of the "networkTarget" variable will be delayed. Checking that variable immediately after a return from this function will most likely fail to deliver the actual status.
    ///
    /// - Parameter target: The network ip address and port number to use.
    
    public func connectToNetworkTarget(_ target: NetworkTarget) {
        if networkQueue == nil {
            // Only create this queue if necessary, and then do it only once.
            networkQueue = DispatchQueue(label: "SwifterLog-Network")
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
            _ = SwifterSockets.closeSocket(socket!)
            socket = nil
            _networkTarget = nil
            Logger.OptionalLogger.atNotice.log("Connection to network target closed", from: Source(file: #file, function: #function, line: #line), to: Logger.allTargetsExceptNetwork)
        }
        
        
        // Try to open a connection
        
        let result = SwifterSockets.connectToTipServer(atAddress: ipAddress, atPort: port)
        
        switch result {
            
        case let .error(msg):
            
            Logger.OptionalLogger.atNotice.log("Could not open connection to network target. Address = \(ipAddress), port = \(port), message = \(msg)", from: Source(file: #file, function: #function, line: #line), to: Logger.allTargetsExceptNetwork)
            
            
        case let .success(num):
            
            socket = num
            _networkTarget = (ipAddress, port)
            Logger.OptionalLogger.atNotice.log("Openend connection to network target. Address = \(ipAddress), port = \(port)", from: Source(file: #file, function: #function, line: #line), to: Logger.allTargetsExceptNetwork)
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
        Logger.OptionalLogger.atNotice.log("Network target logging stopped", from: Source(file: #file, function: #function, line: #line), to: Logger.allTargetsExceptNetwork)
    }
    
    
    // Log information to the network destination (or open cq close that connection)
    
    internal func logToNetwork(_ entry: Entry) {
        
        
        // Send the log information to a network destination (if there is one)
        
        if socket != nil {
            
            
            // JSON formatted message
            
            let logline = LogLine(entry)
            
            
            // Try to transmit it. Use a very short timeout because there can be a lot of messages and the connection should be able to handle a fast succession of messages.
            
            let result = SwifterSockets.tipTransfer(socket: socket!, string: logline.json.description, timeout: 0.1)
            
            switch result {
                
            case .timeout:
                
                Logger.OptionalLogger.atError.log("Timeout on connection to network target", from: Source(file: #file, function: #function, line: #line), to: Logger.allTargetsExceptNetwork)
                
                
            case let .error(message: err):
                
                Logger.OptionalLogger.atError.log("Error on transfer to network target: \(err)", from: Source(file: #file, function: #function, line: #line), to: Logger.allTargetsExceptNetwork)
                self.closeNetworkConnection()
                
                
            case .ready, .queued: break
                
            case .closed:
                
                Logger.OptionalLogger.atError.log("Connection to network target unexpectedly closed", from: Source(file: #file, function: #function, line: #line), to: Logger.allTargetsExceptNetwork)
                self.closeNetworkConnection()
            }
        }
    }
}

#endif
