# SwifterLog
A single class framework in Swift to create and manage log entries.

The main class in this project is used internally for our logging needs. It can write to

1. The Apple System Log facility
2. A file
3. STDOUT (println)
4. A network destination (Needs [SwifterJSON](https://github.com/Swiftrien/SwifterJSON))
5. A list of callback objects from the Application itself.

It uses the level approach as defined in ASL to differentiate between logging levels.

Simply drop the file into your project, add the asl-bridge files, configure your app's bridge-headers and log away. More details are in the main class.

V0.9.5:

- Added transfer of log entries to a TCP/IP destination and targetting of error messages.
- Renamed logfileRecordAtAndAboveLevel to fileRecordAtAndAboveLevel
- Added call-back logging

V0.9.4

- Added conveniance functions that add the "ID" parameter back in as hexadecimal output before the source.
- Note: v0.9.4 was never released into the public.

V0.9.3: Updated for Swift 2.0