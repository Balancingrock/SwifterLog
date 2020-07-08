# SwifterLog

A framework in Swift to create and manage log entries in up to 5 destinations and on 8 levels.

SwifterLog is part of the Swiftfire webserver project.

The [Swiftfire website](http://swiftfire.nl)

The [Reference manual](http://swiftfire.nl/projects/swifterlog/reference/index.html)

The Installation manual on [Swiftfire.nl](http://swiftfire.nl/projects/swifterlog/reference/installation.html) or [github](https://github.com/Balancingrock/SwifterLog/docs/Installation.md)

The User manual on [Swiftfire.nl](http://swiftfire.nl/projects/swifterlog/reference/usermanual.html) or [github](https://github.com/Balancingrock/SwifterLog/docs/UserManual.md)

# Features

- 5 different logging targets:
    1. The OS Log facility (from macOS 10.12 or from iOS 10)
    2. A file
    3. STDOUT (println)
    4. A network destination
    5. A list of callback objects from the Application itself.
- 8 log levels:
    1. Debug
    2. Info
    3. Notice
    4. <span>Warning</span>
    5. Error
    6. Critical
    7. Alert
    8. Emergency
- Each logging target can have its own cut-off level for the information that is logged.
- The file target can be configured to store the log info in a predefined number of files of a predefined maximum size. When the maximum number of files is exceeded, the oldest file will automatically be removed.
- Included high performance non-evaluation destinations to allow debug logging calls to remain in shipping code
- Compiles using SPM (Swift Package Manager)
- Filtering is possible
- Supports macOS and Linux
- Keeps logfiles seperate if multiple instances of the same app are executing in parallel.

# Installation

## As an SPM package

To install SwifterLog type the following:

    $ git clone https://github.com/Balancingrock/SwifterLog

This will create a directory SwifterLog with the project contained in it.

Go down in the directory that was created:

    $ cd SwifterLog

Then perform a SPM build.

    $ swift build

## Adding to an Xcode project

In the Xcode project using the navigator panel select the target SwifterLog should be added to.

Then select the `General` tab and click the `+` sign of the `Frameworks, Libraries, and Embedded Content` section.

In the dropdown window select `Add Other...` and choose `Add Package Dependency...`.

In the new dropdown window type `https://github.com/Balancingrock/SwifterLog.git` and click `Next`, `Next` and `Finish`.

Now use `import SwifterLog` in each source file where you need its capabilities.

## Optional removal of Ascii, BRUtils, VJson and SwifterSockets dependency

By default SwifterLog also needs Ascii, BRUtils, VJson and SwifterSockets for the networking target. If the networking target is not needed, that code can be excluded by adding an Active Compilation Condition:

In the xcode project, the SwifterLog framework target, select the `Build Settings` and under `Swift Compiler - Custom Flags` add `SWIFTERLOG_DISABLE_NETWORK_TARGET` to the `Active Compiler Conditions`.

Also remove the Ascii, BRUtils, VJson and SwifterSockets from the `Linked Frameworks and Libraries` settings under the `General` tab for the SwifterLog target.

# Version History

No new features planned. Updates are made on an ad-hoc basis as needed to support Swiftfire development.

#### 2.2.2 & 2.2.3

- Added swift version, platform and a LICENSE file

#### 2.2.1

- Rewrote dependency on >= macOS 12

#### 2.2.0

- Added capability to run multiple instances of an app in parallel and still keep the logfiles sperate.

#### 2.1.1

- Linux compatibility

#### 2.1.0

- Updated for changes in SwifterSockets: using Swift.Result instead of BRUtils.Result. 

#### 2.0.1

- Documentation updates

#### 2.0.0

- Udated headers
- Added defaultTypeString and now allows empty type parameters.

#### 1.7.1

- Updated manifest to tool v5
- Added platform to manifest (macOS 10.12)

#### 1.7.0

- Migration to Swift 5

#### 1.6.0

- Undid the disabling of time info in Stdout target (not needed)
- Fixed level-inversion bug that made the newest versions of SwifterLog unworkable

#### 1.5.0

- Added disabling of time info to Stdout target
- Added disable/enable settings for OSLog target

#### 1.4.0

- Made the message parameter implicit

#### 1.3.0

- Replace ASL with os_log

#### 1.2.0

- Migration to SPM 4

#### 1.1.2

- Migration to Swift 4, minor changes.
- Updated user manual

#### 1.1.1

- Updated dependecies

#### 1.1.0

- Split off from 1.0.1, new implementation.

#### 1.0.1

- Updated dependecies (VJson & SwifterSockets)

#### 1.0.0

- No changes but this readme file since the previous version.
