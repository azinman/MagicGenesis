//
//  E68kTests.swift
//  E68k
//
//  Created by Aaron Zinman on 6/6/26.
//

import Testing
@testable import E68k

@Test func canCreateCore() {
    let _ = E68k(memoryCapacity: 100000)
}

@Test("Verify basic memory read/write")
func basicMemoryReadWrite() {
    let ram = RAM(memoryCapacity: 64)
    
    // It's zero'd out
    #expect(ram.readInt8(address: 4) == 0)
    #expect(ram.readInt16(address: 4) == 0)
    #expect(ram.readInt32(address: 4) == 0)
    
    // Basic read in / read out
    ram.writeUInt8(address: 4, value: 0xAB)
    #expect(ram.readUInt8(address: 4) == 0xAB)
    
    ram.writeUInt16(address: 4, value: 0xBABE)
    #expect(ram.readUInt16(address: 4) == 0xBABE)

    ram.writeUInt32(address: 4, value: 0xDEADBEEF)
    #expect(ram.readUInt32(address: 4) == 0xDEADBEEF)

    ram.writeInt8(address: 4, value: Int8.max)
    #expect(ram.readInt8(address: 4) == Int8.max)
    
    ram.writeInt8(address: 4, value: Int8.min)
    #expect(ram.readInt8(address: 4) == Int8.min)

    ram.writeInt16(address: 4, value: Int16.max)
    #expect(ram.readInt16(address: 4) == Int16.max)
    
    ram.writeInt16(address: 4, value: Int16.min)
    #expect(ram.readInt16(address: 4) == Int16.min)

    ram.writeInt32(address: 4, value: Int32.max)
    #expect(ram.readInt32(address: 4) == Int32.max)
    
    ram.writeInt32(address: 4, value: Int32.min)
    #expect(ram.readInt32(address: 4) == Int32.min)
}
