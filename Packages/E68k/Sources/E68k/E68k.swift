//
//  E68k.swift
//  E68k
//
//  Created by Aaron Zinman on 6/6/26.
//

import Foundation

public class E68k: Codable {
    public var registers: Registers
    public var ram: BigEndianMemory
    public var memoryCapacity: Bytes
    
    public convenience init(memoryCapacity: Bytes) {
        self.init(registers: Registers(),
                  ram: BigEndianMemory(memoryCapacity: memoryCapacity),
                  memoryCapacity: memoryCapacity)
    }
    
    public init(registers: Registers,
                ram: BigEndianMemory,
                memoryCapacity: Bytes) {
        self.registers = registers
        self.ram = ram
        self.memoryCapacity = memoryCapacity
    }

    public func main() {
        reset()

        while true {
            cycle()
        }
    }

    public func reset() {
        registers = Registers()
        registers.ssp = ram.readUInt32(address: 0)
        registers.pc = ram.readUInt32(address: 4)
        registers.supervisorMode = .supervisor
        registers.system.interruptLevel = 7
    }

    public func cycle() {
        let operationWord = ram.readUInt16(address: registers.pc)
        registers.pc += 2

        let instruction = decode(operationWord: operationWord)
        execute(instruction: instruction)
    }

    func decode(operationWord: UInt16) -> Instruction {
        guard let opcode = Opcode(rawValue: operationWord) else {
            preconditionFailure("Invalid opcode: \(operationWord)")
        }
        return Instruction(opcode: opcode)
    }

    func execute(instruction: Instruction) {

    }
}
