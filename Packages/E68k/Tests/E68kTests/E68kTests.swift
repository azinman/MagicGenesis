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
    let ram = BigEndianMemory(memoryCapacity: 64)
    
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

@Test("CCR convertion to/from byte")
func ccrConversion() {
    let ccr = CCR(overflow: true,
                  zero: true,
                  negative: true)
    #expect(ccr.overflow)
    #expect(ccr.zero)
    #expect(ccr.negative)
    #expect(!ccr.carry)
    #expect(!ccr.extended)
    #expect(ccr.asByte == 0b00001110)

    #expect(ccr == CCR(fromByte: ccr.asByte))
}

@Test("System byte convertion to/from byte")
func systemByteConversion() {
    let sb = SystemByte(interrupt0: true,
                        interrupt2: true,
                        supervisor: true)
    #expect(sb.interrupt0)
    #expect(!sb.interrupt1)
    #expect(sb.interrupt2)
    #expect(sb.supervisor)
    #expect(!sb.trace)
    #expect(sb.asByte == 0b00100101)
    #expect(sb.asWord == 0b00100101_00000000)

    #expect(sb == SystemByte(fromByte: sb.asByte))
    #expect(sb == SystemByte(fromWord: sb.asWord))
}

@Test("Status register converstion to/from word")
func statusWordConversion() {
    let r = Registers()
    let word: UInt16 = 0b10100010_00001010
    r.status = word
    #expect(r.status == word)
    #expect(r.ccr.asByte == 0b00001010)
    #expect(r.system.asByte == 0b10100010)
}

@Test("Interrupt set/get with levels")
func interruptLevels() {
    let s = SystemByte()
    #expect(s.interruptLevel == 0)
    s.interrupt0 = true
    #expect(s.interruptLevel == 1)
    s.interrupt1 = true
    #expect(s.interruptLevel == 3)
    s.interrupt2 = true
    #expect(s.interruptLevel == 7)
    s.i1 = false
    #expect(s.interruptLevel == 5)
    s.i2 = false
    #expect(s.interruptLevel == 1)
    s.i0 = false
    #expect(s.interruptLevel == 0)
}

@Test("Test machine reset")
func machineReset() {
    let m = E68k(memoryCapacity: 32)
    #expect(m.registers.ssp == 0)
    #expect(m.registers.pc == 0)
    #expect(m.registers.system.interruptLevel == 0)

    m.ram.writeUInt32(address: 0, value: 0xDEADBEEF)
    m.ram.writeUInt32(address: 4, value: 0xCAFEBABE)
    m.reset()

    #expect(m.registers.ssp == 0xDEADBEEF)
    #expect(m.registers.pc == 0xCAFEBABE)
    #expect(m.registers.system.interruptLevel == 7)
}
