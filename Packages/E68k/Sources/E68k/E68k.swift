//
//  E68k.swift
//  E68k
//
//  Created by Aaron Zinman on 6/6/26.
//

import Foundation

public class E68k {
    public var registers: Registers
    public var ram: RAM
    
    public convenience init() {
        self.init(registers: Registers(), ram: RAM())
    }
    
    public init(registers: Registers, ram: RAM) {
        self.registers = registers
        self.ram = ram
    }
}

public class Registers {
    
}

public class RAM {
    
}
