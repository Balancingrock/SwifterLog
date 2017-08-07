// =====================================================================================================================
//
//  File:       Source.swift
//  Project:    SwifterLog
//
//  Version:    2.0.0
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
// This struct represents the full source specifier for a log entry.
//
// =====================================================================================================================
//
// History:
// 2.0.0 -  Completely rewritten from 1.0.0
//
// =====================================================================================================================

import Foundation
import VJson


/// This struct represents the full source specifier for a log entry.

public struct Source: Hashable {
    
    public private(set) var hashValue: Int
    
    public let id: Int?
    public let file: String?
    public let type: String?
    public let function: String?
    public let line: Int?
    
    
    public init(id: Int? = nil, file: String? = nil, type: String? = nil, function: String? = nil, line: Int? = nil) {
        self.id = id
        self.file = file
        self.type = type
        self.function = function
        self.line = line
        let arr: [Int] = [id?.hashValue, file?.hashValue, type?.hashValue, function?.hashValue, line?.hashValue].flatMap { $0 }
        self.hashValue = arr.reduce(5381) { return ($0 << 5) &+ $0 &+ $1 }
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
        let jid = (json|"Id")?.intValue
        let jfile = (json|"File")?.stringValue
        let jtype = (json|"Type")?.stringValue
        let jfunction = (json|"Function")?.stringValue
        let jline = (json|"Line")?.intValue
        self.init(id: jid, file: jfile, type: jtype, function: jfunction, line: jline)
    }
}

extension Source: CustomStringConvertible {
    
    public var description: String {
        let strs: [String] = [file ?? "", type ?? "", function ?? "", (line == nil ? "" : line!.description)]
        let str = strs.joined(separator: ".")
        if let id = id {
            return "\(id), \(str)"
        } else {
            return str
        }
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


// Helper extension to read an integer from self and verify that the description of the integer is equal to self.

fileprivate extension String {
    
    func verifiedInt() -> Int? {
        if let i = Int(self) {
            if i.description == self {
                return i
            }
        }
        return nil
    }
}
