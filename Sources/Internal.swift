//
//  Internal.swift
//  SwifterLog
//
//  Created by Marinus van der Lugt on 29/07/2017.
//
//

import Foundation

internal var logQueue = DispatchQueue(label: "SwifterLog", qos: .default, attributes: DispatchQueue.Attributes(), autoreleaseFrequency: .inherit, target: nil)
