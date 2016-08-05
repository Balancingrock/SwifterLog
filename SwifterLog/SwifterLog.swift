// =====================================================================================================================
//
//  File:       SwifterLog.swift
//  Project:    SwifterLog
//
//  Version:    0.9.12
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/pages/projects/swifterlog/
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Swiftrien/SwifterLog
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
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  whishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
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
// This file needs two assist files:
// 
// asl-bridge.h which should contain:
// ----------------------------------
//
// #import <Foundation/Foundation.h>
//
// #ifndef asl_bridge_h
// #define asl_bridge_h
//
// int asl_bridge_log_message(int level, NSString *message);
//
// #endif
//
//
// And the corresponding asl-bridge.m which should contain:
// --------------------------------------------------------
//
// #import <Foundation/Foundation.h>
//
// #import <asl.h>
// #import "asl-bridge.h"
//
// int asl_bridge_log_message(int level, NSString *message) {
//     return asl_log_message(level, "%s", [message cStringUsingEncoding:NSUTF8StringEncoding]);
// }
//
//
// It also needs the following two lines in your <<<app-name>>-Bridging-Header.h:
// ------------------------------------------------------------------------------
//
// #import <asl.h>
// #import "asl-bridge.h"
//
// =====================================================================================================================
//
// WARNING: Both the network destination and callback destinations have the potential to be too slow to accept all the
// logging information sent to them. While this will not impact the other destinations (i.e. logging will continue to
// work normally on the other destinations) it will result in an increasing load on the system resources. Eventually
// this can lead to a crash of your application.
//
// Quick start:
//
// 1) Add SwifterJSON and SwifterSockets to the project. (Not necessary if the TODO items are performed as detailed in
//    the source code)
//
// 2) Add all 4 files (asl-bridge.h, asl-bridge.m, SwifterLog.swift and SwifterLog.Network.swift) to the project. (Do
//    not add SwifterLog.Network.swift if SwifterJSON and SwifterSockets are not present)
//
// 3) Update the bridging header (create one if necessary)
//
// 4) Make sure there is no global variable called "log" in the project, except for the one in this file.
//
// 5) That is all. Now add logging statements, just type "log." and the auto-completion in xcode will start suggesting
//    the operations necessary to log and configure this utility.
//    Typical is as follows:
//
//    a) log.atLevelError(id: logId, source: "My source identifier", message: "Error message")
//    b) log.atLevelError(id: logId, source: #file.source(#function, #line), message: "Error message")
//    c) private let SOURCE = ((#file as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
//       log.atLevelError(id: logId, source: SOURCE + ".\(#function).\(#line)", message: "Error message")
//
// Note1: The id is intended to differentiate between sources. I.e. for example an object identifier, a thread
// identifier, or a socket cq file descriptor.
//
// Note2: The source field is used to identify the spot where the log entry originated. The fastest way to do this is
// by using a constant string (example a). However when the extra time consumption is not a problem it may also be done
// automatically as in example (b). Example c is a compromise between a and b. I am not really sure, but these two
// expressions can be evaluated at compile time and hopefully result -like a- in a fast call but with the added benefit
// of auto-generated identifiers.
//
// Note3: Since version 0.9.9 the message parameter has changed to "Any". Extend classes with the
// ReflectedStringConvertible protocol to gain easy access to debug information:
//
//    class MyClass: ReflectedStringConvertible { ... }
//    var myInstance = MyClass()
//    log.atLevelDebug(id: logId, source: #file.source(#function, #line), message: myInstance)
//
// PS: Note that the #file, #function and #line are determined at compile time and thus cannot be abstracted into a
// subroutine.
//
// Configuration of SwifterLog is through:
//
// Configuration for ASL:
//     aslFacilityRecordAtAndAboveLevel - Threshold for recording.
//
// Configuration for STDOUT - i.e. println():
//     stdoutPrintAtAndAboveLevel       - Threshold for printing.
//
// Configuration for a logfile:
//    logfileRecordAtAndAboveLevel      - Threshold for recording.
//    logfileDirectoryPath              - Either nil or the directory in which the logfiles should be written.
//    logfileMaxSizeInBytes             - Approximate maximum size of a single logfile.
//    logfileMaxNumberOfFiles           - The maximum number of logfiles.
//
// Configuration for a network destination:
//    networkTransmitAtAndAboveLevel    - Threshold for transmisison
//    networkIpAddress                  - The IP address of the network destination
//    networkPortNumber                 - The portnumber for the network destination
//
// Configuration for callback:
//    callbackAtAndAboveLevel           - Threshold for calling the callback with the log information
//
// For further details on the configuration, check the definitions below, or see the Xcode Quick Help.
//
// A suggestion: while working in Xcode, set aslFacilityRecordAtAndAboveLevel to .NONE, the others can be set as you
// like/need. In a shipping application set stdoutPrintAtAndAboveLevel to .NONE and the logfile and
// aslFacilityRecordAtAndAboveLevel as you like/need. Be aware that ASL will by default filter out anything at level
// DEBUG and INFO in the /etc/asl.conf file.
//
// Be carefull with the network destination. It can cause a lot of data to be transferred and can potentially cause
// security or privacy issue's.
//
// The configuration variables above can be set in code, or in the application's Info.plist. Note that an application
// procured through the App-store will not start if the Info.plist is changed from the values when "Archived" for
// distribution. If end-user must be able to update the log levels, add a settings panel or menu to your code.
// Note: Without code signing a user can change the Info.plist, but then you cannot use the App-store for distribution.
//
// In order to set them in the Info.plist add a dictionary item with the key value "SwifterLog". In this directory add
// as many of the configuration items as necessary. Use the full name of the configuration items for the key's and
// numbers for their values except for the logfileDirectoryPath which is a string. SwifterLog will guard against values
// that are invalid or out-of-bounds, in that case the default values as in this code will be used.
//
// Key                              | Type       | Range           | Default when absent
// -----------------------------------------------------------------------------------------
// SwifterLog                       | Dictionary | The other items | -
// aslFacilityRecordAtAndAboveLevel | Number     | 0...8           | NONE (8)
// stdoutPrintAtAndAboveLevel       | Number     | 0...8           | NONE (8)
// fileRecordAtAndAboveLevel        | Number     | 0...8           | NONE (8)
// networkTransmitAtAndAboveLevel   | Number     | 0...8           | NONE (8)
// callbackAtAndAboveLevel          | Number     | 0...8           | NONE (8)
// logfileDirectoryPath             | String     | RFC 2396        | "/Library/Application Support/<<AppName>>/Logfiles"
// logfileMaxSizeInBytes            | Number     | 10K...100M      | 1M
// logfileMaxNumberOfFiles          | Number     | 2...1000        | 20
// networkIpAddress                 | String     | IP Address      | -
// networkPortNumber                | String     | Port Number     | -
//
// Note: networkIpAddress and networkPortNumber must both be present to have any effect.
//
// =====================================================================================================================
//
// Don't forget: Before creating the final release version of the software, make sure to set the correct loglevels!
//
// =====================================================================================================================
//
// Here is how I use the log levels:
//
// DEBUG: Almost all of my log messages are at this level. They are only of interest to me while I am working in Xcode.
// Typically they are of the kind "MyClass.myFunc: started" or "myParameter = 42".
//
// INFO: Once I am done with debugging, I still want to gain confidence that my app works as intended. The information
// at this level should remain visible in xcode, even though I am by now mostly unit-testing or running GUI tests from
// within Xcode. None of this information is usefull for the end-user. Typically they are of the kind "User clicked
// commit" or "Image XYZ loaded in MyClass".
//
// NOTICE: This is the first level of information that might be visible to the end-user. I use it to give information
// about the execution that may help me in helping the end-user with a problem. Typically these are messages like:
// "Connection with server established" or "Loaded configuration file" or "Set image correction to ALWAYS".
//
// WARNING: These messages contain information for the end-user. They usually inform the user about things he did wrong
// but which are fully handled by the application. I.e. they do not lead to termination of the app. While the messages
// will often be accompanied by an alert message, they may also fail silently. Typically they are like: "Option
// HIGHLIGHT no longer supported" or "Data after end-of-data marker ignored"
//
// ERROR: These are messages that are always accompanied by an alert window. They alert the user that something impared
// the functioning of the application. Typically like "Cannot load file format XYZ" or "Data does not contain XYZ". Note
// that it is still possible for the application to continue.
//
// CRITICAL: Messages at this level alert the user that he has to do something, or the application will not be able to
// continue. The application will usually stop until the user has fixed the situation. Examples are "Cannot save file,
// disk is full" or "Transfer interrupted".
//
// ALERT: This level is important to the end-user. It contains information about situations that could lead to security
// issues. Like somebody failing the password more than N times.
//
// EMERGENCY: I use this level when the application cannot continue and will terminate itself. The message itself
// is a last ditch attempt to generate some information that gives a clue to the cause of the problem.
//
// =====================================================================================================================
//
// History:
// v0.9.12  - Upgraded to Swift 3 beta
// v0.9.9   - Added 'public' to the string extensions
//          - Added 'ReflectedStringConvertible' (idea from Matt Comi, https://github.com/mattcomi )
//          - Changed message parameter from 'String' to optinal 'Any?' on all logging calls
//            (Inspired by whitehat007, https://github.com/whitehat007 )
//          - Fixed bug that would not call the callback destination for the very first logging message
// v0.9.8   - Header update
// v0.9.7   - Split off the network related stuff into its own file (except for the property definitions)
// v0.9.6   - Included extension for String to easily create a SOURCE identifier from a #file string.
//          - JSON code returned by 'json' changed from a value to a valid hierarchy.
//          - Added ALL_NON_RECURSIVE target definition.
//          - Updated for changes in SwifterSockets.Transmit
// v0.9.5   Added transfer of log entries to a TCP/IP destination and targetting of error messages.
//          Renamed logfileRecordAtAndAboveLevel to fileRecordAtAndAboveLevel
//          Added call-back logging
// v0.9.4   Added conveniance functions that add the "ID" parameter back in as hexadecimal output before the source.
// v0.9.3   Changed syntax to Swift 2.0
// v0.9.2   Removed the 'ID' parameter from the logging calls
//          Added the "consoleSeparatorLine" function to create separators in the xcode or console output
// v0.9.1   Initial release
//
// =====================================================================================================================

import Foundation


// Note: This could also have been implemented as a set of functions instead of a class.
// However creating the class and subsequent singleton gives us a minor ease of use: code completion.
// Typing "log." where you need logging will instantly reveal all available options.


public let log = SwifterLog() // Since SwifterLog.init is private, this is the only instance ever created


/// The protocol for callback receivers

public protocol SwifterlogCallbackProtocol: class {
    
    /**
     The registered callback object must implement this function.
     
     - Parameter time: The time of the logging event.
     - Parameter level: The level of the logging event.
     - Parameter source: The source of the logging event.
     - Parameter message: The message of the logging event.
     
     - Note: DO NOT CALL A LOGGING FUNCTION WITHIN A CALLBACK WITH A TARGET INCLUDING THE CALLBACK ITSELF. This would create an endless loop.
     */
    
    func logInfo(_ time: Date, level: SwifterLog.Level, source: String, message: String)
}


/// This protocol/extension combination allows classes to be printed like struct's.
/// Add ReflectedStringConvertible to any class definition and the extension will do the rest.
/// Credit: Matt Comi
/// - Note: This will override the default 'description'

public protocol ReflectedStringConvertible: CustomStringConvertible {}


/// This protocol/extension combination allows classes to be printed like struct's.
/// Add ReflectedStringConvertible to any class definition and the extension will do the rest.
/// Credit: Matt Comi
/// - Note: This will override the default 'description'

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


public func <= (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
    return left.rawValue <= right.rawValue
}

public func > (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
    return left.rawValue > right.rawValue
}

public extension String {
    
    /**
     Extension to create a SOURCE identifier from a #file identifier.
     
     Example usage: log.atLevelDebug(id: 0, source: #file.source(#function, #line), message: "My Message")
     
     - Note: This will increase the time needed to create the log entry, it is therefore not advised for time-critical entries. Suggested use is at level NOTICE and above only.
     
     - Parameter function: This should be the '#function' identifier.
     - Parameter line: This should be the '#line' identifier.
     */
    public func source(_ function: String, _ line: Int) -> String {
        return ((self as NSString).lastPathComponent as NSString).deletingPathExtension + "." + function + "." + line.description
    }
}

public final class SwifterLog {
    
    
    private lazy var __once: () = { _ = asl_add_log_file(nil, STDERR_FILENO) }()
    
    
    /// The available levels to cut-off
    
    public enum Level: Int, CustomStringConvertible {
        case debug          = 0
        case info           = 1
        case notice         = 2
        case warning        = 3
        case error          = 4
        case critical       = 5
        case alert          = 6
        case emergency      = 7
        case none           = 8
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
    }
    
    
    // TODO: Consider removing the network target if it is not needed. Of course the rest of the code must be slimmed down if this is done. The compiler will identify the other places.
    
    /// Available targets for error messages
    
    public enum Target {
        case stdout, file, asl, network, callback
        public static let ALL: Set<Target> = [stdout, file, asl, network, callback]
        public static let ALL_EXCEPT_CALLBACK: Set<Target> = [stdout, file, asl, network]
        public static let ALL_EXCEPT_ASL: Set<Target> = [stdout, file, network, callback]
        public static let ALL_NON_RECURSIVE: Set<Target> = [stdout, file, asl] // the callback and network could generate an infinite recursion
    }

    
    /**
     Specifies the path for the directory in which the next logfile will be created. Note that the application must have write access to this directory and to create this directory (sandbox!). If this variable is nil, the logfiles will be written to /Library/Application Support/<<<Application Name>>>/Logfiles. Do not use '~' signs in the path, expand them first if there are tildes in the path that must be set.
    
     - Note: When debugging in xcode, the app support directory is in /Library/Containers/<<<bundle identifier>>>/Data/Library/Application Support/<<<app name>>>/Logfiles.
     */
    
    public var logfileDirectoryPath: NSString? {
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
    // TODO: - The following 4 declarations can be removed if the network destination is not needed
    
    public typealias NetworkTarget = (address: String, port: String)

    
    /**
     The most recent value of the network target that was set using the function "connectToNetworkTarget". If the target is unreachable or after a "closeNetworkTarget" was executed the value will be nil.
    
     - Note: There will be a delay between calling connectToNetworkTarget and closeNetworkTarget and the updating of this variable. Thus checking this variable immediately after a return from either function will most likely fail to deliver the actual status.
     */
    
    public var networkTarget: NetworkTarget? {
        return _networkTarget
    }
    
    internal var _networkTarget: NetworkTarget?
    
    
    // The socket for the network target
    
    internal var socket: Int32?

    
    // MARK: - Loglevel control
    
    /// Only messages with a level at or above the level specified in this variable will be written to STDOUT. Set to "SwifterLog.Level.NONE" to suppress all messages to STDOUT.
    
    public var stdoutPrintAtAndAboveLevel: Level = .none { didSet { self.setOverallThreshold() } }
    
    
    /// Only messages with a level at or above the level specified in this variable will be recorded in the logfile. Set to "SwifterLog.Level.NONE" to suppress all messages to the logfile.

    public var fileRecordAtAndAboveLevel: Level = .none  { didSet { self.setOverallThreshold() } }

    
    /**
     Only messages with a level at or above the level specified in this variable will be recorded by the Apple System Log Facility. Set to "SwifterLog.Level.NONE" to suppress all messages to the ASL(F).
    
     - Note: The ASL log entries can be viewed with the "System Information.app" that is available in the "Applications/Utilities" folder. Do note that the configuration file at "/etc/asl.conf" suppresses all messages at levels DEBUG and INFO by default irrespective of the value of this variable.
    
     - Note: SwifterLog itself can write messages to the ASL at level ERROR if necessary. If the threshold is set higher than ERROR SwifterLog will fail silently.
     */
    
    public var aslFacilityRecordAtAndAboveLevel: Level = .none  {
        didSet {
            self.setOverallThreshold()
            if (oldValue == .none) && (aslFacilityRecordAtAndAboveLevel != .none) {
                _ = self.__once
            }
        }
    }

    
    /// Only messages with a level at or above the level specified in this variable will be transferred to the TCP/IP destination. Set to "SwifterLog.Level.NONE" to suppress transmission of all messages to the TCP/IP destination.
    
    public var networkTransmitAtAndAboveLevel: Level = .none { didSet { self.setOverallThreshold() } }
    
    
    /// Only messages with a level at or above the level specified in this variable will be transferred to the callback destination(s). Set to "SwifterLog.Level.NONE" to suppress transmission of all messages to the callback destination(s).

    public var callbackAtAndAboveLevel: Level = .none { didSet { self.setOverallThreshold() } }
    
    
    /**
     Adds the given callback target to the list of callback targets if it is not present in the list yet. Has no effect if the callback target is already present.
     
     - Parameter target: The callback target to be added.
     */
    
    public func registerCallback(_ target: SwifterlogCallbackProtocol) {
        for t in callbackTargets {
            if target === t { return }
        }
        callbackTargets.append(target)
    }

    
    /**
     Removes the given callback target from the list of callback targets. Has no effect if the callback target is not present.
     
     - Parameter target: The callback target to be removed.
     */

    public func removeCallback(_ target: SwifterlogCallbackProtocol) {
        for (index, t) in callbackTargets.enumerated() {
            if target === t { callbackTargets.remove(at: index) }
        }
    }
    
    
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
    
    public func atLevel(_ level: Level, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(level, source: source, message: message, targets: targets)
    }

    public func atLevelDebug(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.debug, source: source, message: message, targets: targets)
    }
    
    public func atLevelInfo(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.info, source: source, message: message, targets: targets)
    }
    
    public func atLevelNotice(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.notice, source: source, message: message, targets: targets)
    }
    
    public func atLevelWarning(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.warning, source: source, message: message, targets: targets)
    }
    
    public func atLevelError(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.error, source: source, message: message, targets: targets)
    }
    
    public func atLevelCritical(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.critical, source: source, message: message, targets: targets)
    }
    
    public func atLevelAlert(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.alert, source: source, message: message, targets: targets)
    }
    
    public func atLevelEmergency(source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.emergency, source: source, message: message, targets: targets)
    }

    public func atLevel(_ level: Level, id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(level, source: createSource(id, source), message: message, targets: targets)
    }

    public func atLevelDebug(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.debug, source: createSource(id, source), message: message, targets: targets)
    }
    
    public func atLevelInfo(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.info, source: createSource(id, source), message: message, targets: targets)
    }
    
    public func atLevelNotice(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.notice, source: createSource(id, source), message: message, targets: targets)
    }
    
    public func atLevelWarning(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.warning, source: createSource(id, source), message: message, targets: targets)
    }
    
    public func atLevelError(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.error, source: createSource(id, source), message: message, targets: targets)
    }
    
    public func atLevelCritical(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.critical, source: createSource(id, source), message: message, targets: targets)
    }
    
    public func atLevelAlert(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.alert, source: createSource(id, source), message: message, targets: targets)
    }
    
    public func atLevelEmergency(id: Int32, source: String, message: Any? = nil, targets: Set<Target> = Target.ALL) {
        putOnLoggingQueue(.emergency, source: createSource(id, source), message: message, targets: targets)
    }

    
    // MARK: - All private from here on
    
    // Conveniance
    
    private func createSource(_ id: Int32, _ source: String) -> String {
        return String(format: "%08x, %@", id, source)
    }

    private init() { // Guarantee a singleton usage of the logger
        
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
                
                // TODO: Comment out the next line if the network destination is not needed
                if let networkIpAddress = swifterLogOptions["networkIpAddress"] as? String {
                    if let networkPortNumber = swifterLogOptions["networkPortNumber"] as? String {
                        connectToNetworkTarget(NetworkTarget(networkIpAddress, networkPortNumber))
                    }
                }
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
        let networkEnabled  = targets.contains(.network)  && (networkTransmitAtAndAboveLevel <= level)
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


    static var logTimeFormatter: DateFormatter = {
        let ltf = DateFormatter()
        ltf.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
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
    }
    
    
    // Write log messages only from within this queue, that guarantees a non-overlapping behaviour even if multiple threads use the SwifterLog.
    
    private let loggingQueue = DispatchQueue(label: "logging-queue", attributes: DispatchQueueAttributes.serial)
    
    
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
        // TODO: Comment out the next line if the network destination is not needed
        if destinationNetwork {
            if networkQueue != nil {
                networkQueue!.async(execute: { [unowned self] in
                    self.logToNetwork(time, source: source, logLevel: logLevel, message: message)
                    })
            }
        }
        if destinationCallback {
            if callbackQueue == nil {
                callbackQueue = DispatchQueue(label: "callback-queue", attributes: DispatchQueueAttributes.serial)
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
                try fileManager.urlForDirectory(
                    FileManager.SearchPathDirectory.applicationSupportDirectory,
                    in: FileManager.SearchPathDomainMask.userDomainMask,
                    appropriateFor: nil,
                    create: true).path!
                
            let appName = ProcessInfo.processInfo.processName
            let dirUrl = try! URL(fileURLWithPath: applicationSupportDirectory, isDirectory: true).appendingPathComponent(appName)
            return try! dirUrl.appendingPathComponent("Logfiles").path

        } catch let error as NSError {
        
            let message: String = "Could not get application support directory, error = " + (error.localizedDescription ?? "Unknown reason")
            self.logToASL(Level.error, message: message)
            return nil
        }
    }()
    
    
    // Will be set to the URL of the logfile if the directory for the logfiles is available.
    
    private var logfileDirectoryURL: URL?
    
    
    // Creates a new logfile.
    
    private func createLogfile() -> FileHandle? {
        
        
        // Get the logfile directory
        
        if let logdir = (logfileDirectoryPath ?? applicationSupportLogfileDirectory) as? String {
            
            do {
                
                // Make sure the logfile directory exists

                try FileManager.default.createDirectory(atPath: logdir, withIntermediateDirectories: true, attributes: nil)
            
                logfileDirectoryURL = URL(fileURLWithPath: logdir, isDirectory: true) // For the logfile services
        
                let filename = "Log_" + SwifterLog.logTimeFormatter.string(from: Date()) + ".txt"
                
                let logfileUrl = try! URL(fileURLWithPath: logdir).appendingPathComponent(filename)
                
                if FileManager.default.createFile(atPath: logfileUrl.path!, contents: nil, attributes: [FileAttributeKey.posixPermissions.rawValue : NSNumber(value: 0o640)]) {
                    
                    return FileHandle(forUpdatingAtPath: logfileUrl.path!)

                } else {
                    
                    if !logfileErrorMessageGenerated {
                        let message = "Could not create logfile \(logfileUrl.path)"
                        logToASL(.error, message: message)
                        logfileErrorMessageGenerated = true
                    }
                }
                
            } catch let error as NSError {
                
                if !logdirErrorMessageGenerated {
                    let message = "Could not create logfile directory \(logdir), error = " + (error.localizedDescription ?? "Unknown reason")
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
                    let sortedFiles = files.sorted(isOrderedBefore: { $0.lastPathComponent < $1.lastPathComponent })
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
