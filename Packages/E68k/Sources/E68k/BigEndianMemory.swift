//
//  Memory.swift
//  E68k
//
//  Created by Aaron Zinman on 6/6/26.
//


public final class BigEndianMemory: Codable {
    private var memory: ContiguousArray<UInt8>
    
    public init(memoryCapacity: Bytes) {
        self.memory = ContiguousArray(repeating: 0, count: memoryCapacity)
    }
    
    public func reset() {
        self.memory.resetBytes(in: 0..<self.memory.count)
    }
    
    public func readUInt8(address: UInt32) -> HostUInt8 {
        return memory[address]
    }
    
    public func readInt8(address: UInt32) -> HostInt8 {
        return Int8(bitPattern: memory[address])
    }

    public func readUInt16(address: UInt32) -> HostUInt16 {
        // Read in big-endian
        return UInt16(memory[address + 0]) << 8
             | UInt16(memory[address + 1]) << 0
    }
    
    public func readInt16(address: UInt32) -> HostInt16 {
        return Int16(bitPattern: readUInt16(address: address))
    }
    
    public func readUInt32(address: UInt32) -> HostUInt32 {
        // Read in big-endian
        return UInt32(memory[address + 0]) << 24
             | UInt32(memory[address + 1]) << 16
             | UInt32(memory[address + 2]) << 8
             | UInt32(memory[address + 3]) << 0
    }
    
    public func readInt32(address: UInt32) -> HostInt32 {
        return Int32(bitPattern: readUInt32(address: address))
    }
    
    public func writeUInt8(address: UInt32, value: HostUInt8) {
        memory[address] = value
    }
    
    public func writeInt8(address: UInt32, value: HostInt8) {
        memory[address] = UInt8(bitPattern: value)
    }

    public func writeUInt16(address: UInt32, value: HostUInt16) {
        memory[address + 0] = UInt8(truncatingIfNeeded: value >> 8)
        memory[address + 1] = UInt8(truncatingIfNeeded: value)
    }
    
    public func writeInt16(address: UInt32, value: HostInt16) {
        writeUInt16(address: address, value: HostUInt16(bitPattern: value))
    }
    
    public func writeUInt32(address: UInt32, value: HostUInt32) {
        memory[address + 0] = UInt8(truncatingIfNeeded: value >> 24)
        memory[address + 1] = UInt8(truncatingIfNeeded: value >> 16)
        memory[address + 2] = UInt8(truncatingIfNeeded: value >> 8)
        memory[address + 3] = UInt8(truncatingIfNeeded: value >> 0)
    }
   
    public func writeInt32(address: UInt32, value: HostInt32) {
        writeUInt32(address: address, value: HostUInt32(bitPattern: value))
    }
    
    public func debugPrint(address: UInt32, count: Int) {
        print("== 0x\(address.paddedHexValue) .. 0x\((address + count).paddedHexValue)")
       
        var i = address
        while i <= address + count {
            var buffer: [String] = []
            var j = 0
            while j < 8 && i <= address + count {
                buffer.append(memory[i].paddedHexValue)
                j += 1
                i += 1
            }
            let row = buffer.joined(separator: " ")
            print("   " + row)
        }
    }
}
