//
//  Level.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 29/07/2017.
//
//

import Foundation
import VJson

public class Level: CustomStringConvertible, VJsonSerializable {
    
    public let value: Int
    public let aslLevel: Int32
    
    static public let Debug = Level(0)!
    static public let Info = Level(1)!
    static public let Notice = Level(2)!
    static public let Warning = Level(3)!
    static public let Error = Level(4)!
    static public let Critical = Level(5)!
    static public let Alert = Level(6)!
    static public let Emergency = Level(7)!
    static public let None = Level(8)!
    
    public var filters: [Filter] = []
    
    
    public var json: VJson {
        return VJson(value)
    }
    
    public var description: String {
        switch value {
        case 0: return "DEBUG    "
        case 1: return "INFO     "
        case 2: return "NOTICE   "
        case 3: return "WARNING  "
        case 4: return "ERROR    "
        case 5: return "CRITICAL "
        case 6: return "ALERT    "
        case 7: return "EMERGENCY"
        case 8: return "NONE     "
        default: return "***ERR***"
        }
    }
    
    private init?(_ value: Int) {
        guard value >= 0 && value <= 8 else { return nil }
        self.value = value
        self.aslLevel = -(Int32(value) - 7)
    }
    
    
    /// This function returns one of the static levels in this class.
    ///
    /// - Parameter json: A JSON number with an integer value of the requested level.
    ///
    /// - Returns: The static level corresponding to the specified value, or nil if there is no such level.

    public static func factory(_ json: VJson?) -> Level? {
        guard let json = json else { return nil }
        guard let jvalue = json.intValue else { return nil }
        return factory(jvalue)
    }
    
    
    /// This function returns one of the static levels in this class.
    ///
    /// - Parameter value: The integer value of the requested level.
    ///
    /// - Returns: The static level corresponding to the specified value, or nil if there is no such level.
    
    public static func factory(_ value: Int) -> Level? {
        switch value {
        case 0: return Debug
        case 1: return Info
        case 2: return Notice
        case 3: return Warning
        case 4: return Error
        case 5: return Critical
        case 6: return Alert
        case 7: return Emergency
        case 8: return None
        default: return nil
        }
    }
    
    public convenience init?(string: String) {
        switch string {
        case "DEBUG": self.init(0)
        case "INFO": self.init(1)
        case "NOTICE": self.init(2)
        case "WARNING": self.init(3)
        case "ERROR": self.init(4)
        case "CRITICAL": self.init(5)
        case "ALERT": self.init(6)
        case "EMERGENCY": self.init(7)
        default: return nil
        }
    }
 
    public func record(_ source: Source, _ targets: [Target], _ message: Any? = nil) {
        let now = Date()
        for filter in filters {
            if filter.excludes(source) { return }
        }
        logQueue.async {
            targets.forEach { $0.record(self, source, message, now) }
        }
    }
    
    public static func >= (lhs: Level, rhs: Level) -> Bool {
        return lhs.value >= rhs.value
    }
    
    public static func == (lhs: Level, rhs: Level) -> Bool {
        return lhs.value == rhs.value
    }

    public static func <= (lhs: Level, rhs: Level) -> Bool {
        return lhs.value <= rhs.value
    }
    
    public static func < (lhs: Level, rhs: Level) -> Bool {
        return lhs.value < rhs.value
    }
    
    public static func > (lhs: Level, rhs: Level) -> Bool {
        return lhs.value > rhs.value
    }
}
