//
//  Public.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 30/07/2017.
//
//

import Foundation

public final class SwifterLog {
    

    /// Creates the date & time in the log info string.
    ///
    /// This formatter is used by the defaultFormatter.

    static public var logTimeFormatter: DateFormatter = {
        let ltf = DateFormatter()
        ltf.dateFormat = "yyyy-MM-dd'T'HH.mm.ss.SSSZ"
        return ltf
    }()


    /// This formatter is used to create the string for the log info.
    ///
    /// The default formatter is used -by default- by all targets.

    static public var formatter = SfFormatter()


    /// The ASL logger.
    ///
    /// Notice that this is a singleton, it is not possible to have multiple ASL loggers. This is a restriction of the Asl class, not of the ASL itself.

    static public var asl = Asl.singleton


    /// The default STDOut logger.
    ///
    /// This output will appear in the Xcode debug area or in a terminal window. Depending on how the app is run.

    static public var stdout = Stdout()


    /// The default file logger

    static public var logfiles = Logfiles()


    /// The default callback logger

    static public var callback = Callback()


#if SWIFTERLOG_DISABLE_NETWORK_TARGET

    /// A set containing all targets
    
    static public let allTargets: Array<Target> = [stdout, logfiles, asl, callback]

    
    /// A set containing all targets except the callback
    
    static public let allTargetsExceptCallback: Array<Target> = [stdout, logfiles, asl]

    
    /// A set containing all targets except the ASL
    
    static public let allTargetsExceptAsl: Array<Target> = [stdout, logfiles, callback]

#else
    
    /// The default network logger

    static public var network = Network()

    
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

    public final class Logger {
        private let level: Level
        private init(_ level: Level) { self.level = level }
        fileprivate static let debugLogger = Logger(Level.Debug)
        fileprivate static let infoLogger = Logger(Level.Info)
        fileprivate static let noticeLogger = Logger(Level.Notice)
        fileprivate static let warningLoger = Logger(Level.Warning)
        fileprivate static let errorLogger = Logger(Level.Error)
        fileprivate static let criticalLogger = Logger(Level.Critical)
        fileprivate static let alertLogger = Logger(Level.Alert)
        fileprivate static let emergencyLogger = Logger(Level.Emergency)
        public func log(at level:Level, from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
            theLogger.atLevel(level, from: source, to: targets, message: message)
        }
    }

    
    /// Convenience interface to the level debug.
    ///
    /// This interface has performance advantages when the debug level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atDebug?.log(...)

    static public var atDebug: Logger?


    /// Conveniece interface to the level info.
    ///
    /// This interface has performance advantages when the info level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atInfo?.log(...)

    static public var atInfo: Logger?


    /// Conveniece interface to the level notice.
    ///
    /// This interface has performance advantages when the notice level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atNotice?.log(...)

    static public var atNotice: Logger?


    /// Conveniece interface to the level warning.
    ///
    /// This interface has performance advantages when the warning level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atWarning?.log(...)

    static public var atWarning: Logger?


    /// Conveniece interface to the level error.
    ///
    /// This interface has performance advantages when the error level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atError?.log(...)

    static public var atError: Logger?


    /// Conveniece interface to the level critical.
    ///
    /// This interface has performance advantages when the notice level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atCritical?.log(...)

    static public var atCritical: Logger?


    /// Conveniece interface to the level alert.
    ///
    /// This interface has performance advantages when the warning level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atAlert?.log(...)

    static public var atAlert: Logger?


    /// Conveniece interface to the level emergency.
    ///
    /// This interface has performance advantages when the error level is disabled, as it will not evaluate the arguments before the logging call is made. However it must always be called using optional chaining: atEmergency?.log(...)

    static public var atEmergency: Logger?
    
    
    /// Synchronize the optional loggers availability with the level of self.
        
    fileprivate func setLoggersFor(_ level: Level) {
            
        if level == Level.Debug {
            
            SwifterLog.atDebug = Logger.debugLogger
            SwifterLog.atInfo = Logger.infoLogger
            SwifterLog.atNotice = Logger.noticeLogger
            SwifterLog.atWarning = Logger.warningLoger
            SwifterLog.atError = Logger.errorLogger
            SwifterLog.atCritical = Logger.criticalLogger
            SwifterLog.atAlert = Logger.alertLogger
            SwifterLog.atEmergency = Logger.emergencyLogger
        
        } else if level == Level.Info {
            
            SwifterLog.atDebug = nil
            SwifterLog.atInfo = Logger.infoLogger
            SwifterLog.atNotice = Logger.noticeLogger
            SwifterLog.atWarning = Logger.warningLoger
            SwifterLog.atError = Logger.errorLogger
            SwifterLog.atCritical = Logger.criticalLogger
            SwifterLog.atAlert = Logger.alertLogger
            SwifterLog.atEmergency = Logger.emergencyLogger
                
        } else if level == Level.Notice {
            
            SwifterLog.atDebug = nil
            SwifterLog.atInfo = nil
            SwifterLog.atNotice = Logger.noticeLogger
            SwifterLog.atWarning = Logger.warningLoger
            SwifterLog.atError = Logger.errorLogger
            SwifterLog.atCritical = Logger.criticalLogger
            SwifterLog.atAlert = Logger.alertLogger
            SwifterLog.atEmergency = Logger.emergencyLogger
                
        } else if level == Level.Warning {
            
            SwifterLog.atDebug = nil
            SwifterLog.atInfo = nil
            SwifterLog.atNotice = nil
            SwifterLog.atWarning = Logger.warningLoger
            SwifterLog.atError = Logger.errorLogger
            SwifterLog.atCritical = Logger.criticalLogger
            SwifterLog.atAlert = Logger.alertLogger
            SwifterLog.atEmergency = Logger.emergencyLogger
                
        } else if level == Level.Error {
 
            SwifterLog.atDebug = nil
            SwifterLog.atInfo = nil
            SwifterLog.atNotice = nil
            SwifterLog.atWarning = nil
            SwifterLog.atError = Logger.errorLogger
            SwifterLog.atCritical = Logger.criticalLogger
            SwifterLog.atAlert = Logger.alertLogger
            SwifterLog.atEmergency = Logger.emergencyLogger
            
        } else if level == Level.Critical {
            
            SwifterLog.atDebug = nil
            SwifterLog.atInfo = nil
            SwifterLog.atNotice = nil
            SwifterLog.atWarning = nil
            SwifterLog.atError = nil
            SwifterLog.atCritical = Logger.criticalLogger
            SwifterLog.atAlert = Logger.alertLogger
            SwifterLog.atEmergency = Logger.emergencyLogger
                
        } else if level == Level.Alert {
 
            SwifterLog.atDebug = nil
            SwifterLog.atInfo = nil
            SwifterLog.atNotice = nil
            SwifterLog.atWarning = nil
            SwifterLog.atError = nil
            SwifterLog.atCritical = nil
            SwifterLog.atAlert = Logger.alertLogger
            SwifterLog.atEmergency = Logger.emergencyLogger
                
        } else if level == Level.Emergency {
 
            SwifterLog.atDebug = nil
            SwifterLog.atInfo = nil
            SwifterLog.atNotice = nil
            SwifterLog.atWarning = nil
            SwifterLog.atError = nil
            SwifterLog.atCritical = nil
            SwifterLog.atAlert = nil
            SwifterLog.atEmergency = Logger.emergencyLogger
                
        } else if level == Level.None {
 
            SwifterLog.atDebug = nil
            SwifterLog.atInfo = nil
            SwifterLog.atNotice = nil
            SwifterLog.atWarning = nil
            SwifterLog.atError = nil
            SwifterLog.atCritical = nil
            SwifterLog.atAlert = nil
            SwifterLog.atEmergency = nil
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
    ///
    /// - Note: SwifterLog itself can write messages to the ASL at level ERROR if necessary. If the threshold is set higher than ERROR SwifterLog will fail silently.
    
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
        level.record(source, targets, message)
    }
    
    
    /// Logs a message at level Debug.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevelDebug(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Level.Debug.record(source, targets, message)
    }
    
    
    /// Logs a message at level Info.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevelInfo(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Level.Info.record(source, targets, message)
    }
    
    
    /// Logs a message at level Notice.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevelNotice(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Level.Notice.record(source, targets, message)
    }
    
    
    /// Logs a message at level Warning.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevelWarning(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Level.Warning.record(source, targets, message)
    }
    
    
    /// Logs a message at level Error.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevelError(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Level.Error.record(source, targets, message)
    }

    /// Logs a message at level Critical.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevelCritical(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Level.Critical.record(source, targets, message)
    }
    
    
    /// Logs a message at level Alert.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevelAlert(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Level.Alert.record(source, targets, message)
    }
    
    
    /// Logs a message at level Emergency.
    ///
    /// - Parameters:
    ///   - from: The source of the message.
    ///   - to: The targets to record to (Default = allTargets).
    ///   - message: The data to be recorded (Default = nil).
    
    public func atLevelEmergency(from source: Source, to targets: Array<Target> = allTargets, message: Any? = nil) {
        Level.Emergency.record(source, targets, message)
    }
    
    
    // MARK: - All private from here on
    
    fileprivate init() { // Guarantee a singleton usage of the logger
        
        // Try to read the settings from the app's Info.plist
        
        if  let infoPlist = Bundle.main.infoDictionary,
            let swifterLogOptions = infoPlist["SwifterLog"] as? Dictionary<String, AnyObject> {
            
            if let alsThreshold = swifterLogOptions["aslFacilityRecordAtAndAboveLevel"] as? NSNumber {
                if alsThreshold.intValue >= Level.Debug.value && alsThreshold.intValue <= Level.None.value {
                    SwifterLog.asl.threshold = Level.factory(alsThreshold.intValue)!
                } else {
                    SwifterLog.asl.record(Level.Error, Source(), "Info.plist value for aslFacilityRecordAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let stdoutThreshold = swifterLogOptions["stdoutPrintAtAndAboveLevel"] as? NSNumber {
                if stdoutThreshold.intValue >= Level.Debug.value && stdoutThreshold.intValue <= Level.None.value {
                    stdoutPrintAtAndAboveLevel = Level.factory(stdoutThreshold.intValue)!
                } else {
                    SwifterLog.asl.record(Level.Error, Source(), "Info.plist value for stdoutPrintAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let logfileThreshold = swifterLogOptions["fileRecordAtAndAboveLevel"] as? NSNumber {
                if logfileThreshold.intValue >= Level.Debug.value && logfileThreshold.intValue <= Level.None.value {
                    fileRecordAtAndAboveLevel = Level.factory(logfileThreshold.intValue)!
                } else {
                    SwifterLog.asl.record(Level.Error, Source(), "Info.plist value for fileRecordAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let networkThreshold = swifterLogOptions["networkTransmitAtAndAboveLevel"] as? NSNumber {
                if networkThreshold.intValue >= Level.Debug.value && networkThreshold.intValue <= Level.None.value {
                    networkTransmitAtAndAboveLevel = Level.factory(networkThreshold.intValue)!
                } else {
                    SwifterLog.asl.record(Level.Error, Source(), "Info.plist value for networkTransmitAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let callbackThreshold = swifterLogOptions["callbackAtAndAboveLevel"] as? NSNumber {
                if callbackThreshold.intValue >= Level.Debug.value && callbackThreshold.intValue <= Level.None.value {
                    callbackAtAndAboveLevel = Level.factory(callbackThreshold.intValue)!
                } else {
                    SwifterLog.asl.record(Level.Error, Source(), "Info.plist value for callbackAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                }
            }
            
            if let logfileMaxSize = swifterLogOptions["logfileMaxSizeInBytes"] as? NSNumber {
                if logfileMaxSize.intValue >= 10 * 1024 && logfileMaxSize.intValue <= 100 * 1024 * 1024 {
                    SwifterLog.logfiles.maxSizeInBytes = UInt64(logfileMaxSize.intValue)
                } else {
                    SwifterLog.asl.record(Level.Error, Source(), "Info.plist value for logfileMaxSizeInBytes in SwifterLog out of bounds (10kB .. 100MB)")
                }
            }
            
            if let logfileNofFiles = swifterLogOptions["logfileMaxNumberOfFiles"] as? NSNumber {
                if logfileNofFiles.intValue >= 2 && logfileNofFiles.intValue <= 1000 {
                    SwifterLog.logfiles.maxNumberOfFiles = logfileNofFiles.intValue
                } else {
                    SwifterLog.asl.record(Level.Error, Source(), "Info.plist value for logfileMaxNumberOfFiles in SwifterLog out of bounds (2 .. 1000)")
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
    
    private var overallThreshold = Level.Debug
    
    
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

