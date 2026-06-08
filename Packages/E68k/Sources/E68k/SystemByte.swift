//
//  SystemByte.swift
//  E68k
//
//  Created by Aaron Zinman on 6/7/26.
//

enum SystemBits: UInt8 {
    case interrupt0 = 8
    case interrupt1 = 9
    case interrupt2 = 10
    case supervisor = 13
    case trace = 15
}

public class SystemByte: Codable, Equatable {
    public static func == (lhs: SystemByte, rhs: SystemByte) -> Bool {
        return lhs.i0 == rhs.i0 &&
               lhs.i1 == rhs.i1 &&
               lhs.i2 == rhs.i2 &&
               lhs.s  == rhs.s  &&
               lhs.t  == rhs.t
    }
    
    public var interrupt0: Bool = false
    public var interrupt1: Bool = false
    public var interrupt2: Bool = false
    public var supervisor: Bool = false
    public var trace: Bool = false

    public var i0: Bool { interrupt0 }
    public var i1: Bool { interrupt1 }
    public var i2: Bool { interrupt2 }
    public var s: Bool { supervisor }
    public var t: Bool { trace }

    public init() {}
    
    public init(fromWord value: UInt16) {
        self.interrupt0 = (value & (1 << SystemBits.interrupt0.rawValue)) != 0
        self.interrupt1 = (value & (1 << SystemBits.interrupt1.rawValue)) != 0
        self.interrupt2 = (value & (1 << SystemBits.interrupt2.rawValue)) != 0
        self.supervisor = (value & (1 << SystemBits.supervisor.rawValue)) != 0
        self.trace      = (value & (1 << SystemBits.trace.rawValue))      != 0
    }
    
    public convenience init(fromByte value: UInt8) {
        self.init(fromWord: UInt16(value) << 8)
    }

    public init(interrupt0: Bool = false, interrupt1: Bool = false, interrupt2: Bool = false, supervisor: Bool = false, trace: Bool = false) {
        self.interrupt0 = interrupt0
        self.interrupt1 = interrupt1
        self.interrupt2 = interrupt2
        self.supervisor = supervisor
        self.trace = trace
    }
    
    public func reset() {
        interrupt0 = false
        interrupt1 = false
        interrupt2 = false
        supervisor = false
        trace = false
    }
    
    public var asWord: UInt16 {
        var value: UInt16 = 0
        if i0 { value |= 1 << SystemBits.interrupt0.rawValue }
        if i1 { value |= 1 << SystemBits.interrupt1.rawValue }
        if i2 { value |= 1 << SystemBits.interrupt2.rawValue }
        if s  { value |= 1 << SystemBits.supervisor.rawValue }
        if t  { value |= 1 << SystemBits.trace.rawValue      }
        return value
    }
    
    public var asByte: UInt8 {
        return UInt8(truncatingIfNeeded: asWord >> 8)
    }
}
