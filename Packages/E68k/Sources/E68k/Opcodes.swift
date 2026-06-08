//
//  Opcodes.swift
//  E68k
//
//  Created by Aaron Zinman on 6/7/26.
//

import Foundation

enum EffectiveAddress {
    /// Dn
    case dataRegisterDirect(UInt8)
    /// An
    case addressRegisterDirect(UInt8)
    /// (An)
    case addressRegisterIndirect(UInt8)
    /// (An)+
    case postincrement(addressRegister: UInt8)
    /// -(An)
    case predecrement(addressRegister: UInt8)
    /// d16(An)
    case displacement(addressNumber: UInt8, offset: UInt16)
    /// d8(An, Xn)
    case indexed(addressRegister: UInt8, offset: UInt8)
    /// 1 extension word
    case absoluteShort(extensionWord1: UInt16)
    /// 2 extension words
    case absoluteLong(extensionWord1: UInt16, extensionWord2: UInt16)
    /// d16(PC)
    case programCounterRelative(offset: UInt16)
    /// d8(PC, Xn)
    case programCounterRelativeIndexed(offset: UInt8)
    /// 1 or 2 extension words
    case immediate(extensionWord1: UInt16, extensionWord2: UInt16?)
}

enum EffectiveAddressMode {
    /// Dn
    case dataRegisterDirect
    /// An
    case addressRegisterDirect
    /// (An)
    case addressRegisterIndirect
    /// (An)+
    case postincrement
    /// -(An)
    case predecrement
    /// d16(An)
    case displacement
    /// d8(An, Xn)
    case indexed
    /// 1 extension word
    case absoluteShort
    /// 2 extension words
    case absoluteLong
    /// d16(PC)
    case programCounterRelative
    /// d8(PC, Xn)
    case programCounterRelativeIndexed
    /// 1 or 2 extension words
    case immediate

    init(mode: UInt8, register: UInt8) {
        switch mode {
            case 0b000: self = .dataRegisterDirect
            case 0b001: self = .addressRegisterDirect
            case 0b010: self = .addressRegisterIndirect
            case 0b011: self = .postincrement
            case 0b100: self = .predecrement
            case 0b101: self = .displacement
            case 0b110: self = .indexed
            case 0b111:
                switch register {
                case 0b000: self = .absoluteShort
                case 0b001: self = .absoluteLong
                case 0b010: self = .programCounterRelative
                case 0b011: self = .programCounterRelativeIndexed
                case 0b111: self = .immediate
                default: fatalError("Invalid register in ea field")
                }
            default: fatalError("Invalid mode in ea field")
        }
    }

    init(sourceEaField field: UInt8) {
        let mode     = (field & 0b111000) >> 3
        let register =  field & 0b000111
        self.init(mode: mode, register: register)
    }

    init(destinationEaField field: UInt8) {
        // Opposite of source order
        let register = (field & 0b111000) >> 3
        let mode     =  field & 0b000111
        self.init(mode: mode, register: register)
    }

    var mode: UInt8 {
        switch self {
        case .dataRegisterDirect:            0b000
        case .addressRegisterDirect:         0b001
        case .addressRegisterIndirect:       0b010
        case .postincrement:                 0b011
        case .predecrement:                  0b100
        case .displacement:                  0b101
        case .indexed:                       0b110

        case .absoluteShort:                 0b111
        case .absoluteLong:                  0b111
        case .programCounterRelative:        0b111
        case .programCounterRelativeIndexed: 0b111
        case .immediate:                     0b111
        }
    }

    var register: UInt8? {
        switch self {
        case .dataRegisterDirect,
             .addressRegisterDirect,
             .addressRegisterIndirect,
             .postincrement,
             .predecrement,
             .displacement,
             .indexed: nil

        case .absoluteShort:                 0b000
        case .absoluteLong:                  0b001
        case .programCounterRelative:        0b010
        case .programCounterRelativeIndexed: 0b011
        case .immediate:                     0b100
        }
    }
}

enum OperandSize {
    case byte
    case word
    case long
}

enum ConditionCode: UInt8 {
    /// Branch carry clear
    case cc = 0b0100
    /// Branch carry set
    case cs = 0b0101
    /// Branch equal
    case eq = 0b0111
    /// Branch greater or equal
    case ge = 0b1100
    /// Branch greater than
    case gt = 0b1110
    /// Branch high
    case hi = 0b0010
    /// Branch less or equal
    case le = 0b1111
    /// Branch less or same
    case ls = 0b0011
    /// Branch less than
    case lt = 0b1101
    /// Branch minus
    case mi = 0b1011
    /// Branch not equal
    case ne = 0b0110
    /// Branch plus
    case pl = 0b1010
    /// Branch overflow clear
    case vc = 0b1000
    /// Branch overflow set
    case vs = 0b1001
}

enum Opcode {
    case nop
    case move(size: OperandSize, sourceEaMode: EffectiveAddressMode, destinationEaMode: EffectiveAddressMode)
    case movq(immediate: UInt8, destinationDataRegister: UInt8)
    case addq(immediate: UInt8, eaMode: EffectiveAddressMode)
    case subq(immediate: UInt8, eaMode: EffectiveAddressMode)
    // Branching
    /// If displacement8 == nil, 16-bit displacement follows this opcode
    case bra(displacement8: Int8?)
    /// If displacement8 == nil, 16-bit displacement follows this opcode
    case bsr(displacement8: Int8?)
    /// If displacement8 == nil, 16-bit displacement follows this opcode
    case bcc(condition: ConditionCode, displacement8: Int8?)

    case lea(sourceEaMode: EffectiveAddressMode, destinationAddressRegister: UInt8)
    case jmp(sourceEaMode: EffectiveAddressMode)
    case jsr(sourceEaMode: EffectiveAddressMode)
    case clr
    case neg
    case not
    case tst
    case movem

    init?(rawValue: UInt16) {
        let line = (rawValue >> 12) & 0b1111
        switch line {
        case 0x0:
            // Bit manipulation / MOVEP / immediate (ANDI, ORI, ADDI, …)
            preconditionFailure("Not implemented yet")
        case 0x1, 0x2, 0x3:
            // MOVE(A).B/L/W
            let sourceEaRawValue = UInt8(truncatingIfNeeded: rawValue & 0b1111)
            let destEaRawValue = UInt8(truncatingIfNeeded: (rawValue >> 6) & 0b1111)
            let sourceEaMode = EffectiveAddressMode(sourceEaField: sourceEaRawValue)
            let destEaMode = EffectiveAddressMode(destinationEaField: destEaRawValue)
            let size: OperandSize = switch line {
                case 0x1: .byte // b01 = byte
                case 0x3: .word // b11 = word
                case 0x2: .long // b10 = long
                default: fatalError("Invalid line size")
            }
            self = .move(size: size, sourceEaMode: sourceEaMode, destinationEaMode: destEaMode)
        case 0x4:
            // Miscellaneous: LEA, JMP, JSR, CLR, NEG, NOT, TST, MOVEM, …

            let eaRawValue = UInt8(truncatingIfNeeded: rawValue & 0b11111)
            let sourceEaMode = EffectiveAddressMode(sourceEaField: eaRawValue)
            let destinationRegister = UInt8(truncatingIfNeeded: (rawValue >> 9) & 0b111)

            let op = UInt8(truncatingIfNeeded: rawValue >> 6) & 0b111
            switch op {
            case 0b111:
                self = .lea(sourceEaMode: sourceEaMode, destinationAddressRegister: destinationRegister)
            case 0b011:
                assert((rawValue >> 9) & 0b111 == 0b111)
                self = .jmp(sourceEaMode: sourceEaMode)
            case 0b010:
                assert((rawValue >> 9) & 0b111 == 0b111)
                self = .jsr(sourceEaMode: sourceEaMode)
            default:
                preconditionFailure("Unknown op for line 0x4: \(op)")
            }
        case 0x5:
            // ADDQ / SUBQ / Scc / DBcc
            // Bits 11-9 hold immediate data
            var immediate = UInt8(truncatingIfNeeded: (rawValue >> 9) & 0b111)
            if immediate == 0 {
                immediate = 8 // how 8 can be encoded in 3 bits
            }
            // Bits 7-6 are size
            let sizeRawValue: UInt8 = UInt8(truncatingIfNeeded: (rawValue >> 6) & 0b11)
            // The conventional ordering
            let size: OperandSize = switch sizeRawValue {
                case 0b00: .byte
                case 0b01: .word
                case 0b10: .long
                default: fatalError("Invalid line size")
            }

            // Bits 5-0 are dest EA
            let destEARawValue = UInt8(truncatingIfNeeded: rawValue) & 0b00011111
            let destEA = EffectiveAddressMode(destinationEaField: destEARawValue)

            // Bit 8 holds addq vs subq
            if rawValue & 0b00000000_10000000 == 0 {
                self = .addq(immediate: immediate, eaMode: destEA)
            } else {
                self = .subq(immediate: immediate, eaMode: destEA)
            }
        case 0x6:
            // Bcc / BSR / BRA
            var displacement: Int8? = Int8(truncatingIfNeeded: rawValue)
            if displacement == 0 {
                // Signal it's in the next word
                displacement = nil
            }

            // Bits 11-8 are the condition code, as are values that select BRA and BSR
            let conditionCodeRawValue = UInt8(truncatingIfNeeded: (rawValue >> 8) & 0b111)
            if let conditionCode = ConditionCode(rawValue: conditionCodeRawValue) {
                // Bits 7-0 are an 8-bit signed displacement
                //  Note if displacement is 0, then it's taken from the following 16-bit extension word
                self = .bcc(condition: conditionCode, displacement8: displacement)
            } else if conditionCodeRawValue == 0b000 {
                // BRA
                self = .bra(displacement8: displacement)
            } else if conditionCodeRawValue == 0b001 {
                // BSR
                self = .bsr(displacement8: displacement)
            } else {
                preconditionFailure("Invalid condition code: \(conditionCodeRawValue)")
            }
        case 0x7:
            // MOVEQ
            let destDataRegister = UInt8(truncatingIfNeeded: (rawValue >> 9) & 0b111)
            assert(rawValue & 0b0000010000000000 == 0)
            let immediate = UInt8(truncatingIfNeeded: rawValue)
            self = .movq(immediate: immediate, destinationDataRegister: destDataRegister)
        case 0x8:
            // OR / DIVU / DIVS / SBCD
            preconditionFailure("Not implemented yet")
        case 0x9:
            // SUB / SUBA / SUBX
            preconditionFailure("Not implemented yet")
        case 0xA:
            // Reserved — line-A, unimplemented instruction trap
            preconditionFailure("Not implemented yet")
        case 0xB:
            // CMP / CMPA / EOR
            preconditionFailure("Not implemented yet")
        case 0xC:
            // AND / MULU / MULS / ABCD / EXG
            preconditionFailure("Not implemented yet")
        case 0xD:
            // ADD / ADDA / ADDX
            preconditionFailure("Not implemented yet")
        case 0xE:
            // Shift / rotate (ASL, ASR, LSL, LSR, ROL, ROR, …)
            preconditionFailure("Not implemented yet")
        case 0xF:
            // Reserved — line-F, coprocessor / unimplemented trap
            preconditionFailure("Not implemented yet")
        default:
            fatalError("Invalid line: \(line)")
        }
    }
}
