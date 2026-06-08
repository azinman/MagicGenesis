//
//  CCR.swift
//  E68k
//
//  Created by Aaron Zinman on 6/7/26.
//

enum CCRBits: UInt8 {
    case carry = 0
    case overflow = 1
    case zero = 2
    case negative = 3
    case extended = 4
}

public class CCR: Codable, Equatable {
    public static func == (lhs: CCR, rhs: CCR) -> Bool {
        return lhs.carry    == rhs.carry    &&
               lhs.overflow == rhs.overflow &&
               lhs.zero     == rhs.zero     &&
               lhs.negative == rhs.negative &&
               lhs.extended == rhs.extended
    }
    
    public var carry: Bool = false
    public var overflow: Bool = false
    public var zero: Bool = false
    public var negative: Bool = false
    public var extended: Bool = false
    
    public var c: Bool { carry    }
    public var v: Bool { overflow }
    public var z: Bool { zero     }
    public var n: Bool { negative }
    public var x: Bool { extended }
   
    public init() { }
    
    public init(fromByte value: UInt8) {
        self.carry    = (value & (1 << CCRBits.carry.rawValue))    != 0
        self.overflow = (value & (1 << CCRBits.overflow.rawValue)) != 0
        self.zero     = (value & (1 << CCRBits.zero.rawValue))     != 0
        self.negative = (value & (1 << CCRBits.negative.rawValue)) != 0
        self.extended = (value & (1 << CCRBits.extended.rawValue)) != 0
    }
    
    public init(carry: Bool = false, overflow: Bool = false, zero: Bool = false, negative: Bool = false, extended: Bool = false) {
        self.carry = carry
        self.overflow = overflow
        self.zero = zero
        self.negative = negative
        self.extended = extended
    }
    
    public func reset() {
        carry = false
        overflow = false
        zero = false
        negative = false
        extended = false
    }
    
    public var asByte: UInt8 {
        var value: UInt8 = 0
        if c { value |= 1 << CCRBits.carry.rawValue    }
        if v { value |= 1 << CCRBits.overflow.rawValue }
        if z { value |= 1 << CCRBits.zero.rawValue     }
        if n { value |= 1 << CCRBits.negative.rawValue }
        if x { value |= 1 << CCRBits.extended.rawValue }
        return value
    }
}
