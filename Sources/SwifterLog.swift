// =====================================================================================================================
//
//  File:       SwifterLog.swift
//  Project:    SwifterLog
//
//  Version:    0.9.19
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2014-2016 Marinus van der Lugt, All rights reserved.
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
//  I strongly believe that the Non Agression Principle is the way for societies to function optimally. I thus reject
//  the implicit use of force to extract payment. Since I cannot negotiate with you about the price of this code, I
//  have choosen to leave it up to you to determine its price. You pay me whatever you think this code is worth to you.
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
// Don't forget: Before creating the final release version of the software, make sure to set the correct loglevels!
//
// =====================================================================================================================
//
// NOTES:
//
// In the update to Xcode 8 beta 6 the loggingQueue is created with AutoreleaseFrequency.inherit. This was done for
// backwards compatibility to MacOS 10.11. If that is not needed, setting it to AutoreleaseFrequency.never would seem
// more appropriate.
//
// =====================================================================================================================
//
// History:
// 0.9.19  - Removed definition of global variable log, replaced with 'theLogger' singleton.
//         - Added logger interfaces to allow higher performance disabled levels through optional chaining.
// 0.9.14  - Move to SPM
//         - Documentation updates for reference manual generation
//         - Changed callback protocol to 'AnyObject' from 'class'
//         - Added conditional compilation for the network target
// 0.9.13  - Upgraded to Xcode 8 beta 6 (see "NOTES" above!)
//         - Changed names of logfiles to use '.' instead of '/' as seperator between time components.
// 0.9.12  - Upgraded to Swift 3 beta
// 0.9.9   - Added 'public' to the string extensions
//         - Added 'ReflectedStringConvertible' (idea from Matt Comi, https://github.com/mattcomi )
//         - Changed message parameter from 'String' to optinal 'Any?' on all logging calls
//           (Inspired by whitehat007, https://github.com/whitehat007 )
//         - Fixed bug that would not call the callback destination for the very first logging message
// 0.9.8   - Header update
// 0.9.7   - Split off the network related stuff into its own file (except for the property definitions)
// 0.9.6   - Included extension for String to easily create a SOURCE identifier from a #file string.
//         - JSON code returned by 'json' changed from a value to a valid hierarchy.
//         - Added ALL_NON_RECURSIVE target definition.
//         - Updated for changes in SwifterSockets.Transmit
// 0.9.5   - Added transfer of log entries to a TCP/IP destination and targetting of error messages.
//         - Renamed logfileRecordAtAndAboveLevel to fileRecordAtAndAboveLevel
//         - Added call-back logging
// 0.9.4   - Added conveniance functions that add the "ID" parameter back in as hexadecimal output before the source.
// 0.9.3   - Changed syntax to Swift 2.0
// 0.9.2   - Removed the 'ID' parameter from the logging calls
//         - Added the "consoleSeparatorLine" function to create separators in the xcode or console output
// 0.9.1   - Initial release
//
// =====================================================================================================================

import Foundation
import CAsl


/// The protocol for loginfo callback receivers

public protocol SwifterlogCallbackProtocol: AnyObject {
    
    /// Called when log information must be processed by the target.
    ///
    /// - Note: __DO NOT CALL A LOGGING FUNCTION WITHIN A CALLBACK WITH A TARGET INCLUDING THE CALLBACK ITSELF.__ This would create an endless loop.
    ///
    /// - Parameters:
    ///   - time: The time of the logging event.
    ///   - level: The level of the logging event.
    ///   - source: The source of the logging event.
    ///   - message: The message of the logging event.
    
    func logInfo(_ time: Date, level: SwifterLog.Level, source: String, message: String)
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


/// A single class logging 'framework'

public final class SwifterLog {
    
    
    // Setup the ASL logging facility
    
    private lazy var __once: () = { _ = asl_add_log_file(nil, STDERR_FILENO) }()
    
    
    /// The logging levels
    
    public enum Level: Int, CustomStringConvertible {
        
        
        /// The lowest level, will not appear in the system log unless additional system settings are updated.
        ///
        /// Recommendation: Use this level when working in xcode during programming / debugging.
        ///
        /// Example: "MyClass.myFunc: started" or "myParameter = 42"
        
        case debug = 0
        
        
        /// The lowest level but one, will not appear in the system log unless additional system settings are updated.
        ///
        /// Recommendation: Use this level while still working on the project, but a decent level of confidence in the code correctness is present. For example during GUI level test/debugging.
        ///
        /// Example: "User clicked commit" or "Image XYZ loaded in MyClass"
        
        case info = 1
        
        
        /// The lowest level that can be visible in the Apple System Log.
        ///
        /// Recommendation: Use this level to record information that might help you helping a user that experiences problems with the product.
        ///
        /// Example: "Connection with server established" or "Set image correction to ALWAYS"
        
        case notice = 2
        
        
        /// The lowest level but one that can be visible in the Apple System Log.
        ///
        /// Recommendation: Use this level to record information that might help a user to solve a problem or help with understanding the product's behaviour.
        ///
        /// Example: "Option HIGHLIGHT no longer supported" or "Data after end-of-data marker ignored"

        case warning = 3
        
        
        /// Recommendation: Use this level to record information that explains why something was wrong and the product (possibly) failed to perform as expected. However future performance of the product should be unaffected.
        ///
        /// Example: "Cannot load file format XYZ" or "Data does not contain XYZ"
        
        case error = 4
        
        
        /// Recommendation: Use this level to record information that explains why future performance of the product will be affected (unless corrective action is taken).
        ///
        /// Example: "Cannot save file, disk is full" or "Transfer interrupted"

        case critical = 5
        
        
        /// Recommendation: Use this level to alert the end-user to possible security violations.
        ///
        /// Example: Like somebody failing the password more than N times.
        
        case alert = 6
        
        
        /// Recommendation: Use this level to attempt a last ditch effort to record some information that might explain why the application crashed.
        
        case emergency = 7
        
        
        /// This is a meta level for filtering purposes only. Use it to allow all other levels to record their information.
        
        case none = 8
        
        
        /// A textual description of the level.
        
        public var description: String {
            
            switch self {
            case .debug:        return "DEBUG    "
            case .info:         return "INFO     "
            case .notice:       return "NOTICE   "
            case .warning:      return "WARNING  "
            case .error:        return "ERROR    "
            case .critical:     return "CRITICAL "
            case .alert:        return "ALERT    "
            case .emergency:    return "EMERGENCY"
            case .none:         return "NONE     "
            }
        }
        
        
        /// The Apple System Log facility level associated with this Logging Level.
        
        public func toAslLevel() -> Int32 {
            
            switch self {
            case .debug:        return 7
            case .info:         return 6
            case .notice:       return 5
            case .warning:      return 4
            case .error:        return 3
            case .critical:     return 2
            case .alert:        return 1
            case .emergency:    return 0
            case .none:         return -1
            }
        }
        
        
        /// Implements the Smaller or Equal comparison.
        ///
        /// - Parameters:
        ///   - left: A logging level
        ///   - right: A logging level
        ///
        /// - Returns: True if the left logging level ranks at or below the right logging level. False otherwise.
        
        static public func <= (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
            return left.rawValue <= right.rawValue
        }
        
        
        /// Implements the Smaller or Equal comparison.
        ///
        /// - Parameters:
        ///   - left: A logging level
        ///   - right: A logging level
        ///
        /// - Returns: True if the left logging level ranks at or above the right logging level. False otherwise.

        static public func >= (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
            return left.rawValue >= right.rawValue
        }
        
        
        /// Implements the Smaller or Equal comparison.
        ///
        /// - Parameters:
        ///   - left: A logging level
        ///   - right: A logging level
        ///
        /// - Returns: True if the left logging level ranks above the right logging level. False otherwise.
        
        static public func > (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
            return left.rawValue > right.rawValue
        }
        
        
        /// Implements the Smaller or Equal comparison.
        ///
        /// - Parameters:
        ///   - left: A logging level
        ///   - right: A logging level
        ///
        /// - Returns: True if the left logging level ranks below the right logging level. False otherwise.
        
        static public func < (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
            return left.rawValue < right.rawValue
        }
        
        
        /// Implements the Smaller or Equal comparison.
        ///
        /// - Parameters:
        ///   - left: A logging level
        ///   - right: A logging level
        ///
        /// - Returns: True if the left logging level equals the right logging level. False otherwise.
        
        static public func == (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
            return left.rawValue == right.rawValue
        }
        
        
        /// Synchronize the optional loggers availability with the level of self.
        
        fileprivate func createLoggers() {
            
            switch self {
                
            case .debug:
                atDebug = Logger.debugLogger
                atInfo = Logger.debugLogger
                atNotice = Logger.noticeLogger
                atWarning = Logger.warningLoger
                atError = Logger.errorLogger
                atCritical = Logger.criticalLogger
                atAlert = Logger.alertLogger
                atEmergency = Logger.emergencyLogger
            
            case .info:
                atDebug = nil
                atInfo = Logger.debugLogger
                atNotice = Logger.noticeLogger
                atWarning = Logger.warningLoger
                atError = Logger.errorLogger
                atCritical = Logger.criticalLogger
                atAlert = Logger.alertLogger
                atEmergency = Logger.emergencyLogger
                
            case .notice:
                atDebug = nil
                atInfo = nil
                atNotice = Logger.noticeLogger
                atWarning = Logger.warningLoger
                atError = Logger.errorLogger
                atCritical = Logger.criticalLogger
                atAlert = Logger.alertLogger
                atEmergency = Logger.emergencyLogger
                
            case .warning:
                atDebug = nil
                atInfo = nil
                atNotice = nil
                atWarning = Logger.warningLoger
                atError = Logger.errorLogger
                atCritical = Logger.criticalLogger
                atAlert = Logger.alertLogger
                atEmergency = Logger.emergencyLogger
                
            case .error:
                atDebug = nil
                atInfo = nil
                atNotice = nil
                atWarning = nil
                atError = Logger.errorLogger
                atCritical = Logger.criticalLogger
                atAlert = Logger.alertLogger
                atEmergency = Logger.emergencyLogger
                
            case .critical:
                atDebug = nil
                atInfo = nil
                atNotice = nil
                atWarning = nil
                atError = nil
                atCritical = Logger.criticalLogger
                atAlert = Logger.alertLogger
                atEmergency = Logger.emergencyLogger
                
            case .alert:
                atDebug = nil
                atInfo = nil
                atNotice = nil
                atWarning = nil
                atError = nil
                atCritical = nil
                atAlert = Logger.alertLogger
                atEmergency = Logger.emergencyLogger
                
            case .emergency:
                atDebug = nil
                atInfo = nil
                atNotice = nil
                atWarning = nil
                atError = nil
                atCritical = nil
                atAlert = nil
                atEmergency = Logger.emergencyLogger
                
            case .none:
                atDebug = nil
                atInfo = nil
                atNotice = nil
                atWarning = nil
                atError = nil
                atCritical = nil
                atAlert = nil
                atEmergency = nil
            }
        }
    }
    

    /// Available targets for error messages
    
    public enum Target {
        
        
        /// Prints the log message to the console in xcode, or to the command line.
        
        case stdout
        
        
        /// Writes the log message to a file.
        
        case file
        
        
        /// Stores the log message in the Apple System Log facility
        
        case asl

        
        
        #if SWIFTERLOG_DISABLE_NETWORK_TARGET
        #else
        /// Transfers the log message to the network destination
        case network
        #endif

        /// Sends the log message to the specified target
        
        case callback
        
        
        #if SWIFTERLOG_DISABLE_NETWORK_TARGET
        /// A set containing all targets
        public static let ALL: Set<Target> = [stdout, file, asl, callback]
        #else
        /// A set containing all targets
        public static let ALL: Set<Target> = [stdout, file, asl, network, callback]
        #endif
        
        
        #if SWIFTERLOG_DISABLE_NETWORK_TARGET
        /// A set containing all targets except the callback
        public static let ALL_EXCEPT_CALLBACK: Set<Target> = [stdout, file, asl]
        #else
        /// A set containing all targets except the callback
        public static let ALL_EXCEPT_CALLBACK: Set<Target> = [stdout, file, asl, network]
        #endif
        
        
        #if SWIFTERLOG_DISABLE_NETWORK_TARGET
        /// A set containing all targets except the ASL
        public static let ALL_EXCEPT_ASL: Set<Target> = [stdout, file, callback]
        #else
        /// A set containing all targets except the ASL
        public static let ALL_EXCEPT_ASL: Set<Target> = [stdout, file, network, callback]
        #endif

        
        /// A set containing all targets except the callback and network since there have the potential to be recursive.
        
        public static let ALL_NON_RECURSIVE: Set<Target> = [stdout, file, asl]
    }

    
    /// This singleton is intended to be used as the logger.
    
    public static let theLogger = SwifterLog()
    
    
    /// Convenience class to allow higher performance disabled logging calls.

    public final class Logger {
        private let level: SwifterLog.Level
        private init(_ level: SwifterLog.Level) { self.level = level }
        fileprivate static let debugLogger = Logger(.debug)
        fileprivate static let infoLogger = Logger(.info)
        fileprivate static let noticeLogger = Logger(.notice)
        fileprivate static let warningLoger = Logger(.warning)
        fileprivate static let errorLogger = Logger(.error)
        fileprivate static let criticalLogger = Logger(.critical)
        fileprivate static let alertLogger = Logger(.alert)
        fileprivate static let emergencyLogger = Logger(.emergency)
        public func log(source: String, message: Any? = nil, targets: Set<SwifterLog.Target> = SwifterLog.Target.ALL) {
            theLogger.atLevel(level, source: source, message: message, targets: targets)
        }
        public func log(id: Int32, source: String, message: Any? = nil, targets: Set<SwifterLog.Target> = SwifterLog.Target.ALL) {
            theLogger.atLevel(level, id: id, source: source, message: message, targets: targets)
        }
    }

    /// Convenience interface to SwifterLog at the level debug.
    ///
    /// This interface has performance advantages when the debug level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atDebug?.log(...)
    
    public static var atDebug: Logger?
    
    
    /// Conveniece interface to SwifterLog at the level info.
    ///
    /// This interface has performance advantages when the info level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atInfo?.log(...)
    
    public static var atInfo: Logger?
    
    
    /// Conveniece interface to SwifterLog at the level notice.
    ///
    /// This interface has performance advantages when the notice level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atNotice?.log(...)
    
    public static var atNotice: Logger?
    
    
    /// Conveniece interface to SwifterLog at the level warning.
    ///
    /// This interface has performance advantages when the warning level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atWarning?.log(...)
    
    public static var atWarning: Logger?
    
    
    /// Conveniece interface to SwifterLog at the level error.
    ///
    /// This interface has performance advantages when the error level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atError?.log(...)
    
    public static var atError: Logger?
    
    
    /// Conveniece interface to SwifterLog at the level critical.
    ///
    /// This interface has performance advantages when the notice level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atCritical?.log(...)
    
    public static var atCritical: Logger?
    
    
    /// Conveniece interface to SwifterLog at the level alert.
    ///
    /// This interface has performance advantages when the warning level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atAlert?.log(...)
    
    public static var atAlert: Logger?
    
    
    /// Conveniece interface to SwifterLog at the level emergency.
    ///
    /// This interface has performance advantages when the error level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atEmergency?.log(...)
    
    public static var atEmergency: Logger?
    
    
    /// The path for the directory in which the next logfile will be created.
    ///
    /// Note that the application must have write access to this directory and the rights to create this directory (sandbox!). If this variable is nil, the logfiles will be written to /Library/Application Support/[Application Name]/Logfiles.
    ///
    /// Do not use '~' signs in the path, expand them first if there are tildes in it.
    
    /// - Note: When debugging in xcode, the app support directory is in /Library/Containers/[bundle identifier]/Data/Library/Application Support/[app name]/Logfiles.
 
    public var logfileDirectoryPath: String? {
        didSet {
            logdirErrorMessageGenerated = false
            logfileErrorMessageGenerated = false
        }
    }
    
    
    /// As soon as an entry in the current logfile grows the logfile beyond this limit, the logfile will be closed and a new logfile will be started. The default is 1 MB. Also see "logfileMaxNumberOfFiles".
    
    public var logfileMaxSizeInBytes: UInt64 = 1 * 1024 * 1024

    
    /// The maximum number of logfiles kept in the logfile directory. As soon as there are more than this number of logfiles, the oldest logfile will be removed. Must be >= 2.
    
    public var logfileMaxNumberOfFiles: Int = 20 {
        didSet {
            if logfileMaxNumberOfFiles < 2 { logfileMaxNumberOfFiles = 2 }
        }
    }
    
    
    // MARK: - For the network target.
    
    /// Associates a tuple with a network destination.
    
    public typealias NetworkTarget = (address: String, port: String)

    
    /// The most recent value of the network target that was set using the function "connectToNetworkTarget".
    ///
    /// Will be nil if the target is unreachable or once a "closeNetworkTarget" was executed.
    ///
    /// - Note: There will be a delay between calling connectToNetworkTarget and closeNetworkTarget and the updating of this variable. Thus checking this variable immediately after a return from either function will most likely fail to deliver the actual status.
    
    public var networkTarget: NetworkTarget? { return _networkTarget }
    
    internal var _networkTarget: NetworkTarget?
    
    
    // The socket for the network target
    
    internal var socket: Int32?

    
    // MARK: - Loglevel control
    
    /// Only messages with a level at or above the level specified in this variable will be written to STDOUT. Set to "SwifterLog.Level.NONE" to suppress all messages to STDOUT.
    
    public var stdoutPrintAtAndAboveLevel: Level = .none { didSet { self.setOverallThreshold() } }
    
    
    /// Only messages with a level at or above the level specified in this variable will be recorded in the logfile. Set to "SwifterLog.Level.NONE" to suppress all messages to the logfile.

    public var fileRecordAtAndAboveLevel: Level = .none  { didSet { self.setOverallThreshold() } }

    
    /// Only messages with a level at or above the level specified in this variable will be recorded by the Apple System Log Facility. Set to "SwifterLog.Level.NONE" to suppress all messages to the ASL(F).
    ///
    /// - Note: The ASL log entries can be viewed with the "System Information.app" that is available in the "Applications/Utilities" folder. Also note that the configuration file at "/etc/asl.conf" suppresses all messages at levels DEBUG and INFO by default irrespective of the value of this variable.
    ///
    /// - Note: SwifterLog itself can write messages to the ASL at level ERROR if necessary. If the threshold is set higher than ERROR SwifterLog will fail silently.
    
    public var aslFacilityRecordAtAndAboveLevel: Level = .none  {
        didSet {
            self.setOverallThreshold()
            if (oldValue == .none) && (aslFacilityRecordAtAndAboveLevel != .none) {
                _ = self.__once
            }
        }
    }

    
    /// Only messages with a level at or above the level specified in this variable will be transferred to the network destination. Set to "SwifterLog.Level.NONE" to suppress transmission of all messages to the network destination.
    
    public var networkTransmitAtAndAboveLevel: Level = .none { didSet { self.setOverallThreshold() } }
    
    
    /// Only messages with a level at or above the level specified in this variable will be transferred to the callback destination(s). Set to "SwifterLog.Level.NONE" to suppress transmission of all messages to the callback destination(s).

    public var callbackAtAndAboveLevel: Level = .none { didSet { self.setOverallThreshold() } }
    
    
    // MARK: - Callback management
    
    /// Adds the given callback target to the list of callback targets if it is not present in the list yet. Has no effect if the callback target is already present.
    ///
    /// - Parameter target: The callback target to be added.
    
    public func registerCallback(_ target: SwifterlogCallbackProtocol) {
        for t in callbackTargets {
            if target === t { return }
        }
        callbackTargets.append(target)
    }

    
    /// Removes the given callback target from the list of callback targets. Has no effect if the callback target is not present.
    ///
    /// - Parameter target: The callback target to be removed.

    public func removeCallback(_ target: SwifterlogCallbackProtocol) {
        for (index, t) in callbackTargets.enumerated() {
            if target === t { callbackTargets.remove(at: index) }
        }
    }
    
    
    // MARK: - Console utility
    
    /// Prints a line with the specified character for the specified times to the console
    
    public func consoleSeperatorLine(_ char: Character, times: Int) {
        guard times >= 0 else { return }
        let time = Date()
        var separator = ""
        for _ in 0 ..< times {
            separator.append(char)
        }
        loggingQueue.async(execute: {
            [unowned self] in
            let logstr = SwifterLog.logTimeFormatter.string(from: time) + ", SEPARATOR: " + separator
            self.logToStdout(logstr)
            })
    }
    
    
    // MARK: - Logging functions
    
    
    /// Log the given message to all destinations that have a logging level set at or below the specified level.
    ///
    /// - Parameters:
    ///   - level: Write the log message to destinations at or below this level.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the specified level).
    
    public func atLevel(_ level: Level, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(level, source: source, message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at .debug.
    ///
    /// - Parameters:
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).

    public func atLevelDebug(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.debug, source: source, message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .info.
    ///
    /// - Parameters:
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelInfo(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.info, source: source, message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .notice.
    ///
    /// - Parameters:
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelNotice(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.notice, source: source, message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .warning.
    ///
    /// - Parameters:
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelWarning(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.warning, source: source, message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .error.
    ///
    /// - Parameters:
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelError(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.error, source: source, message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .critical.
    ///
    /// - Parameters:
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelCritical(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.critical, source: source, message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .alert.
    ///
    /// - Parameters:
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelAlert(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.alert, source: source, message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .emergency.
    ///
    /// - Parameters:
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelEmergency(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.emergency, source: source, message: message, targets: targets)
    }

    
    /// Log the given message to all destinations that have a logging level set at or below the specified level.
    ///
    /// - Parameters:
    ///   - level: Write the log message to destinations at or below this level.
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the specified level).

    public func atLevel(_ level: Level, id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(level, source: createSource(id, source), message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at .debug.
    ///
    /// - Parameters:
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).

    public func atLevelDebug(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.debug, source: createSource(id, source), message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .info.
    ///
    /// - Parameters:
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelInfo(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.info, source: createSource(id, source), message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .notice.
    ///
    /// - Parameters:
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelNotice(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.notice, source: createSource(id, source), message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .warning.
    ///
    /// - Parameters:
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelWarning(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.warning, source: createSource(id, source), message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .error.
    ///
    /// - Parameters:
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelError(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.error, source: createSource(id, source), message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .critical.
    ///
    /// - Parameters:
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelCritical(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.critical, source: createSource(id, source), message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .alert.
    ///
    /// - Parameters:
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).
    
    public func atLevelAlert(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.alert, source: createSource(id, source), message: message, targets: targets)
    }
    
    
    /// Log the given message to all destinations that have a logging level set at or below .emergency.
    ///
    /// - Parameters:
    ///   - id: A 32 bit integer that can be used to identify an object or other resource this message applies to.
    ///   - source: The source of the message.
    ///   - message: The data to be recorded.
    ///   - targets: The target set to record to (subject to the cutoff level).

    public func atLevelEmergency(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.emergency, source: createSource(id, source), message: message, targets: targets)
    }

    
    // MARK: - All private from here on
    
    // Conveniance
    
    private func createSource(_ id: Int32, _ source: String) -> String {
        return String(format: "%08x, %@", id, source)
    }

    fileprivate init() { // Guarantee a singleton usage of the logger
        
        // Try to read the settings from the app's Info.plist
        
        if  let infoPlist = Bundle.main.infoDictionary,
            let swifterLogOptions = infoPlist["SwifterLog"] as? Dictionary<String, AnyObject> {
            
                if let alsThreshold = swifterLogOptions["aslFacilityRecordAtAndAboveLevel"] as? NSNumber {
                    if alsThreshold.intValue >= Level.debug.rawValue && alsThreshold.intValue <= Level.none.rawValue {
                        aslFacilityRecordAtAndAboveLevel = Level(rawValue: alsThreshold.intValue)!
                    } else {
                        logAslErrorOverride("Info.plist value for aslFacilityRecordAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                    }
                }
                    
                if let stdoutThreshold = swifterLogOptions["stdoutPrintAtAndAboveLevel"] as? NSNumber {
                    if stdoutThreshold.intValue >= Level.debug.rawValue && stdoutThreshold.intValue <= Level.none.rawValue {
                        stdoutPrintAtAndAboveLevel = Level(rawValue: stdoutThreshold.intValue)!
                    } else {
                        logAslErrorOverride("Info.plist value for stdoutPrintAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                    }
                }
                
                if let logfileThreshold = swifterLogOptions["fileRecordAtAndAboveLevel"] as? NSNumber {
                    if logfileThreshold.intValue >= Level.debug.rawValue && logfileThreshold.intValue <= Level.none.rawValue {
                        fileRecordAtAndAboveLevel = Level(rawValue: logfileThreshold.intValue)!
                    } else {
                        logAslErrorOverride("Info.plist value for fileRecordAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                    }
                }
                
                if let networkThreshold = swifterLogOptions["networkTransmitAtAndAboveLevel"] as? NSNumber {
                    if networkThreshold.intValue >= Level.debug.rawValue && networkThreshold.intValue <= Level.none.rawValue {
                        networkTransmitAtAndAboveLevel = Level(rawValue: networkThreshold.intValue)!
                    } else {
                        logAslErrorOverride("Info.plist value for networkTransmitAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                    }
                }
                
                if let callbackThreshold = swifterLogOptions["callbackAtAndAboveLevel"] as? NSNumber {
                    if callbackThreshold.intValue >= Level.debug.rawValue && callbackThreshold.intValue <= Level.none.rawValue {
                        callbackAtAndAboveLevel = Level(rawValue: callbackThreshold.intValue)!
                    } else {
                        logAslErrorOverride("Info.plist value for callbackAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                    }
                }
                
                if let logfileMaxSize = swifterLogOptions["logfileMaxSizeInBytes"] as? NSNumber {
                    if logfileMaxSize.intValue >= 10 * 1024 && logfileMaxSize.intValue <= 100 * 1024 * 1024 {
                        logfileMaxSizeInBytes = UInt64(logfileMaxSize.intValue)
                    } else {
                        logAslErrorOverride("Info.plist value for logfileMaxSizeInBytes in SwifterLog out of bounds (10kB .. 100MB)")
                    }
                }
                
                if let logfileNofFiles = swifterLogOptions["logfileMaxNumberOfFiles"] as? NSNumber {
                    if logfileNofFiles.intValue >= 2 && logfileNofFiles.intValue <= 1000 {
                        logfileMaxNumberOfFiles = logfileNofFiles.intValue
                    } else {
                        logAslErrorOverride("Info.plist value for logfileMaxNumberOfFiles in SwifterLog out of bounds (2 .. 1000)")
                    }
                }
                
                if let logfileDirPath = swifterLogOptions["logfileDirectoryPath"] as? String {
                    logfileDirectoryPath = logfileDirPath
                }

                #if SWIFTERLOG_DISABLE_NETWORK_TARGET
                #else
                if let networkIpAddress = swifterLogOptions["networkIpAddress"] as? String {
                    if let networkPortNumber = swifterLogOptions["networkPortNumber"] as? String {
                        connectToNetworkTarget(NetworkTarget(networkIpAddress, networkPortNumber))
                    }
                }
                #endif
        }
    }
    
    
    // This function writes error messages to the ASL irrespective of the level settings. For internal use only.

    private func logAslErrorOverride(_ message: String) {
        loggingQueue.async(execute: { asl_bridge_log_message(Level.error.toAslLevel(), message) } )
    }
    
    private func putOnLoggingQueue(_ level: Level, source: String, message: Any?, targets: Set<Target>) {
        if level == .none { return }
        if overallThreshold > level { return }
        let stdoutEnabled   = targets.contains(.stdout)   && (stdoutPrintAtAndAboveLevel <= level)
        let aslEnabled      = targets.contains(.asl)      && (aslFacilityRecordAtAndAboveLevel <= level)
        let fileEnabled     = targets.contains(.file)     && (fileRecordAtAndAboveLevel <= level)

        #if SWIFTERLOG_DISABLE_NETWORK_TARGET
        let networkEnabled  = false
        #else
        let networkEnabled  = targets.contains(.network)  && (networkTransmitAtAndAboveLevel <= level)
        #endif
        
        let callbackEnabled = targets.contains(.callback) && (callbackAtAndAboveLevel <= level)
        let stringMessage = "\(message ?? "")"
        loggingQueue.async(execute: {
            [unowned self] in
            self.log(
                Date(),
                source: source,
                logLevel: level,
                message: stringMessage,
                destinationSTDOut: stdoutEnabled,
                destinationASL: aslEnabled,
                destinationFile: fileEnabled,
                destinationNetwork: networkEnabled,
                destinationCallback: callbackEnabled)
        })
    }


    internal static var logTimeFormatter: DateFormatter = {
        let ltf = DateFormatter()
        ltf.dateFormat = "yyyy-MM-dd'T'HH.mm.ss.SSSZ"
        return ltf
    }()
    
    private var aslInitialised: Int = 0

    
    // Used to suppress multiple error messages for the failure to create a directory for the logfiles
    
    private var logdirErrorMessageGenerated = false
    private var logfileErrorMessageGenerated = false
    
    
    // For a slight performance gain
    
    private var overallThreshold = SwifterLog.Level.debug

    
    // Should be called on every update to any of the three thresholds.
    
    private func setOverallThreshold() {
        var newThreshold = stdoutPrintAtAndAboveLevel
        if newThreshold > aslFacilityRecordAtAndAboveLevel { newThreshold = aslFacilityRecordAtAndAboveLevel }
        if newThreshold > fileRecordAtAndAboveLevel { newThreshold = fileRecordAtAndAboveLevel }
        if newThreshold > networkTransmitAtAndAboveLevel { newThreshold = networkTransmitAtAndAboveLevel }
        if newThreshold > callbackAtAndAboveLevel { newThreshold = callbackAtAndAboveLevel }
        overallThreshold = newThreshold
        overallThreshold.createLoggers()
    }
    
    
    // Write log messages only from within this queue, that guarantees a non-overlapping behaviour even if multiple threads use the SwifterLog.
    
    private let loggingQueue = DispatchQueue(label: "logging-queue", qos: .background, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
    
    
    // Send logging messages to a network destination using this. This decouples the log messages on this machine from the traffic conditions to another machine.
    
    internal var networkQueue: DispatchQueue?
    
    
    // Send logging messages to callbacks using this queue. This decouples the log messages on this machine from possible application errors.
    
    private var callbackQueue: DispatchQueue?

    
    // This function creates the log message and controls distribution to the enabled destinations, it should be called from within the logginQueue only.
    
    private func log(
        _ time: Date,
        source: String,
        logLevel: Level,
        message: String,
        destinationSTDOut: Bool,
        destinationASL: Bool,
        destinationFile: Bool,
        destinationNetwork: Bool,
        destinationCallback: Bool)
    {
        let sourceMessage = message.isEmpty ? source : source + ", " + message
        let logstr = SwifterLog.logTimeFormatter.string(from: time) + ", " + logLevel.description + ": " + sourceMessage
            
        if destinationSTDOut { logToStdout(logstr) }
        if destinationFile { logToFile(logstr) }
        if destinationASL { logToASL(logLevel, message: logstr) }

        #if SWIFTERLOG_DISABLE_NETWORK_TARGET
        #else
        if destinationNetwork {
            if networkQueue != nil {
                networkQueue!.async(execute: { [unowned self] in
                    self.logToNetwork(time, source: source, logLevel: logLevel, message: message)
                    })
            }
        }
        #endif

        if destinationCallback {
            if callbackQueue == nil {
                callbackQueue = DispatchQueue(label: "callback-queue")
            }
            callbackQueue!.async(execute: { [unowned self] in
                self.logToCallback(time, source: source, logLevel: logLevel, message: message)
                })
        }
    }
    
    
    // MARK: - ASL target
    
    private func logToASL(_ level: Level, message: String) {
        asl_bridge_log_message(level.toAslLevel(), message)
    }
    
    
    // MARK: - STDOUT target
    
    private func logToStdout(_ message: String) {
        print(message)
    }
    
    
    // MARK: - FILE target
    
    private func logToFile(_ message: String) {
        
        if let file = logfile {
            
            _ = file.seekToEndOfFile()
            if let data = (message + "\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true) {
                file.write(data)
                file.synchronizeFile()
            }
            
            
            // Do some additional stuff like creating a new file if the current one gets too large and cleaning up of existing logfiles if there are too many
            
            self.logfileServices()
        }
    }


    // Handle for the logfile
    
    lazy private var logfile: FileHandle? = { self.createLogfile() }()
    

    // We use the /Library/Application Support/<<<application>>>/Logfiles directory if no logfile directory is specified

    lazy private var applicationSupportLogfileDirectory: String? = {


        let fileManager = FileManager.default
        
        do {
            let applicationSupportDirectory =
                try fileManager.url(
                    for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                    in: FileManager.SearchPathDomainMask.userDomainMask,
                    appropriateFor: nil,
                    create: true).path
            
            let appName = ProcessInfo.processInfo.processName
            let dirUrl = URL(fileURLWithPath: applicationSupportDirectory, isDirectory: true).appendingPathComponent(appName)
            return dirUrl.appendingPathComponent("Logfiles").path

        } catch let error as NSError {
        
            let message: String = "Could not get application support directory, error = \(error.localizedDescription)"
            self.logToASL(Level.error, message: message)
            return nil
        }
    }()
    
    
    // Will be set to the URL of the logfile if the directory for the logfiles is available.
    
    private var logfileDirectoryURL: URL?
    
    
    // Creates a new logfile.
    
    private func createLogfile() -> FileHandle? {
        
        
        // Get the logfile directory
        
        if let logdir = logfileDirectoryPath ?? applicationSupportLogfileDirectory {
            
            do {
                
                // Make sure the logfile directory exists

                try FileManager.default.createDirectory(atPath: logdir, withIntermediateDirectories: true, attributes: nil)
            
                logfileDirectoryURL = URL(fileURLWithPath: logdir, isDirectory: true) // For the logfile services
        
                let filename = "Log_" + SwifterLog.logTimeFormatter.string(from: Date()) + ".txt"
                
                let logfileUrl = URL(fileURLWithPath: logdir).appendingPathComponent(filename)
                
                if FileManager.default.createFile(atPath: logfileUrl.path, contents: nil, attributes: [FileAttributeKey.posixPermissions.rawValue : NSNumber(value: 0o640)]) {
                    
                    return FileHandle(forUpdatingAtPath: logfileUrl.path)

                } else {
                    
                    if !logfileErrorMessageGenerated {
                        let message = "Could not create logfile \(logfileUrl.path)"
                        logToASL(.error, message: message)
                        logfileErrorMessageGenerated = true
                    }
                }
                
            } catch let error as NSError {
                
                if !logdirErrorMessageGenerated {
                    let message = "Could not create logfile directory \(logdir), error = \(error.localizedDescription)"
                    logToASL(.error, message: message)
                    logdirErrorMessageGenerated = true
                }
            }
            
        } else {
            // Only possible if the application support directory could not be retrieved, in that case an ASL entry has already been generated
        }
        
        return nil
    }
    
    
    // Closes the current logfile if it has gotten too large. And limits the number of logfiles to the specified maximum.
    
    private func logfileServices() {
        
        
        // There should be a logfile, if there is'nt, then something is wrong
        
        if let file = logfile {
        
            
            // If the file size is larger than the specified maximum, close the existing logfile and create a new one
            
            if file.seekToEndOfFile() > logfileMaxSizeInBytes {
                
                file.closeFile()
                
                logfile = createLogfile()
            }
        
            
            // Check if there are more than 20 files in the logfile directory, if so, remove the oldest
            
            do {
            
                let files = try FileManager.default.contentsOfDirectory(
                    at: logfileDirectoryURL!,
                    includingPropertiesForKeys: nil,
                    options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                
                if files.count > logfileMaxNumberOfFiles {
                    let sortedFiles = files.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
                    try FileManager.default.removeItem(at: sortedFiles.first!)
                }
            } catch {
            }
        }
    }

    
    // MARK: - Callback targets
    
    private var callbackTargets: Array<SwifterlogCallbackProtocol> = []
    
    private func logToCallback(_ time: Date, source: String, logLevel: Level, message: String) {
        for target in callbackTargets {
            target.logInfo(time, level: logLevel, source: source, message: message)
        }
    }
}
