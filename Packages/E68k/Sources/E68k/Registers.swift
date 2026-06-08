//
//  Registers.swift
//  E68k
//
//  Created by Aaron Zinman on 6/6/26.
//


public class Registers: Codable {
    public var data: ContiguousArray<UInt32> = ContiguousArray(repeating: 0, count: 8)
    public var addresses: ContiguousArray<UInt32> = ContiguousArray(repeating: 0, count: 7)
    public var usp: UInt32 = 0
    public var ssp: UInt32 = 0
    public var pc: UInt32 = 0
//    public var status: UInt16 = 0
//    
//    public var ccr: UInt8 {
//        return UInt8(truncatingIfNeeded: status)
//    }
}
