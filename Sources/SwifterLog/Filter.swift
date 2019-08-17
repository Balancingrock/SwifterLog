// =====================================================================================================================
//
//  File:       Filter.swift
//  Project:    SwifterLog
//
//  Version:    2.0.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2017-2018 Marinus van der Lugt, All rights reserved.
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
// 2.0.0 - New header
// 1.3.0 - Definition of Entry was changed.
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation


public protocol Filter {
    
    
    /// The name of this filter.
    
    var name: String { get set }
    
    
    /// Checks if the source must be excluded by the patterns in the filter.
    ///
    /// - Returns: True if the src must be excluded.
    
    func excludes(_ level: Level, _ source: Source) -> Bool
}


/// A default implementation for a filter.

public struct SfFilter: Filter {

    
    /// The name for this filter
    
    public var name: String
    
    
    /// One of the criteria the level/source must fulfill to be excluded, see init parameters for detail.
    
    public let firstId: Int?
    
    
    /// One of the criteria the level/source must fulfill to be excluded, see init parameters for detail.
    
    public let lastId: Int?
    
    
    /// One of the criteria the level/source must fulfill to be excluded, see init parameters for detail.
    
    public let file: String?
    
    
    /// One of the criteria the level/source must fulfill to be excluded, see init parameters for detail.
    
    public let type: String?
    
    
    /// One of the criteria the level/source must fulfill to be excluded, see init parameters for detail.
    
    public let function: String?
    
    
    /// One of the criteria the level/source must fulfill to be excluded, see init parameters for detail.
    
    public let firstLine: Int?
    
    
    /// One of the criteria the level/source must fulfill to be excluded, see init parameters for detail.
    
    public let lastLine: Int?
    
    
    /// One of the criteria the level/source must fulfill to be excluded, see init parameters for detail.
    
    public let level: Int
    
    
    /// Creates a new source filter.
    ///
    /// The filter operation `excludes` will check that all criteria are matched (see parameters) in order to be excluded from the logging process.
    ///
    /// - Parameters:
    ///   - name: The name for this filter (should be unique)
    ///   - levels: An array with the levels to which this filter should apply.
    ///   - id: Exclude entry if it's id matches this id, or if it is in the range between this number and the lastId (inclusive).
    ///   - lastId: Exclude an entry if it's id is in the range between the id number and this number (inclusive).
    ///   - file: Exclude an entry if its filename contains this regex pattern.
    ///   - type: Exclude an entry if its type name contains this regex pattern.
    ///   - function: Exclude an entry if its function name contains this regex pattern.
    ///   - line: Exclude entry if it's line number matches this number, or if it is in the range between this number and the lastId number (inclusive).
    ///   - lastLine: Exclude an entry if it's number is in the range between the line number and this number (inclusive).
    
    public init(name: String, levels: [Level] = [], id: Int? = nil, lastId: Int? = nil, file: String? = nil, type: String? = nil, function: String? = nil, line: Int? = nil, lastLine: Int? = nil) {
        
        self.name = name
        self.level = levels.reduce(0) { $0 & $1.bitPattern }
        self.firstId = id
        self.lastId = lastId
        self.file = file
        self.type = type
        self.function = function
        self.firstLine = line
        self.lastLine = lastLine
    }
    
    
    /// Checks if the source must be excluded by the patterns in the filter.
    ///
    /// - Returns: True if the level/source combination must be excluded from generating a log entry.
    
    public func excludes(_ level: Level, _ source: Source) -> Bool {
        
        if !((level.bitPattern & self.level) != 0) { return false }
        
        if !(source.id.inRange(first: self.firstId, last: self.lastId)) { return false }
        if !(source.file.regex(self.file)) { return false }
        if !(source.type.regex(self.type)) { return false }
        if !(source.function.regex(self.function)) { return false }
        if !(source.line.inRange(first: self.firstLine, last: self.lastLine)) { return false }

        return true
    }
}

fileprivate extension String {
    
    
    /// Returns true if the regex pattern applied to self returns a valid range.
    
    func regex(_ pattern: String?) -> Bool {
        guard let pattern = pattern else { return false }
        return self.range(of: pattern, options: String.CompareOptions.regularExpression) != nil
    }
}

fileprivate extension Int {
    
    
    // Returns true if self can be found in the range given by first and last.
    
    func inRange(first: Int?, last: Int?) -> Bool {
        guard let first = first else { return false }
        if let last = last {
            return (self >= first) && (self <= last)
        } else {
            return (self == first)
        }
    }
}
