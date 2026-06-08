//
//  Registers.swift
//  E68k
//
//  Created by Aaron Zinman on 6/6/26.
//

public enum SupervisorMode: Codable {
    case user
    case supervisor
}

public class Registers: Codable {
    // Basic registers
    public var data: ContiguousArray<UInt32> = ContiguousArray(repeating: 0, count: 8)
    public var addresses: ContiguousArray<UInt32> = ContiguousArray(repeating: 0, count: 7)
    public var pc: UInt32 = 0

    // Status register
    public var ccr = CCR()
    public var system = SystemByte()
    public var status: UInt16 {
        get {
            UInt16(truncatingIfNeeded: ccr.asByte) | system.asWord
        }
        set {
            ccr = CCR(fromByte: UInt8(truncatingIfNeeded: newValue))
            system = SystemByte(fromWord: newValue)
        }
    }
    
    // Stack Pointer / Supervisor associations
    public var usp: UInt32 = 0
    public var ssp: UInt32 = 0
    public var sp: UInt32 {
        switch supervisorMode {
        case .user: return usp
        case .supervisor: return ssp
        }
    }
    public var supervisorMode: SupervisorMode {
        get {
            system.supervisor ? .supervisor : .user
        } set {
            system.supervisor = newValue == .supervisor
        }
    }
    public var a7: UInt32 { sp }
    
    public func reset() {
        data = ContiguousArray(repeating: 0, count: data.count)
        addresses = ContiguousArray(repeating: 0, count: addresses.count)
        pc = 0
        ccr.reset()
        system.reset()
        usp = 0
        ssp = 0
    }
}
