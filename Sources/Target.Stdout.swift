//
//  Target.Stdout.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 30/07/2017.
//
//

import Foundation

public class Stdout: Target {
        
    public override func write(_ string: String) {
        print(string)
    }
    
    
    /// Prints a line with the specified character for the specified times to the console
    
    public func seperatorLine(_ char: Character, times: Int) {
        guard times >= 0 else { return }
        let time = Date()
        var separator = ""
        for _ in 0 ..< times {
            separator.append(char)
        }
        let logstr = logTimeFormatter.string(from: time) + ", SEPARATOR: " + separator
        write(logstr)
    }
}
