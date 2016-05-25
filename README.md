# SwifterLog
A single class framework in Swift to create and manage log entries.

SwifterLog is part of the 5 packages that make up the [Swiftfire](http://swiftfire.nl) webserver:

#####[Swiftfire](https://github.com/Swiftrien/Swiftfire)

An open source web server in Swift.

#####[SwiftfireConsole](https://github.com/Swiftrien/SwiftfireConsole)

A GUI application for Swiftfire.

#####[SwifterSockets](https://github.com/Swiftrien/SwifterSockets)

General purpose socket utilities.

#####[SwifterJSON](https://github.com/Swiftrien/SwifterJSON)

General purpose JSON utility.

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