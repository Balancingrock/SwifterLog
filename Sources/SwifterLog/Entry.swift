// =====================================================================================================================
//
//  File:       Entry.swift
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
// 2.0.0 - New header
// 1.3.0 - Changed message type from Any to CustomStringConvertible
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation


/// This type is used to represent the data to be logged. It is usually created by internal functions of SwifterLog.

public struct Entry {
    
    
    /// The message that accompanies the log entry. If the message (object) is a class and does not implement `CustomStringConvertible` it is recommended to extend the class with `ReflectedStringConvertible`.
    
    public let message: CustomStringConvertible?
    
    
    /// The logging level at which this entry should be created.
    
    public let level: Level
    
    
    /// The source that created this entry.
    
    public let source: Source
    
    
    /// The timestamp at which this entry was made.
    
    public let timestamp: Date
}
