# SwifterLog
A single class framework in Swift to create and manage log entries.

SwifterLog is part of the 5 packages that make up the Swiftfire webserver:

#####Swiftfire

An open source web server in Swift.

####SwiftfireConsole

A GUI application for Swiftfire.

####SwifterSockets

General purpose socket utilities.

####SwifterJSON

General purpose JSON framework.

There is a 6th package called SwiftfireTester that can be used to challenge a webserver (any webserver) and see/verify the response.

#Features

- 5 different logging destinations:
	1. The Apple System Log facility
	2. A file
	3. STDOUT (println)
	4. A network destination (Needs [SwifterJSON](https://github.com/Swiftrien/SwifterJSON))
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
Simply drop the file into your project, add the asl-bridge files, configure your app's bridge-headers and log away. More details are in the main class.

#Version History
V0.9.6:

- Included extension for type String to easily create a SOURCE identifier from a #file string.
- JSON code returned by 'json' changed from a value to a valid hierarchy.
- Added ALL_NON_RECURSIVE target definition.
- Updated for changes in SwifterSockets.Transmit

V0.9.5:

- Added transfer of log entries to a TCP/IP destination and targetting of error messages.
- Renamed logfileRecordAtAndAboveLevel to fileRecordAtAndAboveLevel
- Added call-back logging

V0.9.4

- Added conveniance functions that add the "ID" parameter back in as hexadecimal output before the source.
- Note: v0.9.4 was never released into the public.

V0.9.3: Updated for Swift 2.0