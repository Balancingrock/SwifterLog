// =====================================================================================================================
//
//  File:       Source.swift
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
// This struct represents the full source specifier for a log entry.
//
// =====================================================================================================================
//
// History:
//
// 1.7.0 - Migration to Swift 5
// 1.3.0 - Added default initialisation
//         Removed optionality from all members.
// 1.1.2 - Migration to Swift 4, minor changes.
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation
import VJson


/// This struct represents the full source specifier for a log entry.

public struct Source: Hashable {
        
    public let id: Int
    public let file: String
    public let type: String
    public let function: String
    public let line: Int
    
    
    public init(id: Int = -1, file: String = #file, type: String = "noType", function: String = #function, line: Int = #line) {
        self.id = id
        self.file = file
        self.type = type
        self.function = function
        self.line = line
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(file)
        hasher.combine(type)
        hasher.combine(function)
        hasher.combine(line)
    }
}

extension Source: VJsonConvertible {

    public var json: VJson {
        let j = VJson()
        j["Id"] &= id
        j["File"] &= file
        j["Type"] &= type
        j["Function"] &= function
        j["Line"] &= line
        return j
    }

    public init?(json: VJson?) {
        guard let json = json else { return nil }
        guard let jid = (json|"Id")?.intValue else { return nil }
        guard let jfile = (json|"File")?.stringValue else { return nil }
        guard let jtype = (json|"Type")?.stringValue else { return nil }
        guard let jfunction = (json|"Function")?.stringValue else { return nil }
        guard let jline = (json|"Line")?.intValue else { return nil }
        self.init(id: jid, file: jfile, type: jtype, function: jfunction, line: jline)
    }
}

extension Source: CustomStringConvertible {
    
    public var description: String {
        let strs: [String] = [file, type, function, line.description]
        let str = strs.joined(separator: ".")
        return "\(id), \(str)"
    }
}

extension Source: Equatable {
    
    public static func == (lhs: Source, rhs: Source) -> Bool {
        if lhs.hashValue != rhs.hashValue { return false }
        if lhs.file != rhs.file { return false }
        if lhs.type != rhs.type { return false }
        if lhs.function != rhs.function { return false }
        if lhs.line != rhs.line { return false }
        return true
    }
}

