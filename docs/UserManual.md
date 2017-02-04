# User Manual

## Jump start

The framework defines a global variable called `log`. Use this variable to access all logging functions.

Before using the logging functions, first setup the log level thresholds for the targets. In code this is done as follows:

    log.stdoutPrintAtAndAboveLevel = .debug
    log.fileRecordAtAndAboveLevel = .notice
    log.aslFacilityRecordAtAndAboveLevel = .warning
    log.networkTransmitAtAndAboveLevel = .none
    log.callbackAtAndAboveLevel = .none

Of course the default is `.none`, thus it is not necessary to assign `.none` to unused targets.

After the threshold levels are set, use the log as follows:

    log.atLevelError(id: logId, source: "My source identifier", message: "Error message")
or

    log.atLevelDebug(id: logId, source: #file.source(#function, #line), message: myVariable)

or alternatively without the id parameter:

    log.atLevelInfo(source: "My source identifier", message: myObject)
or

    log.atLevelNotice(source: #file.source(#function, #line), message: "Error message")

For best layout in the log, either always use the ID parameter, or never us it.

The ID parameter can be used to differentiate between objects, sockets, threads etc. Set it to -1 if IDs are used but there is no such id present in a specific case.

The source parameter is intended to give a code location from where the log entry was made.

The message parameter is defined as Any. It uses the `description` method to display the information in the item. It is recommended to add the protocol `ReflectedStringConvertible` to objects for an auto generated reflection based description.

## Targets

SwifterLog defines 5 targets that can receive the information from the logging calls:

- STDOUT
- File
- Apple System Log (ASL)
- Network
- Callback

Each of these targets is configured individually. To disable a target set its threshold level to `.none`.

Each logging call has a parameter called `targets`. This can contain a set of targets that determine where the infomation should be written to (assuming the level is sufficient). By default all targets are included.

### STDOUT

This is the traditional console output. It can be seen in the console when the application is run, but more often this will be used to write information to the Xcode debugger console.

The threshold level is set through: `log.stdoutPrintAtAndAboveLevel`

### File

The file target writes information to file. Multiple files in fact.

The threshold level is set through: `log.fileRecordAtAndAboveLevel`

After the logfile exceeds a predefined value (`logfileMaxSizeInBytes`) the logger automatically creates a new logfile. This size can be configured:

    log.logfileMaxSizeInBytes = 1 * 1024 * 1024

the default size is 1 MByte.

The name of the logfile starts with a timestamp, thus it is always clear which logfile was created when.

Once the number of logfiles exceeds a predefined value (`logfileMaxNumberOfFiles`) the logger automatically deletes the oldest logfile. This prevents the filesystem from filling up. The number of logfiles can be configured:

    log.logfileMaxNumberOfFiles = 20

the default value is 20.

The minimum value for the `logfileMaxNumberOfFiles` is 2. It is not possible to set a lower value.

The location for the logfiles can be configured:

    log.logfileDirectoryPath = nil

the default value is `nil`. A nil value means that the logfiles will be written to:

/Library/Application Support/<Application Name>/Logfiles

Where <Application Name> is of course substituted with the name of the application.

_Note_: When running under Xcode the default logfile location is different:

/Library/Containers/<bundle identifier>/Data/Library/Application Support/<app name>/Logfiles

__Warning__: When using a different path for the logfiles make sure the app has write access to that location. Also make sure that this write access persists between sessions.

### Apple System Log

The Apple System Log can be viewed with the console application in the system utilties.

The threshold level is set through: `log.aslFacilityRecordAtAndAboveLevel`

The ASL has multiple places that control which information is logged, besides the settings in SwifterLog.

By default the ASL only shows loglevel at the level `.notice` or above.

The main switch can be seen (and set) with the `syslog` command line utility.

    > syslog -c 0
    Master filter mask: Off

There is also a process switch which can be seen (and set) with the `syslog` command line utility.

First you will have to find the process number (pid) with:

    > ps ax | grep <app name> | grep -v grep

The first number on the line is the pid.

To see the switch for that pid:

    > syslog -c 1726
    Process 1726 syslog filter mask: Off

Unless these switches were set explicitly they are unlikely to be active.

The file `/etc/asl.conf` contains the default configuration for the system log. It is this file that specifies the minimum level of `.notice` for the ASL target. Regardless of the settings of SwifterLog.

### Network

The threshold level is set through: `log.networkTransmitAtAndAboveLevel`

The network destination is set by calling the operation:

    log.connectToNetworkTarget(address: "myserver.com", port: "3897")

Of course there should be a server running at that destination to receive the information.

To use the network destination the frameworks SwifterJSON and SwifterSockets are necessary. These are installed by default.

The information is transmitted as a small JSON record. An example:

    {"LogLine":{"Time":<timestamp>,"Level":<loglevel>,"Source":<source>,"Message":<message>}}
    
All of the data fields are in fact strings.

__Warning__: If a network target is too slow, logging messages will stack up in the logger. Leading to increased use of system resources that could eventually crash the applications.

Be aware of privacy issues when using a network target!

Always ask the end-user before activation!

### Callback

The callback target is an object in the main application that implements the `SwifterlogCallbackProtocol`.

The threshold level is set through: `log.callbackAtAndAboveLevel`

A callback target is set as follows:

    log.registerCallback(aCallbackReceiver)

It can be uninstalled by:

    log.removeCallback(aCallbackReceiver)

Note that from within the callback there should be no logging entries made that include the callback target!

__Warning__: If a callback target is too slow, logging messages will stack up in the logger. Leading to increased use of system resources that could eventually crash the applications.

## Levels

SwiftLog uses the same levels as the Apple System Log:

- Debug (lowest level)
- Info
- Notice (lowest level that appears in the ASL by default)
- Warning
- Error
- Critical
- Alert
- Emergency

While there are many interpretations possible, the following suggestions may be helpful:

### Debug

Use this level when working in xcode during programming / debugging.

Example: "MyClass.myFunc: started" or "myParameter = 42"
        
### Info        
        
Use this level while still working on the project, but a decent level of confidence in the code correctness is present. For example during GUI level test/debugging.

Example: "User clicked commit" or "Image XYZ loaded in MyClass"
        
### Notice        
        
Use this level to record information that might help you helping a user that experiences problems with the product.

Example: "Connection with server established" or "Set image correction to ALWAYS"
        
### Warning        
        
Use this level to record information that might help a user to solve a problem or help with understanding the product's behaviour.

Example: "Option HIGHLIGHT no longer supported" or "Data after end-of-data marker ignored"

### Error        
        
Use this level to record information that explains why something was wrong and the product (possibly) failed to perform as expected. However future performance of the product should be unaffected.

Example: "Cannot load file format XYZ" or "Data does not contain XYZ"
        
### Critical        
        
Use this level to record information that explains why future performance of the product will be affected (unless corrective action is taken).

Example: "Cannot save file, disk is full" or "Transfer interrupted"

### Alert        
        
Use this level to alert the end-user to possible security violations.

Example: Like somebody failing the password more than N times.
        
### Emergency        
        
Use this level as a last ditch effort to record some information that might explain why the application crashed.

## Info.plist

Before using the logging functions make sure the loglevels are setup correctly. By default none of the destinations is enabled for logging.

SwifterLog can of course be completely set up in source code.

But it is also possible to use the Info.plist.

To do so, create a dictionary entry in the plist and give it the name SwifterLog. Then add from the entries listed below. Only add those entries that are needed. 

The following table lists the keys and the values:

<table>
<tr>
	<th>Key</th>
	<th>Type</th>
	<th>Range</th>
	<th>Default when absent</th>
</tr>
<tr>
	<td>SwifterLog</td>
	<td>Dictionary</td>
	<td>The other items</td>
	<td>-</td>
</tr>
<tr>
	<td>aslFacilityRecordAtAndAboveLevel</td>
	<td>Number</td>
	<td>0...8</td>
	<td>.none (8)</td>
</tr>
<tr>
	<td>stdoutPrintAtAndAboveLevel</td>
	<td>Number</td>
	<td>0...8</td>
	<td>.none (8)</td>
</tr>
<tr>
	<td>fileRecordAtAndAboveLevel</td>
	<td>Number</td>
	<td>0...8</td>
	<td>.none (8)</td>
</tr>
<tr>
	<td>networkTransmitAtAndAboveLevel</td>
	<td>Number</td>
	<td>0...8</td>
	<td>.none (8)</td>
</tr>
<tr>
	<td>callbackAtAndAboveLevel</td>
	<td>Number</td>
	<td>0...8</td>
	<td>.none (8)</td>
</tr>
<tr>
	<td>logfileDirectoryPath</td>
	<td>String</td>
	<td>RFC 2396</td>
	<td>"/Library/Application Support/[AppName]/Logfiles"</td>
</tr>
<tr>
	<td>logfileMaxSizeInBytes</td>
	<td>Number</td>
	<td>10K...100M</td>
	<td>1M</td>
</tr>
<tr>
	<td>logfileMaxNumberOfFiles</td>
	<td>Number</td>
	<td>2...1000</td>
	<td>20</td>
</tr>
<tr>
	<td>networkIpAddress</td>
	<td>String</td>
	<td>IP Address</td>
	<td>-</td>
</tr>
<tr>
	<td>networkPortNumber</td>
	<td>String</td>
	<td>Port Number</td>
	<td>-</td>
</tr>
</table>

Note: networkIpAddress and networkPortNumber must both be present to have any effect.

Caveat: The end user cannot change the plist entries without invalidating the app. Hence plist settings are only usefull for developers.

## Extra's

### Source
To make life easier, SwifterLog has an extension on String to create a very readable `source` identifier.

The Swift language has three literals that make sense to use as a `source` identifier: #file, #function and #line.

However the value of these is not very readable if they are simply concatenated. Therefore the String extension "source" can be used to transform the value of these literals into a shorter more readable form:

    log.atLevelNotice(source: #file.source(#function, #line), message: "Error message")

### ReflectedStringConvertable

Logging calls accept as a message the argument "Any". To retrieve the information the "description" method is used. This works fine for most build in types and for structs.

However for classes this does not work very well. This where the ReflectedStringConvertible can help. By simply extending a class with it ReflectedStringConvertible protocol, classes will provide a neatly formatted output without any additional work from the developer.

Thanks to Matt Comi for this [idea](https://github.com/mattcomi/ReflectedStringConvertible) 