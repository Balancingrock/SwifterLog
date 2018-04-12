// =====================================================================================================================
//
//  File:       Target.swift
//  Project:    SwifterLog
//
//  Version:    1.3.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2017-2018 Marinus van der Lugt, All rights reserved.
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
// Parent class for log targets.
//
// =====================================================================================================================
//
// History:
//
// 1.3.0 - Added default for Source parameter
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation


public class Target {
    
    
    // This queue is used to schedule the log entries before they are written to the implied target.
    
    private static var queue = DispatchQueue(label: "SwifterLog.Target", qos: .default, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: .inherit, target: nil)

    
    /// Entry levels below this one are ignored.
    
    public var threshold: Level = Level.none
    
    
    /// Filters to exclude entries from beiing recorded.
    
    public var filters: [Filter] = []
    
    
    /// Provides the string for the target to process
    
    public var formatter: Formatter?
    
    
    /// Level counters, each counter counts how many entries were actually made (exclusive the ignored entries)
    
    public var counters: Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0]
    
    
    /// Schedules the logging of a log entry if it is not rejected by the level or filter(s)
    ///
    /// - Parameters:
    ///   - message: An optional message to be recorded with the source & level
    ///   - at: The level for the loginfo
    ///   - from: The source that originated the loginfo
    ///   - with: An optional time to record with the loginfo, will be set to 'now' if not supplied.
    
    public func log(
        message: CustomStringConvertible? = nil,
        at level: Level,
        from source: Source = Source(),
        with timestamp: Date? = nil
        ) {
        
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
        
        
        // Schedule the logging event
        
        let entry = Entry(message: message, level: level, source: source, timestamp: date)
        
        Target.queue.async() {
            [weak self] in
            self?.process(entry)
        }
    }
    
    
    /// This function should transmit/record/file/output etc the entry to its destination. It is intended to be overridden by a child class. No other log entries will be created in any target as longs as this function does not return, provided the log antries are only created using the `log` operation!
    ///
    /// - Note: This function should return immediately. If this target can cause delays it should implement an asynchronous queueing mechanism.
    ///
    /// - Note: The default implementation created a string from the entry using the formatter and calls the `write` function with the result. It is thus also possible to implement only the `write` function.
    
    open func process(_ entry: Entry) {
        
        
        // Create the line with loginformation
        
        let loginfo = (formatter ?? Logger.formatter).string(entry)
        
        
        // Write the log info to the destination
        
        write(loginfo)

    }
    
    /// Writes a formatted string of loginfo to the target. It is intended to be overwritten by a child class.
    ///
    /// - Note: If a (child class of) target does not implement the function `process`, then be aware that this function should return immediately. If this target can cause delays it should implement an asynchronous queueing mechanism.
    ///
    /// - Note: Has a default implementation that does nothing.
    
    open func write(_ string: String) {}
    
    
    /// Closes the target, perform any cleanup or finalization in this operation.
    ///
    /// - Note: Has a default implementation that does nothing.
    
    open func close() {}
}
