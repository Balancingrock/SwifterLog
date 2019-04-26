// =====================================================================================================================
//
//  File:       Extension.swift
//  Project:    SwifterLog
//
//  Version:    1.7.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2017-2019 Marinus van der Lugt, All rights reserved.
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
//  I strongly believe that voluntarism is the way for societies to function optimally. So you can pay whatever you
//  think our code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you can also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to visit the website to ensure that you actually pay me and not some imposter)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// Purpose:
//
// Extensions that may be usefull with SwifterLog.
//
// =====================================================================================================================
//
// History:
//
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
