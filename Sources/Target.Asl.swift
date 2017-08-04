//
//  Target.Asl.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 29/07/2017.
//
//

import Foundation
import CAsl


public class Asl: Target {

    
    /// The only instance of ASL created
    
    public static var singleton: Asl = { Asl() }()

    
    /// This target can only be a singleton
    
    private override init() {}

    
    // Setup the ASL logging facility
    
    private var __once: () = { _ = asl_add_log_file(nil, STDERR_FILENO) }()

    
    /// Record one line of text (conditionally)
    
    public override func record(_ level: Level, _ source: Source, _ message: Any?, _ timestamp: Date? = nil) {
        
        
        // Message must be at or above threshold
        
        if level >= threshold { return }
        
        
        // Prevent unwanted sources from creating an entry
        
        for filter in filters {
            if filter.excludes(source) { return }
        }
        
        
        // Increment the counter
        
        counters[level.value] += 1
        

        // Set the date for ths entry
        
        let date = timestamp ?? Date()
        
        
        // Create the line with loginformation
        
        let str = (formatter ?? SwifterLog.formatter).string(level: level, source: source, message: message, timestamp: date)
        
        
        // Create the entry in the ASL
        
        asl_bridge_log_message(level.aslLevel, str)
    }

    
}
