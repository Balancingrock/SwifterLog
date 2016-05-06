# SwifterLog
A single class framework in Swift to create and manage log entries.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

SwifterLog is part of the 5 packages that make up the Swiftfire webserver:

#####[Swiftfire](https://github.com/Swiftrien/Swiftfire)

An open source web server in Swift.

#####[SwiftfireConsole](https://github.com/Swiftrien/SwiftfireConsole)

A GUI application for Swiftfire.

#####[SwifterSockets](https://github.com/Swiftrien/SwifterSockets)

General purpose socket utilities.

#####[SwifterJSON](https://github.com/Swiftrien/SwifterJSON)

General purpose JSON framework.

There is a 6th package called [SwiftfireTester](https://github.com/Swiftrien/SwiftfireTester) that can be used to challenge a webserver (any webserver) and see/verify the response.

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

#Usage
##As a Framework
Do use [Chartage](https://github.com/Carthage/Carthage) for this. Note that due to bug 22492040 Apple says: "_Frameworks written in Swift should be compiled from source as part of the same project that depends on them to guarantee a single, consistent compilation environment._", hence you will need to rebuild the framework to be sure. [Chartage](https://github.com/Carthage/Carthage) can do this for you.
If you use SwifterLog this way, you will also need the frameworks SwifterJSON and SwifterSockets.

##As Sourcecode

SwifterLog can be used in two ways: As a stand-alone framework and as a framework that is integrated with SwfterJSON and SwifterSockets.
1. Drop the 4 files: SwifterLog.swift, SwifterLogNetwork.swift, asl-bridge.m & asl-bridge.h into your project.
2. Configure your bridge file (or add one) like SwifterLog-Bridging-Header.h.
3. If you do not want/need the network destination, remove

#Version History

####V0.9.7:

- Changed target to a framework
- Added support for [Chartage](https://github.com/Carthage/Carthage)

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