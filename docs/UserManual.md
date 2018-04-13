# User Manual

## Jump start

The framework defines a singleton called `singleton`. This variable can be used to access all logging functions. For ease of use, it is recommened to create a global variable from this:

    let log = SwifterLog.singleton

Before using the logging functions, first setup the log level thresholds for the targets. In code this is done as follows:

    log.stdoutPrintAtAndAboveLevel = .debug
    log.fileRecordAtAndAboveLevel = .notice
    log.osLogFacilityRecordAtAndAboveLevel = .notice
    log.networkTransmitAtAndAboveLevel = .none
    log.callbackAtAndAboveLevel = .none

Of course the default is `.none`, thus it is not necessary to assign `.none` to unused targets.

After the threshold levels are set, use the log as follows:

    log.atDebug("Kilroy was here")
    
Or use the optional loggers:
    
    SwifterLog.atDebug?.log("Kilroy was here")

The optional logger are not as readable, but offer performance advantages when levels are disabled.

There are other optional parameters that can be usefull:

    log.atDebug("Kilroy was here", id: 16, type: "MyType")

The `id` parameter can be used to identify an object, thread, socket etc. Its default value is -1. Hence -1 should not be used for any other purpose.

The `type` parameter can be used to identify the type for which the entry was made. Its default value is _noType_.

Note that all log entries will be accompanied by a Source specifier that identifies the file, function and line number of where the log entry was made.

The message parameter is defined as `CustomStringConvertible`. It uses the `description` method to display the information in the item. It is recommended to add the (also provided) protocol `ReflectedStringConvertible` to objects for an auto generated reflection based description.

## Performance problem & solution

While it is perfectly possible (and the only option before 0.9.18) to use a single point of contact for all logging functions, there is a performance hit for this simplicity.

Consider the following:

    import SwifterLog
    typealias Log = SwifterLog
    let log = Log.singleton

    log.stdoutPrintAtAndAboveLevel = .info
    extension MyGreatVariable: ReflectedStringConvertable {}
    let myGreatVariable = MyGreatVariable()
    log.atDebug(myGreatVariable)
    
This works fine. When there is no target with a threshold below `.info` no log information is written. However the call `atDebug` is always made. And hence all parameters must be evaluated and the information must be placed on the stack. That overhead is always incurred. Wether the debug level is used or not.

The solution is to avoid the evaluation/preparation when the debug level is not used.

For this purpose there are additional optional (level dependent) loggers available. Because they are optionals they will be nil when the debug level is not in use. For example the optional debug logger is SwifterLog.atDebug

The last line of the above example then becomes:

    Log.atDebug?.log(myGreatVariable)

While the readability has suffered slightly, this has the big advantage of not evaluating the parameters of the call if the debug level is not used in any target. Under circumstances this can either give a performance boost to the application, or alternatively, it becomes unneccesary to comment-out all logger call at the debug and info level before shipping.

There are optional loggers for all levels. Though probably only the ones for the .debug and .info are useful. (It is not likely that the other levels will be disabled in shipping applications)

## Targets

SwifterLog defines 5 targets that can receive the information from the logging calls:

- STDOUT
- File
- OS Log
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

### OS Log

The OS Log has fewer levels than SwifterLog, the following mapping has been made:

    debug -> OSLogType.debug
    info -> OSLogType.info
    notice -> OSLogType.default
    warning -> OSLogType.error
    error -> OSLogType.error
    critical -> OSLogType.error
    alert -> OSLogType.error
    emergency -> OSLogType.fault

The threshold level is set through: `log.osLogRecordAtAndAboveLevel`. The level that is set here must be one of the SwifterLog levels.

### Network

The threshold level is set through: `log.networkTransmitAtAndAboveLevel`

The network destination is set by calling the operation:

    log.connectToNetworkTarget(address: "myserver.com", port: "3897")

Of course there should be a server running at that destination to receive the information.

To use the network destination the frameworks VJson and SwifterSockets are necessary. These are installed by default.

The information is transmitted as a small JSON record. An example:

    {"LogLine":{"Time":<timestamp>,"Level":<loglevel>,"Source":<source>,"Message":<message>}}
    
All of the data fields are in fact strings.

__Warning__: If a network target is too slow, logging messages will stack up in the logger. Leading to increased use of system resources that could eventually crash the application.

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

__Warning__: If a callback target is too slow, logging messages will stack up in the logger. Leading to increased use of system resources that could eventually crash the application.

## Levels

SwiftLog uses the following levels:

- Debug (lowest level)
- Info
- Notice
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
	<td>osLogFacilityRecordAtAndAboveLevel</td>
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

### ReflectedStringConvertable

Logging calls accept as a message the argument "Any". To retrieve the information the "description" method is used. This works fine for most build in types and for structs.

However for classes this does not work very well. This where the ReflectedStringConvertible can help. By simply extending a class with it ReflectedStringConvertible protocol, classes will provide a neatly formatted output without any additional work from the developer.

Thanks to Matt Comi for this [idea](https://github.com/mattcomi/ReflectedStringConvertible) 
