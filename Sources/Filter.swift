//
//  Filter.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 29/07/2017.
//
//

import Foundation


public protocol Filter {
    
    /// Checks if the source must be excluded by the patterns in the filter.
    ///
    /// - Returns: True if the src must be excluded.
    
    func excludes(_ src: Source) -> Bool
}


public struct SourceFilter: Filter {
    
    public private(set) var file: String?
    public private(set) var type: String?
    public private(set) var function: String?
    public private(set) var firstLine: Int?
    public private(set) var lastLine: Int?
    
    public init(file: String? = nil, type: String? = nil, function: String? = nil, line: Int? = nil, lastLine: Int? = nil) {
        self.file = file
        self.type = type
        self.function = function
        self.firstLine = line
        self.lastLine = lastLine
    }
    
    
    /// Checks if the source must be excluded by the patterns in the filter.
    ///
    /// - Returns: True if the src must be excluded.
    
    public func excludes(_ src: Source) -> Bool {
        if let regex = file { if src.file?.range(of: regex, options: .regularExpression) == nil { return false }}
        if let regex = type { if src.type?.range(of: regex, options: .regularExpression) == nil { return false }}
        if let regex = function { if src.function?.range(of: regex, options: .regularExpression) == nil { return false }}
        if let firstLine = firstLine {
            if let line = src.line {
                if let lastLine = lastLine {
                    return (line >= firstLine) && (line <= lastLine)
                } else {
                    return line == firstLine
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
