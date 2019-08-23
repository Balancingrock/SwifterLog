// =====================================================================================================================
//
//  File:       Target.Logfiles.swift
//  Project:    SwifterLog
//
//  Version:    2.0.1
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterlog/swifterlog.html
//  Git:        https://github.com/Balancingrock/SwifterLog
//
//  Copyright:  (c) 2017..2019 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  Like you, I need to make a living:
//
//   - You can send payment (you choose the amount) via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
// PLEASE let me know about bugs, improvements and feature requests. (rien@balancingrock.nl)
// =====================================================================================================================
//
// History
//
// 2.0.1 - Documentation update
// 2.0.0 - New header
// 1.1.2 - Migration to Swift 4, minor changes.
// 1.1.0 - Initial release in preperation for v2.0.0
//
// =====================================================================================================================
//
// Purpose:
//
// This writes the log entries to a log directory.
// The files have an associated maximum size. Once the maximum size has been exceeded a new file will be created.
// If more than a maximum number of files have been created, the oldest file will be removed once a new file is created.
//
// =====================================================================================================================

import Foundation


/// A logfile as destination for log entires.

public class Logfiles: Target {
    
    
    // The queue that decouples the request for entries from the actual writing to the filesystem.
    
    private var queue: DispatchQueue = DispatchQueue(label: "SwifterLog.Target.Logfiles", qos: .background, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: .inherit, target: nil)

    
    /// Writes a message (string) to the end of a logfile with a <cr><lf> at the end.
    
    public override func write(_ message: String) {
        
        queue.async() {
                
            [weak self] in
            guard let `self` = self else { return }
                
            if let file = self.logfile {

                _ = file.seekToEndOfFile()
                if let data = (message + "\r\n").data(using: String.Encoding.utf8, allowLossyConversion: true) {
                    file.write(data)
                    file.synchronizeFile()
                }
            
            
                // Do some additional stuff like creating a new file if the current one gets too large and cleaning up of existing logfiles if there are too many
            
                self.logfileServices()
            }
        }
    }

    
    /// Closes a logfile.
    
    public override func close() {
        logfile?.closeFile()
    }
    
    
    /// As soon as an entry in the current logfile grows the logfile beyond this limit, the logfile will be closed and a new logfile will be started. The default is 1 MB.
    
    public var maxSizeInBytes: UInt64 = 1 * 1024 * 1024
    
    
    /// The maximum number of logfiles kept in the logfile directory. As soon as there are more than this number of logfiles, the oldest logfile will be removed. Must be >= 2.
    
    public var maxNumberOfFiles: Int = 20 {
        didSet {
            if maxNumberOfFiles < 2 { maxNumberOfFiles = 2 }
        }
    }
    
    
    /// The path for the directory in which the next logfile will be created.
    ///
    /// Note that the application must have write access to this directory and the rights to create this directory (sandbox!). If this variable is nil, the logfiles will be written to /Library/Application Support/[Application Name]/Logfiles.
    ///
    /// Do not use '~' signs in the path, expand them first if there are tildes in it.
    
    /// - Note: When debugging in xcode, the app support directory is in /Library/Containers/[bundle identifier]/Data/Library/Application Support/[app name]/Logfiles.
    
    public var directoryPath: String? {
        didSet {
            logdirErrorMessageGenerated = false
            logfileErrorMessageGenerated = false
        }
    }

    
    // Used to suppress multiple error messages for the failure to create a directory for the logfiles
    
    private var logdirErrorMessageGenerated = false
    private var logfileErrorMessageGenerated = false
    
    
    // Handle for the logfile
    
    lazy private var logfile: FileHandle? = { self.createLogfile() }()
    
    
    // We use the /Library/Application Support/<<<application>>>/Logfiles directory if no logfile directory is specified
    
    lazy private var applicationSupportLogfileDirectory: String? = {
        
        
        let fileManager = FileManager.default
        
        do {
            let applicationSupportDirectory =
                try fileManager.url(
                    for: FileManager.SearchPathDirectory.applicationSupportDirectory,
                    in: FileManager.SearchPathDomainMask.userDomainMask,
                    appropriateFor: nil,
                    create: true).path
            
            let appName = ProcessInfo.processInfo.processName
            let dirUrl = URL(fileURLWithPath: applicationSupportDirectory, isDirectory: true).appendingPathComponent(appName)
            return dirUrl.appendingPathComponent("Logfiles").path
            
        } catch let error as NSError {
            
            print("Could not get application support directory, error = \(error.localizedDescription)")
            return nil
        }
    }()
    
    
    // Will be set to the URL of the logfile if the directory for the logfiles is available.
    
    private var directoryURL: URL?
    
    
    // Creates a new logfile.
    
    private func createLogfile() -> FileHandle? {
        
        
        // Get the logfile directory
        
        if let logdir = directoryPath ?? applicationSupportLogfileDirectory {
            
            do {
                
                // Make sure the logfile directory exists
                
                try FileManager.default.createDirectory(atPath: logdir, withIntermediateDirectories: true, attributes: nil)
                
                directoryURL = URL(fileURLWithPath: logdir, isDirectory: true) // For the logfile services
                
                let filename = "Log_" + logTimeFormatter.string(from: Date()) + ".txt"
                
                let logfileUrl = URL(fileURLWithPath: logdir).appendingPathComponent(filename)
                
                if FileManager.default.createFile(atPath: logfileUrl.path, contents: nil, attributes: [FileAttributeKey(rawValue: FileAttributeKey.posixPermissions.rawValue) : NSNumber(value: 0o640)]) {
                    
                    return FileHandle(forUpdatingAtPath: logfileUrl.path)
                    
                } else {
                    
                    if !logfileErrorMessageGenerated {
                        print("Could not create logfile \(logfileUrl.path)")
                        logfileErrorMessageGenerated = true
                    }
                }
                
            } catch let error as NSError {
                
                if !logdirErrorMessageGenerated {
                    print("Could not create logfile directory \(logdir), error = \(error.localizedDescription)")
                    logdirErrorMessageGenerated = true
                }
            }
            
        } else {
            // Only possible if the application support directory could not be retrieved, in that case a message  has already been printed
        }
        
        return nil
    }
    
    
    // Closes the current logfile if it has gotten too large. And limits the number of logfiles to the specified maximum.
    
    private func logfileServices() {
        
        
        // There should be a logfile, if there is'nt, then something is wrong
        
        if let file = logfile {
            
            
            // If the file size is larger than the specified maximum, close the existing logfile and create a new one
            
            if file.seekToEndOfFile() > maxSizeInBytes {
                
                file.closeFile()
                
                logfile = createLogfile()
            }
            
            
            // Check if there are more than 20 files in the logfile directory, if so, remove the oldest
            
            do {
                
                let files = try FileManager.default.contentsOfDirectory(
                    at: directoryURL!,
                    includingPropertiesForKeys: nil,
                    options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                
                if files.count > maxNumberOfFiles {
                    let sortedFiles = files.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
                    try FileManager.default.removeItem(at: sortedFiles.first!)
                }
            } catch {
            }
        }
    }    
}
