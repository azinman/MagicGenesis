//
//  GenesisCore.swift
//  GenesisCore
//
//  Created by Aaron Zinman on 6/6/26.
//

import Foundation

import E68k

public class GenesisCore {
    public var cpu: E68k
    
    public init(cpu: E68k) {
        self.cpu = cpu
    }
    
    public convenience init() {
        // Sega Genesis has 64 KiB RAM aka 65,536 bytes aka 0x10000
        self.init(cpu: E68k(memoryCapacity: 0x10000))
    }
}
