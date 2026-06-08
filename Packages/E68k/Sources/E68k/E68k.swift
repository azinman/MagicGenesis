//
//  E68k.swift
//  E68k
//
//  Created by Aaron Zinman on 6/6/26.
//

import Foundation

public typealias Bytes = Int

public typealias BigEndianInt32 = Int32
public typealias BigEndianUInt32 = UInt32
public typealias BigEndianInt16 = Int16
public typealias BigEndianUInt16 = UInt16
public typealias BigEndianInt8 = Int8
public typealias BigEndianUInt8 = UInt8

public typealias HostInt32 = Int32
public typealias HostUInt32 = UInt32
public typealias HostInt16 = Int16
public typealias HostUInt16 = UInt16
public typealias HostInt8 = Int8
public typealias HostUInt8 = UInt8


public class E68k: Codable {
    public var registers: Registers
    public var ram: RAM
    
    public convenience init(memoryCapacity: Bytes) {
        self.init(registers: Registers(), ram: RAM(memoryCapacity: memoryCapacity))
    }
    
    public init(registers: Registers, ram: RAM) {
        self.registers = registers
        self.ram = ram
    }
}
