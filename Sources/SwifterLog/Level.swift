// =====================================================================================================================
//
//  File:       Level.swift
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
// 2.0.1 - Documentation updated
// 2.0.0 - New header
// 1.3.0 - Replaced ASL levels with OSLogType
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation
import VJson
#if os(macOS) || os(iOS) || os(tvOS)
import os
#endif


/// The log level at which log entries can be written.

public enum Level: Comparable, CustomStringConvertible, VJsonSerializable {
    
    /// The DEBUG level
    ///
    /// Use this level for information that is only relevant during coding for the developper.
    
    case debug
    
    
    /// The INFO level
    ///
    /// Use this level for information that is relevant during coding but should remain available even when the debugging level is disabled.
    
    case info
    
    
    /// The NOTICE level
    ///
    /// Use this level to record information that might help you helping a user that experiences problems with the product.
    
    case notice
    
    
    /// The WARNING level
    ///
    /// Use this level to record information that might help a user to solve a problem or help with understanding the product's behaviour.

    case warning
    
    
    /// The ERROR level
    ///
    /// Use this level to record information that explains why something was wrong and the product (possibly) failed to perform as expected. However future performance of the product should be unaffected.
    
    case error
    
    
    /// The CRITICAL level
    ///
    /// Use this level to record information that explains why future performance of the product will be affected (unless corrective action is taken).
    
    case critical
    
    
    /// The ALERT level
    ///
    /// Use this level to alert the end-user to possible security violations.
    
    case alert
    
    
    /// The EMERGENCY level
    ///
    /// Use this level as a last ditch effort to record some information that might explain why the application crashed.
    
    case emergency
    
    
    /// Use this to avoid all logging.
    ///
    /// This level can be usefull when writing code that logs at dynamic loglevels.
    
    case none
    
    
    /// The numerical value for this loglevel.
    
    public var value: Int {
        switch self {
        case .debug:        return 0
        case .info:         return 1
        case .notice:       return 2
        case .warning:      return 3
        case .error:        return 4
        case .critical:     return 5
        case .alert:        return 6
        case .emergency:    return 7
        case .none:         return 8
        }
    }
    
    
    #if os(macOS) || os(iOS) || os(tvOS)
    
    /// The OSLogTYpe for this loglevel.
    
    @available(OSX 10.12, *)
    public var osLogType: OSLogType {
        switch self {
        case .debug:        return OSLogType.debug
        case .info:         return OSLogType.info
        case .notice:       return OSLogType.default
        case .warning:      return OSLogType.error
        case .error:        return OSLogType.error
        case .critical:     return OSLogType.error
        case .alert:        return OSLogType.error
        case .emergency:    return OSLogType.fault
        case .none:         fatalError("osLogType should never be used on Level enum")
        }
    }
    
    #endif
    
    #if os(Linux)
    
    public var linuxPriority: Int32 {
        switch self {
        case .debug:        return 7
        case .info:         return 6
        case .notice:       return 5
        case .warning:      return 4
        case .error:        return 3
        case .critical:     return 2
        case .alert:        return 1
        case .emergency:    return 0
        case .none:         fatalError("linuxPriority should never be used on Level enum")
        }
    }

    #endif
    
    
    /// The binary pattern for this loglevel
    
    public var bitPattern: Int {
        switch self {
        case .debug:        return 0b0000_0000_0001
        case .info:         return 0b0000_0000_0010
        case .notice:       return 0b0000_0000_0100
        case .warning:      return 0b0000_0000_1000
        case .error:        return 0b0000_0001_0000
        case .critical:     return 0b0000_0010_0000
        case .alert:        return 0b0000_0100_0000
        case .emergency:    return 0b0000_1000_0000
        case .none:         return 0b0001_0000_0000
        }
    }

    
    /// The CustomStringConvertible protocol
    
    public var description: String {
        switch self {
        case .debug:        return "DEBUG    "
        case .info:         return "INFO     "
        case .notice:       return "NOTICE   "
        case .warning:      return "WARNING  "
        case .error:        return "ERROR    "
        case .critical:     return "CRITICAL "
        case .alert:        return "ALERT    "
        case .emergency:    return "EMERGENCY"
        case .none:         return "NONE     "
        }
    }
    
    
    /// The JSON representation
    
    public var json: VJson {
        return VJson(value)
    }
    
    
    /// This function returns one of the static levels in this class.
    ///
    /// - Parameter json: A JSON number with an integer value of the requested level.
    ///
    /// - Returns: The static level corresponding to the specified value, or nil if there is no such level.

    public static func factory(_ json: VJson?) -> Level? {
        guard let json = json else { return nil }
        guard let jvalue = json.intValue else { return nil }
        return factory(jvalue)
    }
    
    
    /// This function returns one of the static levels in this class.
    ///
    /// - Parameter value: The integer value of the requested level.
    ///
    /// - Returns: The static level corresponding to the specified value, or nil if there is no such level.
    
    public static func factory(_ value: Int) -> Level? {
        switch value {
        case 0: return Level.debug
        case 1: return Level.info
        case 2: return Level.notice
        case 3: return Level.warning
        case 4: return Level.error
        case 5: return Level.critical
        case 6: return Level.alert
        case 7: return Level.emergency
        case 8: return Level.none
        default: return nil
        }
    }
    
    
    /// This function returns one of the static levels in this class.
    ///
    /// - Parameter string: The string for which to determine the static level.
    ///
    /// - Returns: The static level corresponding to the given string, or nil if there is no such level.

    public static func factory(_ string: String) -> Level? {
        switch string {
        case "DEBUG":       return Level.debug
        case "INFO":        return Level.info
        case "NOTICE":      return Level.notice
        case "WARNING":     return Level.warning
        case "ERROR":       return Level.error
        case "CRITICAL":    return Level.critical
        case "ALERT":       return Level.alert
        case "EMERGENCY":   return Level.emergency
        case "NONE":        return Level.none
        default:            return nil
        }
    }
 
    
    /// The equatable & comparable protocol function
    
    public static func == (lhs: Level, rhs: Level) -> Bool {
        return lhs.value == rhs.value
    }

    
    /// The comparable protocol function

    public static func < (lhs: Level, rhs: Level) -> Bool {
        return lhs.value < rhs.value
    }
}
