// =====================================================================================================================
//
//  File:       Extensions.swift
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
// 1.7.0 - Migration to Swift 5
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================


import Foundation


/// This protocol/extension combination allows classes to be printed like struct's.
///
/// Add ReflectedStringConvertible to any class definition and the default implementation will do the rest.
///
/// Credit: Matt Comi
///
/// - Note: This will override the default 'description'

public protocol ReflectedStringConvertible: CustomStringConvertible {}


/// The default extension for this protocol allows classes to be printed like struct's.

public extension ReflectedStringConvertible {
    
    
    /// The actual description of an objects internals
    
    var description: String {
        let mirror = Mirror(reflecting: self)
        var result = "\(mirror.subjectType)("
        var first = true
        for (label, value) in mirror.children {
            if let label = label {
                if first {
                    first = false
                } else {
                    result += ", "
                }
                result += "\(label): \(value)"
            }
        }
        result += ")"
        return result
    }
}
