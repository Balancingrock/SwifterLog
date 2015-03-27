# SwifterLog
A single class framework in Swift to create log entries in either/or the ASL, a logfile or stdout.

The main class in this project is used internally for our logging needs. It can write to the Apple System Log facility, to a file or to STDOUT (println).
It uses the level approach as defined in ASL to differentiate between logging levels.

Simply drop the file into your project, add the asl-bridge files, configure your app's bridge-headers and log away. More details are in the main class.
