# SwifterLog
A single class framework in Swift to create and manage log entries.

SwifterLog is part of the 4 packages that make up the [Swiftfire](http://swiftfire.nl) webserver:

#####[Swiftfire](https://github.com/Swiftrien/Swiftfire)

An open source web server in Swift.

#####[SwifterSockets](https://github.com/Swiftrien/SwifterSockets)

General purpose socket utilities.

#####[SwifterJSON](https://github.com/Swiftrien/SwifterJSON)

General purpose JSON utility.

There is a 5th package called [SwiftfireTester](https://github.com/Swiftrien/SwiftfireTester) that can be used to challenge a webserver (any webserver) and see/verify the response.

#Features

- 5 different logging destinations:
	1. The Apple System Log facility
	2. A file
	3. STDOUT (println)
	4. A network destination
	5. A list of callback objects from the Application itself.
- 8 log levels, the same as defined for the Apple System Log facility:
	1. DEBUG
	2. INFO
	3. NOTICE
	4. WARNING
	5. ERROR
	6. CRITICAL
	7. ALERT
	8. EMERGENCY
- Each logging destination can have its own cut-off level for the information that is logged.
- The file destination can be configured to store the log info in a predefined number of files of a predefined maximum size. When the maximum number of files is exceeded, the oldest file will automaticaly be removed.
- Build with Swift 3 beta (Xcode 8 beta)

#Usage

Once SwifterLog has been installed, there is a global variable 'log' available on which all logging calls will be performed.
Example:

    log.atLevel(level: .DEBUG, id: logId, source: "My source identifier", message: "Error message", target: Target.ALL_NON_RECURSIVE)

The above is the full-monty, oftentimes it will be possible to use much shorter variants like:

    log.atLevelError(source: #function, message: self)

If 'self' is an object, then it is advantageous to let the class of 'self' implement the ReflectedStringConvertible protocol. This is a functionless protocol that will override the 'description' (CustomStringConvertible) with a much more meaningfull message than the default.

    class TestClass: ReflectedStringConvertible {
        var a: Int = 5
        var b: String = "B"
    }
    let c = TestClass()   
    log.atLevelInfo(source: "MyFunc", message: c)

The above will log the message:

    2016-05-29T12:56:30.072+0200, INFO     : MyFunc, (TestClass #1)(a: 5, b: B)

Setup of the logger is controlled through a couple of properties:

- __logfileDirectoryPath__: The path of the directory that will be used to store the logfiles.
- __logfileMaxSizeInBytes__: The maximum size of a logfile, once this size is exceeded, a new file will be started.
- __logfileMaxNumberOfFiles__: The maximum number of logfiles that will be created. The oldest logfile will automatically discarded when necessary.
- __fileRecordAtAndAboveLevel__: The minimum level which an entry should have to be stored in a logfile.
- __stdoutPrintAtAndAboveLevel__: The minimum level which an entry should have to send to the stdout destination.
- __aslFacilityRecordAtAndAboveLevel__: The minimum level which an entry should have to be be sent to the ASL Facility.
- __networkTransmitAtAndAboveLevel__: The minimum level which an entry should have to be transmitted to the network logging destination.
- __callbackAtAndAboveLevel__: The minimum level which an entry should have to be sent to the callback destinations.

These properties can be set through the application's plist or can be written to directly. Any change takes effect immediately.
    
#Installation

##Including the network destination
If you need the network destination, or want to get goiing without making modifications:

1. Drop the 4 files: SwifterLog.swift, SwifterLogNetwork.swift, asl-bridge.m & asl-bridge.h into your project.
2. Configure your bridge file (or add one) like SwifterLog-Bridging-Header.h.
3. Add the [SwifterSockets](https://github.com/Swiftrien/SwifterSockets) files to the project.

##Excluding the network destination
If you do not need the network destination or do not want to include SwifterSockets:

1. Drop the 3 files: SwifterLog.swift, asl-bridge.m & asl-bridge.h into your project.
2. Configure your bridge file (or add one) like SwifterLog-Bridging-Header.h.
3. Remove the call's SwifterLogNetwork from SwifterLog.swift (there are 2 of them, marked with "TODO"). If you don't like compiler warnings, you can remove the network support properties from SwifterLog.swift as well.

#Version History

Note: Planned releases are for information only, they are subject to change without notice.

####v1.1.0 (Open)

- No new features planned. Features and bugfixes will be made on an ad-hoc basis as needed to support Swiftfire development.
- For feature requests and bugfixes please contact rien@balancingrock.nl

####v1.0.0 (Planned)

- Upgrade to Swift 3

####v0.9.12 (Current)

- Upgraded to Swift 3 beta (Xcode 8)

####v0.9.11

- Update to accomodate VJson v0.9.8

####v0.9.10

- Update to accomodate VJson updates

####v0.9.9

- Added 'public' to the string extensions
- Added 'ReflectedStringConvertible' (Idea from [Matt Comi](https://github.com/mattcomi))
- Changed message parameter from 'String' to 'Any' on all logging calls (Inspired by [whitehat007](https://github.com/whitehat007))
- Fixed bug that would not call the callback destination for the very first logging message
- Added a few unit tests

####v0.9.8:

- Header update to include new website: [swiftfire.nl](http://swiftfire.nl)
- Renamed SwifterLogNetwork.swift to SwifterLog.Network.swift

####V0.9.7:

- Removed all targets
- Removed other unnecessary files
- Moved the network support to its own file (as far as possible).
- Added release tag

####V0.9.6:

- Included extension for type String to easily create a SOURCE identifier from a #file string.
- JSON code returned by 'json' changed from a value to a valid hierarchy.
- Added ALL_NON_RECURSIVE target definition.
- Updated for changes in SwifterSockets.Transmit

####V0.9.5:

- Added transfer of log entries to a TCP/IP destination and targetting of error messages.
- Renamed logfileRecordAtAndAboveLevel to fileRecordAtAndAboveLevel
- Added call-back logging

####V0.9.4

- Added conveniance functions that add the "ID" parameter back in as hexadecimal output before the source.
- Note: v0.9.4 was never released into the public.

####V0.9.3:
- Updated for Swift 2.0