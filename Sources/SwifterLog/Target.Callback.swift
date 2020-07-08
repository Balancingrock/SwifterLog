// =====================================================================================================================
//
//  File:       Target.Callback.swift
//  Project:    SwifterLog
//
//  Version:    2.2.2
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2017-2020 Marinus van der Lugt, All rights reserved.
//
//  License:    MIT, see LICENSE file
//
//  And because I need to make a living:
//
//   - You can send payment (you choose the amount) via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
// PLEASE let me know about bugs, improvements and feature requests. (rien@balancingrock.nl)
// =====================================================================================================================
//
// History
//
// 2.2.2 - Updated LICENSE
// 2.0.1 - Documentation update
// 2.0.0 - New header
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation


/// The protocol for loginfo callback receivers

public protocol CallbackProtocol: AnyObject {
    
    /// Called when log information must be processed by the target.
    ///
    /// - Note: __DO NOT CALL A LOGGING FUNCTION WITHIN A CALLBACK WITH A TARGET INCLUDING THE CALLBACK ITSELF.__ This would create an endless loop.
    ///
    /// - Parameters:
    ///   - time: The time of the logging event.
    ///   - level: The level of the logging event.
    ///   - source: The source of the logging event.
    ///   - message: The message of the logging event.
    
    func logInfo(_ time: Date, _ level: Level, _ source: Source, _ message: Any?)
}


/// The target for a callback destination of log entries. There can be more than one callback target.

public class Callback: Target {

    
    // Send logging messages to callbacks using this queue. This decouples the log messages on this machine from possible application errors.
    
    private var queue: DispatchQueue = DispatchQueue(label: "SwifterLog.Target.Callback", qos: .background, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: .inherit, target: nil)


    // The targets to call back to.
    
    private var callbackTargets: Array<CallbackProtocol> = []

    
    /// Push the logging request onto the callback queue to decouple the logger from possible -bottleneck- constraints in the callback.
    
    public override func process(_ entry: Entry) {
        queue.async {
            [weak self] in
            self?.logToCallback(entry)
        }
    }

    
    // This operation places the actual callback call's
    
    private func logToCallback(_ entry: Entry) {
        for target in callbackTargets {
            target.logInfo(entry.timestamp, entry.level, entry.source, entry.message)
        }
    }

    
    /// Adds the given callback target to the list of callback targets if it is not present in the list yet. Has no effect if the callback target is already present.
    ///
    /// - Parameter target: The callback target to be added.
    
    public func register(_ target: CallbackProtocol) {
        for t in callbackTargets {
            if target === t { return }
        }
        callbackTargets.append(target)
    }
    
    
    /// Removes the given callback target from the list of callback targets. Has no effect if the callback target is not present.
    ///
    /// - Parameter target: The callback target to be removed.
    
    public func remove(_ target: CallbackProtocol) {
        for (index, t) in callbackTargets.enumerated() {
            if target === t { callbackTargets.remove(at: index) }
        }
    }
}
