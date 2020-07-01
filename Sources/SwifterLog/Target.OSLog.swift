// =====================================================================================================================
//
//  File:       Target.OSLog.swift
//  Project:    SwifterLog
//
//  Version:    2.1.1
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2017-2020 Marinus van der Lugt, All rights reserved.
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
// 2.1.1 - Linux compatibility
// 2.0.0 - New header
// 1.5.0 - Added OSLog levels filtering
// 1.3.0 - Removed CAsl, renamed to OSLog
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================
//
// Purpose:
//
// Interface to write log entries to the OS Logger.
//
// =====================================================================================================================

import Foundation
#if os(macOS) || os(iOS) || os(tvOS)
import os
#endif
#if os(Linux)
import Glibc
#endif


/// An interface to write log entries to the OS Log.

public class OSLog: Target {

    
    /// This filter decides AFTER the osLogFacilityRecordAtAndAboveLevel setting if an entry at this level should be enabled or not.
    
    public var debugEnabled: Bool = true
    
    
    /// This filter decides AFTER the osLogFacilityRecordAtAndAboveLevel setting if an entry at this level should be enabled or not.

    public var infoEnabled: Bool = true


    /// This filter decides AFTER the osLogFacilityRecordAtAndAboveLevel setting if an entry at this level should be enabled or not.

    public var defaultEnabled: Bool = true


    /// This filter decides AFTER the osLogFacilityRecordAtAndAboveLevel setting if an entry at this level should be enabled or not.

    public var errorEnabled: Bool = true


    /// This filter decides AFTER the osLogFacilityRecordAtAndAboveLevel setting if an entry at this level should be enabled or not.

    public var faultEnabled: Bool = true
    
    
    /// Record one line of text (conditionally)
    
    public override func process(_ entry: Entry) {
        
        
        // Check OSLog custom levels
        
        switch entry.level {
        case .debug: if !debugEnabled { return }
        case .info: if !infoEnabled { return }
        case .notice: if !defaultEnabled { return }
        case .warning, .error, .critical, .alert: if !errorEnabled { return }
        case .emergency: if !faultEnabled { return }
        case .none: break
        }

        
        // Create the line with loginformation
        
        let str = (formatter ?? Logger.formatter).string(entry)
        
        // Create the entry in the OS Log
        
        #if os(macOS) || os(iOS) || os(tvOS)
        
        if #available(macOS 10.12, *) {
            os_log("%@", type: entry.level.osLogType, (str as NSString))
        }
        
        #endif
        
        #if os(Linux)
        
            withVaList([str.cString(using: .utf8) as! CVarArg]) {
                vsyslog(entry.level.linuxPriority, "%s", $0)
            }
        
        #endif
    }
}
