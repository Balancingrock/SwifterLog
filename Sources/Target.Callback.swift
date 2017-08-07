// =====================================================================================================================
//
//  File:       Target.Callback.swift
//  Project:    SwifterLog
//
//  Version:    2.0.0
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
// This target call's out to the application itself for processing of the log entries.
//
// =====================================================================================================================
//
// History:
// 2.0.0 -  Completely rewritten from 1.0.0
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
