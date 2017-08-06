// =====================================================================================================================
//
//  File:       Public.swift
//  Project:    SwifterLog
//
//  Version:    2.0.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2017 Marinus van der Lugt, All rights reserved.
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
// Provides a ready made logger to be used in a project.
//
// Notice that it is not necessary to use this logger. It is provided as a convenience and as an example.
//
// The static instance (singleton) is a meta-logger. That is, it collects a number of other loggers and offers some
// common operations. Especially the threshold level settings in the included targets should be done through the level
// operations provided in the meta logger. Otherwise unexpected side effects may occur for the optimised
//
// =====================================================================================================================
//
// History:
// 2.0.0 -  Completely rewritten from 1.0.0
//
// =====================================================================================================================

import Foundation


internal var sfQueue = DispatchQueue(label: "SwifterLog", qos: .default, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: .inherit, target: nil)


public final class SwifterLog {


    /// This formatter is used to create the string for the log info.
    ///
    /// The default formatter is used -by default- by all targets.

    static public var formatter = SfFormatter()


    /// The ASL logger.
    ///
    /// Notice that this is a singleton, it is not possible to have multiple ASL loggers. This is a restriction of the Asl class, not of the ASL itself.
    ///
    /// - Note: Do not change the threshold of this target directly, instead, change it through the parameter `aslFacilityRecordAtAndAboveLevel` of `theLogger`. Failure to do so will cause the loggers-instances to become desynchronised with the level settings.

    static public let asl = Asl.singleton


    /// The default STDOut logger.
    ///
    /// This output will appear in the Xcode debug area or in a terminal window. Depending on how the app is run.
    ///
    /// - Note: Do not change the threshold of this target directly, instead, change it through the parameter `stdoutPrintAtAndAboveLevel` of `theLogger`. Failure to do so will cause the loggers-instances to become desynchronised with the level settings.

    static public let stdout = Stdout()


    /// The default file logger
    ///
    /// - Note: Do not change the threshold of this target directly, instead, change it through the parameter `fileRecordAtAndAboveLevel` of `theLogger`. Failure to do so will cause the loggers-instances to become desynchronised with the level settings.

    static public let logfiles = Logfiles()


    /// The default callback logger
    ///
    /// - Note: Do not change the threshold of this target directly, instead, change it through the parameter `callbackAtAndAboveLevel` of `theLogger`. Failure to do so will cause the loggers-instances to become desynchronised with the level settings.

    static public let callback = Callback()


#if SWIFTERLOG_DISABLE_NETWORK_TARGET

    /// A set containing all targets
    
    static public let allTargets: Array<Target> = [stdout, logfiles, asl, callback]

    
    /// A set containing all targets except the callback
    
    static public let allTargetsExceptCallback: Array<Target> = [stdout, logfiles, asl]

    
    /// A set containing all targets except the ASL
    
    static public let allTargetsExceptAsl: Array<Target> = [stdout, logfiles, callback]

#else
    
    /// The default network logger

    static public let network = Network()

    
    /// A set containing all targets
    
    static public let allTargets: Array<Target> = [stdout, logfiles, asl, network, callback]

    
    /// A set containing all targets
    
    static public let allTargetsExceptNetwork: Array<Target> = [stdout, logfiles, asl, callback]

    
    /// A set containing all targets except the callback
    
    static public let allTargetsExceptCallback: Array<Target> = [stdout, logfiles, asl, network]

    
    /// A set containing all targets except the ASL
    
    static public let allTargetsExceptAsl: Array<Target> = [stdout, logfiles, network, callback]

#endif


    /// If an application needs just one logger, use this singleton.
    ///
    /// - Note: This singleton is also used by the high-performance loggers.

    static public let theLogger = SwifterLog()


    /// The base class for the high performance loggers

    public final class Loggers {
        private let level: Level
        private init(_ level: Level) { self.level = level }
        internal static let atDebug = Loggers(Level.debug)
        internal static let atInfo = Loggers(Level.info)
        internal static let atNotice = Loggers(Level.notice)
        internal static let atWarning = Loggers(Level.warning)
        internal static let atError = Loggers(Level.error)
        internal static let atCritical = Loggers(Level.critical)
        internal static let atAlert = Loggers(Level.alert)
        internal static let atEmergency = Loggers(Level.emergency)
        public func log(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
            theLogger.atLevel(level, from: source, to: targets, message: message)
        }
    }

    
    /// Convenience interface to the level debug.
    ///
    /// This interface has performance advantages when the debug level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atDebug?.log(...)

    static public var atDebug: Loggers?


    /// Conveniece interface to the level info.
    ///
    /// This interface has performance advantages when the info level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atInfo?.log(...)

    static public var atInfo: Loggers?


    /// Conveniece interface to the level notice.
    ///
    /// This interface has performance advantages when the notice level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atNotice?.log(...)

    static public var atNotice: Loggers?


    /// Conveniece interface to the level warning.
    ///
    /// This interface has performance advantages when the warning level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atWarning?.log(...)

    static public var atWarning: Loggers?


    /// Conveniece interface to the level error.
    ///
    /// This interface has performance advantages when the error level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atError?.log(...)

    static public var atError: Loggers?


    /// Conveniece interface to the level critical.
    ///
    /// This interface has performance advantages when the notice level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atCritical?.log(...)

    static public var atCritical: Loggers?


    /// Conveniece interface to the level alert.
    ///
    /// This interface has performance advantages when the warning level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atAlert?.log(...)

    static public var atAlert: Loggers?


    /// Conveniece interface to the level emergency.
    ///
    /// This interface has performance advantages when the error level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atEmergency?.log(...)

    static public var atEmergency: Loggers?
    
    
    /// Synchronize the optional loggers availability with the level of self.
        
    fileprivate func setLoggersFor(_ level: Level) {
        
        SwifterLog.atDebug = nil
        SwifterLog.atInfo = nil
        SwifterLog.atNotice = nil
        SwifterLog.atWarning = nil
        SwifterLog.atError = nil
        SwifterLog.atCritical = nil
        SwifterLog.atAlert = nil
        SwifterLog.atEmergency = nil

        switch level {
        case .debug: SwifterLog.atDebug = Loggers.atDebug; fallthrough
        case .info: SwifterLog.atInfo = Loggers.atInfo; fallthrough
        case .notice: SwifterLog.atNotice = Loggers.atNotice; fallthrough
        case .warning: SwifterLog.atWarning = Loggers.atWarning; fallthrough
        case .error: SwifterLog.atError = Loggers.atError; fallthrough
        case .critical: SwifterLog.atCritical = Loggers.atCritical; fallthrough
        case .alert: SwifterLog.atAlert = Loggers.atAlert; fallthrough
        case .emergency: SwifterLog.atEmergency = Loggers.atEmergency; fallthrough
        case .none: break
        }
    }
    
 
    // MARK: - Loglevel control
    
    /// Only messages with a level at or above the level specified in this variable will be written to STDOUT. Set to "SwifterLog.Level.NONE" to suppress all messages to STDOUT.
    
    public var stdoutPrintAtAndAboveLevel: Level {
        set {
            SwifterLog.stdout.threshold = newValue
            self.setOverallThreshold()
        }
        get {
            return SwifterLog.stdout.threshold
        }
    }
    
    
    /// Only messages with a level at or above the level specified in this variable will be recorded in the logfile. Set to "SwifterLog.Level.NONE" to suppress all messages to the logfile.
    
    public var fileRecordAtAndAboveLevel: Level  {
        set {
            SwifterLog.logfiles.threshold = newValue
            self.setOverallThreshold()
        }
        get {
            return SwifterLog.logfiles.threshold
        }
    }
    
    
    /// Only messages with a level at or above the level specified in this variable will be recorded by the Apple System Log Facility. Set to "SwifterLog.Level.NONE" to suppress all messages to the ASL(F).
    ///
    /// - Note: The ASL log entries can be viewed with the "System Information.app" that is available in the "Applications/Utilities" folder. Also note that the configuration file at "/etc/asl.conf" suppresses all messages at levels DEBUG and INFO by default irrespective of the value of this variable.
    
    public var aslFacilityRecordAtAndAboveLevel: Level {
        set {
            SwifterLog.asl.threshold = newValue
            self.setOverallThreshold()
        }
        get {
            return SwifterLog.asl.threshold
        }
    }
    
    
    /// Only messages with a level at or above the level specified in this variable will be transferred to the network destination. Set to "SwifterLog.Level.NONE" to suppress transmission of all messages to the network destination.
    
    public var networkTransmitAtAndAboveLevel: Level {
        set {
            SwifterLog.network.threshold = newValue
            self.setOverallThreshold()
        }
        get {
            return SwifterLog.network.threshold
        }
    }
    
    
    /// Only messages with a level at or above the level specified in this variable will be transferred to the callback destination(s). Set to "SwifterLog.Level.NONE" to suppress transmission of all messages to the callback destination(s).
    
    public var callbackAtAndAboveLevel: Level {
        set {
            SwifterLog.callback.threshold = newValue
            self.setOverallThreshold()
        }
        get {
            return SwifterLog.callback.threshold
        }
    }
    
    
    // MARK: - Logging functions
    
    
    /// Logs a message.
    ///
    /// - Parameters:
    ///   - level: Write the log message to destinations at or below this level.
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevel(_ level: Level, from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        switch level {
        case .debug: Loggers.atDebug.log(from: source, to: targets, message: message)
        case .info: Loggers.atInfo.log(from: source, to: targets, message: message)
        case .notice: Loggers.atNotice.log(from: source, to: targets, message: message)
        case .warning: Loggers.atWarning.log(from: source, to: targets, message: message)
        case .error: Loggers.atError.log(from: source, to: targets, message: message)
        case .critical: Loggers.atCritical.log(from: source, to: targets, message: message)
        case .alert: Loggers.atAlert.log(from: source, to: targets, message: message)
        case .emergency: Loggers.atEmergency.log(from: source, to: targets, message: message)
        case .none: break
        }
    }
    
    
    /// Logs a message at level Debug.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atDebug(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Loggers.atDebug.log(from: source, to: targets, message: message)
    }
    
    
    /// Logs a message at level Info.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atInfo(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Loggers.atInfo.log(from: source, to: targets, message: message)
    }
    
    
    /// Logs a message at level Notice.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atNotice(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Loggers.atNotice.log(from: source, to: targets, message: message)
    }
    
    
    /// Logs a message at level Warning.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atWarning(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Loggers.atWarning.log(from: source, to: targets, message: message)
    }
    
    
    /// Logs a message at level Error.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atError(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Loggers.atError.log(from: source, to: targets, message: message)
    }

    /// Logs a message at level Critical.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atCritical(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Loggers.atCritical.log(from: source, to: targets, message: message)
    }
    
    
    /// Logs a message at level Alert.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atAlert(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Loggers.atAlert.log(from: source, to: targets, message: message)
    }
    
    
    /// Logs a message at level Emergency.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atEmergency(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Loggers.atEmergency.log(from: source, to: targets, message: message)
    }
    
    
    // MARK: - All private from here on
    
    fileprivate init() { // Guarantee a singleton usage of the logger
        
        // Try to read the settings from the app's Info.plist
        
        if  let infoPlist = Bundle.main.infoDictionary,
            let swifterLogOptions = infoPlist["SwifterLog"] as? Dictionary<String, AnyObject> {
            
            if let alsThreshold = swifterLogOptions["aslFacilityRecordAtAndAboveLevel"] as? NSNumber {
                if alsThreshold.intValue >= Level.debug.value && alsThreshold.intValue <= Level.none.value {
                    SwifterLog.asl.threshold = Level.factory(alsThreshold.intValue)!
                } else {
                    SwifterLog.asl.log(Level.error, Source(), "Info.plist value for aslFacilityRecordAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let stdoutThreshold = swifterLogOptions["stdoutPrintAtAndAboveLevel"] as? NSNumber {
                if stdoutThreshold.intValue >= Level.debug.value && stdoutThreshold.intValue <= Level.none.value {
                    stdoutPrintAtAndAboveLevel = Level.factory(stdoutThreshold.intValue)!
                } else {
                    SwifterLog.asl.log(Level.error, Source(), "Info.plist value for stdoutPrintAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let logfileThreshold = swifterLogOptions["fileRecordAtAndAboveLevel"] as? NSNumber {
                if logfileThreshold.intValue >= Level.debug.value && logfileThreshold.intValue <= Level.none.value {
                    fileRecordAtAndAboveLevel = Level.factory(logfileThreshold.intValue)!
                } else {
                    SwifterLog.asl.log(Level.error, Source(), "Info.plist value for fileRecordAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let networkThreshold = swifterLogOptions["networkTransmitAtAndAboveLevel"] as? NSNumber {
                if networkThreshold.intValue >= Level.debug.value && networkThreshold.intValue <= Level.none.value {
                    networkTransmitAtAndAboveLevel = Level.factory(networkThreshold.intValue)!
                } else {
                    SwifterLog.asl.log(Level.error, Source(), "Info.plist value for networkTransmitAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let callbackThreshold = swifterLogOptions["callbackAtAndAboveLevel"] as? NSNumber {
                if callbackThreshold.intValue >= Level.debug.value && callbackThreshold.intValue <= Level.none.value {
                    callbackAtAndAboveLevel = Level.factory(callbackThreshold.intValue)!
                } else {
                    SwifterLog.asl.log(Level.error, Source(), "Info.plist value for callbackAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let logfileMaxSize = swifterLogOptions["logfileMaxSizeInBytes"] as? NSNumber {
                if logfileMaxSize.intValue >= 10 * 1024 && logfileMaxSize.intValue <= 100 * 1024 * 1024 {
                    SwifterLog.logfiles.maxSizeInBytes = UInt64(logfileMaxSize.intValue)
                } else {
                    SwifterLog.asl.log(Level.error, Source(), "Info.plist value for logfileMaxSizeInBytes in SwifterLog out of bounds (10kB .. 100MB)")
                }
            }
            
            if let logfileNofFiles = swifterLogOptions["logfileMaxNumberOfFiles"] as? NSNumber {
                if logfileNofFiles.intValue >= 2 && logfileNofFiles.intValue <= 1000 {
                    SwifterLog.logfiles.maxNumberOfFiles = logfileNofFiles.intValue
                } else {
                    SwifterLog.asl.log(Level.error, Source(), "Info.plist value for logfileMaxNumberOfFiles in SwifterLog out of bounds (2 .. 1000)")
                }
            }
            
            if let logfileDirPath = swifterLogOptions["logfileDirectoryPath"] as? String {
                SwifterLog.logfiles.directoryPath = logfileDirPath
            }
            
            #if SWIFTERLOG_DISABLE_NETWORK_TARGET
            #else
                if let networkIpAddress = swifterLogOptions["networkIpAddress"] as? String {
                    if let networkPortNumber = swifterLogOptions["networkPortNumber"] as? String {
                        SwifterLog.network.connectToNetworkTarget(Network.NetworkTarget(networkIpAddress, networkPortNumber))
                    }
                }
            #endif
        }
    }
    
    
    // For a slight performance gain
    
    private var overallThreshold = Level.debug
    
    
    // Should be called on every update to any of the thresholds.
    
    private func setOverallThreshold() {
        var newThreshold = stdoutPrintAtAndAboveLevel
        if newThreshold > aslFacilityRecordAtAndAboveLevel { newThreshold = aslFacilityRecordAtAndAboveLevel }
        if newThreshold > fileRecordAtAndAboveLevel { newThreshold = fileRecordAtAndAboveLevel }
        if newThreshold > networkTransmitAtAndAboveLevel { newThreshold = networkTransmitAtAndAboveLevel }
        if newThreshold > callbackAtAndAboveLevel { newThreshold = callbackAtAndAboveLevel }
        overallThreshold = newThreshold
        setLoggersFor(newThreshold)
    }
}

