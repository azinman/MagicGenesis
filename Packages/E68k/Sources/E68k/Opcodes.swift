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

enum Opcode {
    case nop
    case movq(immediate: UInt8, destinationDataRegister: UInt8)
    case addq(immediate: UInt8, eaMode: EffectiveAddressMode)
    case subq(immediate: UInt8, eaMode: EffectiveAddressMode)
    case bra8(displacement8: Int8)
    case braExtension
    case bsr
    case move(size: OperandSize, sourceEaMode: EffectiveAddressMode, destinationEaMode: EffectiveAddressMode)

    init?(rawValue: UInt16) {
        let line = (rawValue >> 12) & 0b1111
        switch line {
        case 0x0:
            // Bit manipulation / MOVEP / immediate (ANDI, ORI, ADDI, …)
            break
        case 0x1, 0x2, 0x3:
//            MOVE(A).B/L/W
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
            break
        case 0x5:
            // ADDQ / SUBQ / Scc / DBcc
            break
        case 0x6:
            // Bcc / BSR / BRA
            break
        case 0x7:
            // MOVEQ
            break
        case 0x8:
            // OR / DIVU / DIVS / SBCD
            break
        case 0x9:
            // SUB / SUBA / SUBX
            break
        case 0xA:
            // Reserved — line-A, unimplemented instruction trap
            break
        case 0xB:
            // CMP / CMPA / EOR
            break
        case 0xC:
            // AND / MULU / MULS / ABCD / EXG
            break
        case 0xD:
            // ADD / ADDA / ADDX
            break
        case 0xE:
            // Shift / rotate (ASL, ASR, LSL, LSR, ROL, ROR, …)
            break
        case 0xF:
            // Reserved — line-F, coprocessor / unimplemented trap
            break
        default:
            fatalError("Invalid line: \(line)")
        }


        return nil
    }
}
