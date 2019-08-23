# SwifterLog

A framework in Swift to create and manage log entries in up to 5 destinations and on 8 levels.

SwifterLog is part of the Swiftfire webserver project.

The [Swiftfire website](http://swiftfire.nl)

The [Reference manual](http://swiftfire.nl/projects/swifterlog/reference/index.html)

The Installation manual on [Swiftfire.nl](http://swiftfire.nl/projects/swifterlog/reference/installation.html) or [github](https://github.com/Balancingrock/SwifterLog/docs/Installation.md)

The User manual on [Swiftfire.nl](http://swiftfire.nl/projects/swifterlog/reference/usermanual.html) or [github](https://github.com/Balancingrock/SwifterLog/docs/UserManual.md)

# Features

- 5 different logging targets:
	1. The OS Log facility
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

# Version History

No new features planned. Updates are made on an ad-hoc basis as needed to support Swiftfire development.

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
