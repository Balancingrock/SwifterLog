//
//  Source.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 29/07/2017.
//
//

import Foundation
import VJson

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


/// This struct represents the full source specifier for a log entry.

public struct Source: Hashable, VJsonConvertible {
    
    public private(set) var hashValue: Int
    
    public let id: Int?
    public let file: String?
    public let type: String?
    public let function: String?
    public let line: Int?
    
    public var json: VJson {
        let j = VJson()
        j["Id"] &= id
        j["File"] &= file
        j["Type"] &= type
        j["Function"] &= function
        j["Line"] &= line
        return j
    }
    
    public init(id: Int? = nil, file: String? = nil, type: String? = nil, function: String? = nil, line: Int? = nil) {
        self.id = id
        self.file = file
        self.type = type
        self.function = function
        self.line = line
        let arr: [Int] = [id?.hashValue, file?.hashValue, type?.hashValue, function?.hashValue, line?.hashValue].flatMap { $0 }
        self.hashValue = arr.reduce(5381) { return ($0 << 5) &+ $0 &+ $1 }
    }
    
    public init?(json: VJson?) {
        guard let json = json else { return nil }
        id = (json|"Id")?.intValue
        file = (json|"File")?.stringValue
        type = (json|"Type")?.stringValue
        function = (json|"Function")?.stringValue
        line = (json|"Line")?.intValue
        let arr: [Int] = [id?.hashValue, file?.hashValue, type?.hashValue, function?.hashValue, line?.hashValue].flatMap { $0 }
        self.hashValue = arr.reduce(5381) { return ($0 << 5) &+ $0 &+ $1 }
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

public extension Source {
    
    public static func == (lhs: Source, rhs: Source) -> Bool {
        if lhs.hashValue != rhs.hashValue { return false }
        if lhs.file != rhs.file { return false }
        if lhs.type != rhs.type { return false }
        if lhs.function != rhs.function { return false }
        if lhs.line != rhs.line { return false }
        return true
    }
}
