//
//  Target.Network.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 30/07/2017.
//
//

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
    
    public init(time: Date, level: Level, source: Source, message: String) {
        self.time = time
        self.level = level
        self.source = source
        self.message = message
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
    
    public override func log(_ level: Level, _ source: Source, _ message: Any? = nil, _ timestamp: Date? = nil) {
        
        
        // Message must be at or above threshold
        
        if level >= threshold { return }
        
        
        // Prevent unwanted sources from creating an entry
        
        for filter in filters {
            if filter.excludes(level, source) { return }
        }
        
        
        // Increment the counter
        
        counters[level.value] += 1
        
        
        // Set the date for the entry
        
        let date = timestamp ?? Date()
        
        
        // Dispatch it so a blocked network does not impact the application.
        
        networkQueue?.async {
            [weak self] in
            self?.logToNetwork(date, source: source, logLevel: level, message: message)
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
            SwifterLog.Loggers.atNotice.log(from: Source(file: #file, function: #function, line: #line), to: SwifterLog.allTargetsExceptNetwork, message: "Connection to network target closed")
        }
        
        
        // Try to open a connection
        
        let result = SwifterSockets.connectToTipServer(atAddress: ipAddress, atPort: port)
        
        switch result {
            
        case let .error(msg):
            
            SwifterLog.Loggers.atNotice.log(from: Source(file: #file, function: #function, line: #line), to: SwifterLog.allTargetsExceptNetwork, message: "Could not open connection to network target. Address = \(ipAddress), port = \(port), message = \(msg)")
            
            
        case let .success(num):
            
            socket = num
            _networkTarget = (ipAddress, port)
            SwifterLog.Loggers.atNotice.log(from: Source(file: #file, function: #function, line: #line), to: SwifterLog.allTargetsExceptNetwork, message: "Openend connection to network target. Address = \(ipAddress), port = \(port)")
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
        SwifterLog.Loggers.atNotice.log(from: Source(file: #file, function: #function, line: #line), to: SwifterLog.allTargetsExceptNetwork, message: "Network target logging stopped")
    }
    
    
    // Log information to the network destination (or open cq close that connection)
    
    internal func logToNetwork(_ time: Date, source: Source, logLevel: Level, message: Any?) {
        
        
        // Send the log information to a network destination (if there is one)
        
        if socket != nil {
            
            
            // JSON formatted message
            
            let logline = LogLine(time: time, level: logLevel, source: source, message: "\(message ?? "")")
            
            
            // Try to transmit it. Use a very short timeout because there can be a lot of messages and the connection should be able to handle a fast succession of messages.
            
            let result = SwifterSockets.tipTransfer(socket: socket!, string: logline.json.description, timeout: 0.1)
            
            switch result {
                
            case .timeout:
                
                SwifterLog.Loggers.atError.log(from: Source(file: #file, function: #function, line: #line), to: SwifterLog.allTargetsExceptNetwork, message: "Timeout on connection to network target")
                
                
            case let .error(message: err):
                
                SwifterLog.Loggers.atError.log(from: Source(file: #file, function: #function, line: #line), to: SwifterLog.allTargetsExceptNetwork, message: "Error on transfer to network target: \(err)")
                self.closeNetworkConnection()
                
                
            case .ready, .queued: break
                
            case .closed:
                
                SwifterLog.Loggers.atError.log(from: Source(file: #file, function: #function, line: #line), to: SwifterLog.allTargetsExceptNetwork, message: "Connection to network target unexpectedly closed")
                self.closeNetworkConnection()
            }
        }
    }
}

#endif
