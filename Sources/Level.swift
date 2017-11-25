// =====================================================================================================================
//
//  File:       Level.swift
//  Project:    SwifterLog
//
//  Version:    1.1.0
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
// Provides logging levels for SwifterLog.
//
// =====================================================================================================================
//
// History:
// 1.1.0 -  Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation
import VJson


// The log level at which log entries can be written.

public enum Level: Comparable, CustomStringConvertible, VJsonSerializable {
    
    case debug, info, notice, warning, error, critical, alert, emergency, none
    
    
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
    
    
    /// The ASL level for this loglevel.
    
    public var aslLevel: Int32 {
        switch self {
        case .debug:        return 7
        case .info:         return 6
        case .notice:       return 5
        case .warning:      return 4
        case .error:        return 3
        case .critical:     return 2
        case .alert:        return 1
        case .emergency:    return 0
        case .none:         fatalError("aslLevel should never be used on Level enum")
        }
    }

    
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
