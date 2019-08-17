// =====================================================================================================================
//
//  File:       Formatter.swift
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
//       - Allowed empty type identifier
// 1.3.0 - Changed message from Any to CustomStringConvertible
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation


/// A formatter creates a string from the log entry information, and creates the log entry information from a string.

public protocol Formatter {

    
    /// Creates a single string from the input data.
    
    func string(_ entry: Entry) -> String
    
    
    /// Create the log entry information from a string.
    
    func parse(_ string: String) -> Entry?
}


/// Creates the date & time in the log info string.

internal var logTimeFormatter: DateFormatter = {
    let ltf = DateFormatter()
    ltf.dateFormat = "yyyy-MM-dd'T'HH.mm.ss.SSSZ"
    return ltf
}()


/// The default formatter, used by all defaults targets.

public struct SfFormatter: Formatter {
    
    
    /// Creates a single string from the log entry information.

    public func string(_ entry: Entry) -> String {
        
        let levelStr = entry.level.description
        
        let idStr = String(format: "%08x", entry.source.id)
        
        let fileStr = (((entry.source.file as NSString?)?.lastPathComponent as NSString?)?.deletingPathExtension ?? "").replacingOccurrences(of: ".", with: "_")
        
        let typeStr = entry.source.type.replacingOccurrences(of: ".", with: "_")
        
        let functionStr = entry.source.function.replacingOccurrences(of: ".", with: "_")
        
        let lineStr = entry.source.line.description
        
        let timeStr = logTimeFormatter.string(from: entry.timestamp)

        let str: String
        if let m = entry.message {
            if typeStr.isEmpty {
                str = "\(timeStr), \(levelStr): \(idStr), \(fileStr).\(functionStr).\(lineStr), \(m.description)"
            } else {
                str = "\(timeStr), \(levelStr): \(idStr), \(fileStr).\(typeStr).\(functionStr).\(lineStr), \(m.description)"
            }
        } else {
            if typeStr.isEmpty {
                str = "\(timeStr), \(levelStr): \(idStr), \(fileStr).\(functionStr).\(lineStr)"
            } else {
                str = "\(timeStr), \(levelStr): \(idStr), \(fileStr).\(typeStr).\(functionStr).\(lineStr)"
            }
        }

        return str
    }

    
    
    /// Create the log entry information from a string
    
    public func parse(_ string: String) -> Entry? {

        let strs = string.components(separatedBy: ", ")
        guard strs.count >= 3 else { return nil }

        let time: Date
        let level: Level
        let id: Int
        let file: String
        let type: String
        let function: String
        let line: Int
        let message: String?
        
        if let date = logTimeFormatter.date(from: strs[0]) {
            time = date
        } else {
            return nil
        }
        
        let levelId = strs[1].components(separatedBy: ": ")
        switch levelId[0] {
        case "DEBUG    ": level = Level.debug
        case "INFO     ": level = Level.info
        case "NOTICE   ": level = Level.notice
        case "WARNING  ": level = Level.warning
        case "ERROR    ": level = Level.error
        case "CRITICAL ": level = Level.critical
        case "ALERT    ": level = Level.alert
        case "EMERGENCY": level = Level.emergency
        default: level = Level.none
        }
        
        guard levelId.count == 2 else { return nil }
        guard let li = Int(levelId[1]) else { return nil }
        id = li
        
        let srcStrs = strs[2].components(separatedBy: ".")
        if srcStrs.count == 4 {
            file = srcStrs[0]
            type = srcStrs[1]
            function = srcStrs[2]
            line = Int(srcStrs[3]) ?? 0
        } else if srcStrs.count == 3 {
            file = srcStrs[0]
            type = ""
            function = srcStrs[1]
            line = Int(srcStrs[2]) ?? 0
        } else {
            return nil
        }
        
        if strs.count == 4 {
            message = strs[3]
        } else {
            message = nil
        }
        
        let source = Source(id: id, file: file, type: type, function: function, line: line)
        
        return Entry(message: message, level: level, source: source, timestamp: time)
    }
    
    
    /// Allow external instances.
    
    public init() {}
}
