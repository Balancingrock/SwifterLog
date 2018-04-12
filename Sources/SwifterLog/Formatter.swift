// =====================================================================================================================
//
//  File:       Formatter.swift
//  Project:    SwifterLog
//
//  Version:    1.3.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Blog:       http://swiftrien.blogspot.com
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
// A formatter defines the layout of a log entry. It is (should be) able to transform in both directions in order to
// support all future toolsets. I.e. it should be able to convert an entry to string and a string to an entry.
//
// Formatters can be customized, a default formatter is provided.
//
//
// =====================================================================================================================
//
// History:
//
// 1.3.0 - Changed message from Any to CustomStringConvertible
// 1.1.0 -  Initial release in preperation for v2.0.0
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
            str = "\(timeStr), \(levelStr): \(idStr), \(fileStr).\(typeStr).\(functionStr).\(lineStr), \(m.description)"
        } else {
            str = "\(timeStr), \(levelStr): \(idStr), \(fileStr).\(typeStr).\(functionStr).\(lineStr)"
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
        guard srcStrs.count == 4 else { return nil }
        file = srcStrs[0]
        type = srcStrs[1]
        function = srcStrs[2]
        line = Int(srcStrs[3]) ?? 0
        
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
