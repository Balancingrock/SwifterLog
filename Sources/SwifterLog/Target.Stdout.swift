// =====================================================================================================================
//
//  File:       Target.Stdout.swift
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
// 1.6.0 - Undid 1.5.0
// 1.5.0 - Introduced option to suppress time information.
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================
//
// Purpose:
//
// Writes the log entry to the Unix stdout.
//
// =====================================================================================================================

import Foundation


/// The STDout target for log entries.

public class Stdout: Target {
    
    
    /// Writes a log entry to the console.
    
    open override func process(_ entry: Entry) {
        
        
        // Create the line with loginformation
        
        let loginfo = (formatter ?? Logger.formatter).string(entry)

        
        // Write the log info to the destination
        
        write(loginfo)
    }

    
    /// Writes a string to the console
    
    public override func write(_ string: String) {
        print(string)
    }    
}

