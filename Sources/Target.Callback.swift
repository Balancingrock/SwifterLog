//
//  Target.Callback.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 30/07/2017.
//
//

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


public class Callback: Target {

    
    /// Push the logging request onto the callback queue to decouple the logger from possible -bottleneck- constraints in the callback.
    
    public func record(at level: Level, source: Source, message: Any?, timestamp: Date?) {
        let time = timestamp ?? Date()
        queue?.async {
            [weak self] in
            self?.logToCallback(time, source, level, message)
        }
    }

    // Send logging messages to callbacks using this queue. This decouples the log messages on this machine from possible application errors.
    
    private var queue: DispatchQueue = DispatchQueue(label: "SwifterLog-Callback", qos: .background, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: .inherit, target: nil)

    private var targets: Array<CallbackProtocol> = []
    
    private func logToCallback(_ time: Date, _ source: Source, _ level: Level, _ message: Any?) {
        if level < threshold { return }
        counters[level.value] += 1
        for filter in filters {
            if filter.excludes(source) { return }
        }
        for target in targets {
            target.logInfo(time, level, source, message)
        }
    }

    
    /// Adds the given callback target to the list of callback targets if it is not present in the list yet. Has no effect if the callback target is already present.
    ///
    /// - Parameter target: The callback target to be added.
    
    public func register(_ target: CallbackProtocol) {
        for t in targets {
            if target === t { return }
        }
        targets.append(target)
    }
    
    
    /// Removes the given callback target from the list of callback targets. Has no effect if the callback target is not present.
    ///
    /// - Parameter target: The callback target to be removed.
    
    public func remove(_ target: CallbackProtocol) {
        for (index, t) in targets.enumerated() {
            if target === t { targets.remove(at: index) }
        }
    }
}
