// =====================================================================================================================
//
//  File:       Target.Stdout.swift
//  Project:    SwifterLog
//
//  Version:    2.0.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
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
//  Like you, I need to make a living:
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


public class Stdout: Target {
    
    open override func process(_ entry: Entry) {
        
        
        // Create the line with loginformation
        
        let loginfo = (formatter ?? Logger.formatter).string(entry)

        
        // Write the log info to the destination
        
        write(loginfo)
    }

    public override func write(_ string: String) {
        print(string)
    }    
}

