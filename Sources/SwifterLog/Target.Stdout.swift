// =====================================================================================================================
//
//  File:       Target.Stdout.swift
//  Project:    SwifterLog
//
//  Version:    1.5.0
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
// Writes the log entry to the Unix stdout.
//
// =====================================================================================================================
//
// History:
//
// 1.5.0 - Introduced option to suppress time information.
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================

import Foundation


public class Stdout: Target {
    
    public var noTimeInfo: Bool = false
    
    private var noTimeFormatter = StdoutNoTimeFormatter()
    
    open override func process(_ entry: Entry) {
        
        
        // Create the line with loginformation
        
        let loginfo: String
        
        if noTimeInfo {
            loginfo = noTimeFormatter.string(entry)
        } else {
            loginfo = (formatter ?? Logger.formatter).string(entry)
        }
        
        // Write the log info to the destination
        
        write(loginfo)
    }

    public override func write(_ string: String) {
        print(string)
    }    
}

public struct StdoutNoTimeFormatter: Formatter {
    
    
    /// Creates a single string from the log entry information.
    
    public func string(_ entry: Entry) -> String {
        
        let levelStr = entry.level.description
        
        let idStr = String(format: "%08x", entry.source.id)
        
        let fileStr = (((entry.source.file as NSString?)?.lastPathComponent as NSString?)?.deletingPathExtension ?? "").replacingOccurrences(of: ".", with: "_")
        
        let typeStr = entry.source.type.replacingOccurrences(of: ".", with: "_")
        
        let functionStr = entry.source.function.replacingOccurrences(of: ".", with: "_")
        
        let lineStr = entry.source.line.description
        
        let str: String
        if let m = entry.message {
            str = ", \(levelStr): \(idStr), \(fileStr).\(typeStr).\(functionStr).\(lineStr), \(m.description)"
        } else {
            str = ", \(levelStr): \(idStr), \(fileStr).\(typeStr).\(functionStr).\(lineStr)"
        }
        
        return str
    }
    
    
    
    /// Create the log entry information from a string
    
    public func parse(_ string: String) -> Entry? {
        fatalError()
    }
    
    
    /// Allow external instances.
    
    fileprivate init() {}
}
