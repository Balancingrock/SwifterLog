//
//  Target.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 29/07/2017.
//
//

import Foundation

public class Target {
    
    
    /// Entry levels below this one are ignored.
    
    public var threshold: Level = Level.none
    
    
    /// Filters to exclude entries from beiing recorded.
    
    public var filters: [Filter] = []
    
    
    /// Provides the string for the target to process
    
    public var formatter: Formatter?
    
    
    /// Level counters, each counter counts how many entries were actually made (exclusive the ignored entries)
    
    public var counters: Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0]
    
    
    /// Records the given log info if not rejected by the level or filter(s)
    ///
    /// - Note: This function has a default implementation.
    ///
    /// - Parameters:
    ///   - at: The level for the loginfo
    ///   - source: The source that originated the loginfo
    ///   - message: An optional message to be recorded with the source & level
    ///   - timestamp: An optional time to record with the loginfo, will be set to 'now' if not supplied.
    
    open func log(_ level: Level, _ source: Source, _ message: Any? = nil, _ timestamp: Date? = nil) {
        
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
        
        
        // Create the line with loginformation
        
        let loginfo = (formatter ?? SwifterLog.formatter).string(level: level, source: source, message: message, timestamp: date)
        
        
        // Write the log info to the destination
        
        write(loginfo)
    }
    
    
    /// Writes a formatted string of loginfo to the target.
    ///
    /// - Note: Has a default implementation that does nothing.
    
    open func write(_ string: String) {}
    
    
    /// Closes the target, perform any cleanup or finalization in this operation.
    ///
    /// - Note: Has a default implementation that does nothing.
    
    open func close() {}
}
