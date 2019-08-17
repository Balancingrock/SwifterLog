# SwifterLog

A framework in Swift to create and manage log entries.

SwifterLog is part of the [Swiftfire](http://swiftfire.nl), the HTTP(S) webserver framework.

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
	4. Warning_ (note: without the underscore! - that has to be added to prevent redlining by Jazzy)
	5. Error
	6. Critical
	7. Alert
	8. Emergency
- Each logging target can have its own cut-off level for the information that is logged.
- The file target can be configured to store the log info in a predefined number of files of a predefined maximum size. When the maximum number of files is exceeded, the oldest file will automatically be removed.
- Included high performance non-evaluation destinations to allow debug logging calls to remain in shipping code
- Compiles using SPM (Swift Package Manager)
- Includes Xcode project that creates a modular framework.

# Documentation

Project website: [http://swiftfire.nl/projects/swiftfire/swiftfire.html](http://swiftfire.nl/projects/swiftfire/swiftfire.html)

Reference manual: [http://swiftfire.nl/projects/swiftfire/reference/index.html](http://swiftfire.nl/projects/swiftfire/reference/index.html)

Installation: [http://swiftfire.nl/projects/swifterlog/reference/installation.html](http://swiftfire.nl/projects/swifterlog/reference/installation.html) or on [github](https://github.com/Balancingrock/SwifterLog/blob/master/docs/Installation.md)

User Manual: [http://swiftfire.nl/projects/swifterlog/reference/usermanual.html](http://swiftfire.nl/projects/swifterlog/reference/usermanual.html) or on [github](https://github.com/Balancingrock/SwifterLog/blob/master/docs/UserManual.md)

# Version History

Note: Planned releases are for information only, they are subject to change without notice.

Maintenance updates are updates due to management of the (SPM) package hierarchy, they don't affect the source code.

#### v2.1.0 (Open)

- No new features planned. Features and bugfixes will be made on an ad-hoc basis as needed to support Swiftfire development.
- For feature requests and bugfixes please contact rien@balancingrock.nl

#### v2.0.0 (Current)

- Udated headers
- Added defaultTypeString and now allows empty type parameters.

#### v1.7.1

- Updated manifest to tool v5
- Added platform to manifest (macOS 10.12)

#### v1.7.0

- Migration to Swift 5

#### v1.6.0

- Undid the disabling of time info in Stdout target (not needed)
- Fixed level-inversion bug that made the newest versions of SwifterLog unworkable

#### v1.5.0

- Added disabling of time info to Stdout target
- Added disable/enable settings for OSLog target

#### v1.4.0

- Made the message parameter implicit

#### v1.3.0

- Replace ASL with os_log

#### v1.2.0

- Migration to SPM 4

#### v1.1.2

- Migration to Swift 4, minor changes.
- Updated user manual

#### v1.1.1

- Updated dependecies

#### v1.1.0

- Split off from 1.0.1, new implementation.

#### v1.0.1

- Updated dependecies (VJson & SwifterSockets)

#### v1.0.0

- No changes but this readme file since the previous version.
