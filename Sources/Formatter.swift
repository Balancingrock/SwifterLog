//
//  Formatter.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 29/07/2017.
//
//

import Foundation


/// A (log) Target uses a formatter to create the string that it will record.

public protocol Formatter {

    
    /// Creates a single string from the input data.
    
    func string(level: Level, source: Source, message: Any?, timestamp: Date) -> String
}


/// The default formatter, used by all defaults targets.

public struct SfFormatter: Formatter {
    
    
    /// Creates a single string from the input data.

    public func string(level: Level, source: Source, message: Any?, timestamp: Date) -> String {
        
        let levelStr: String
        switch level.value {
        case 0: levelStr = "DEBUG    "
        case 1: levelStr = "INFO     "
        case 2: levelStr = "NOTICE   "
        case 3: levelStr = "WARNING  "
        case 4: levelStr = "ERROR    "
        case 5: levelStr = "CRITICAL "
        case 6: levelStr = "ALERT    "
        case 7: levelStr = "EMERGENCY"
        case 8: levelStr = "NONE     "
        default: levelStr = "         "
        }
        
        let idStr = source.id == nil ? "" : String(format: "%08x", source.id!)
        
        let fileStr = source.file ?? ""
        
        let typeStr = source.type ?? ""
        
        let functionStr = source.function ?? ""
        
        let lineStr = source.line?.description ?? ""
        
        let timeStr = SwifterLog.logTimeFormatter.string(from: timestamp)
        
        let str: String
        if let m = message {
            str = "\(timeStr), \(levelStr): \(idStr), \(fileStr).\(typeStr).\(functionStr).\(lineStr), \(m)"
        } else {
            str = "\(timeStr), \(levelStr): \(idStr), \(fileStr).\(typeStr).\(functionStr).\(lineStr)"
        }

        return str
    }

    
    
    /// Create a log entry from a string
    
    public func parse(_ string: String) -> (Date, Level, Source, String?)? {

        let strs = string.components(separatedBy: ", ")
        guard strs.count >= 3 else { return nil }

        let time: Date
        let level: Level
        let id: Int?
        let file: String?
        let type: String?
        let function: String?
        let line: Int?
        let message: String?
        
        if let date = SwifterLog.logTimeFormatter.date(from: strs[0]) {
            time = date
        } else {
            return nil
        }
        
        let levelId = strs[1].components(separatedBy: ": ")
        switch levelId[0] {
        case "DEBUG    ": level = Level.Debug
        case "INFO     ": level = Level.Info
        case "NOTICE   ": level = Level.Notice
        case "WARNING  ": level = Level.Warning
        case "ERROR    ": level = Level.Error
        case "CRITICAL ": level = Level.Critical
        case "ALERT    ": level = Level.Alert
        case "EMERGENCY": level = Level.Emergency
        default: level = Level.None
        }
        if levelId.count == 2 {
            id = Int(levelId[1])
        } else {
            id = nil
        }
        
        let srcStrs = strs[2].components(separatedBy: ".")
        guard srcStrs.count == 4 else { return nil }
        file = srcStrs[0]
        type = srcStrs[1]
        function = srcStrs[2]
        line = Int(srcStrs[3])
        
        if strs.count == 4 {
            message = strs[3]
        } else {
            message = nil
        }
        
        let source = Source(id: id, file: file, type: type, function: function, line: line)
        
        return (time, level, source, message)
    }
    
    
    /// Allow external instances.
    
    public init() {}
}
