//
//  Extensions.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 30/07/2017.
//
//

import Foundation


/// An extension that adds a convenience method for logging information.

public extension String {
    
    
    /// Creates 'source' information from a #file identifier.
    ///
    /// Example usage: log.atLevelDebug(id: 0, source: #file.source(#function, #line), message: "My Message")
    ///
    /// - Note: This will increase the time needed to create the log entry, it is therefore not advised for time-critical entries. Suggested use is at level NOTICE and above only.
    ///
    /// - Parameters:
    ///   - function: A string identifying the function that the logging information is created in.
    ///   - line: The line number where the logging call is made.
    ///
    /// - Returns: A string to be used as the 'source' identifier in the logging message.
    
    public func source(_ function: String, _ line: Int) -> String {
        return ((self as NSString).lastPathComponent as NSString).deletingPathExtension + "." + function + "." + line.description
    }
}


/// This protocol/extension combination allows classes to be printed like struct's.
///
/// Add ReflectedStringConvertible to any class definition and the extension will do the rest.
///
/// Credit: Matt Comi
///
/// - Note: This will override the default 'description'

public protocol ReflectedStringConvertible: CustomStringConvertible {}


/// The default extension for this protocol allows classes to be printed like struct's.
///
/// Add ReflectedStringConvertible to any class definition and the extension will do the rest.
///
/// - Note: This will override the default 'description'
///
/// Credit: Matt Comi

public extension ReflectedStringConvertible {
    public var description: String {
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
