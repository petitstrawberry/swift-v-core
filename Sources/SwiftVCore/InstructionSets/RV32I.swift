struct RV32I: InstructionSet {
    let instructions: [Instruction] = [
        // LUI
        Instruction(name: "LUI", type: .U, opcode: 0b0110111) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let imm = signExtend32(val: (inst >> 12), bitWidth: 20)
            cpu.xregs.write(rd, imm)
            cpu.pc &+= 4
        },
        // AUIPC
        Instruction(name: "AUIPC", type: .U, opcode: 0b0010111) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let imm = signExtend32(val: (inst >> 12), bitWidth: 20)
            cpu.xregs.write(rd, cpu.pc &+ imm)
            cpu.pc &+= 4
        },
        // JAL
        Instruction(name: "JAL", type: .J, opcode: 0b1101111) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let imm = signExtend32(val: (inst >> 12), bitWidth: 8)
            let imm1 = signExtend32(val: (inst >> 20 & 0b11111), bitWidth: 1)
            let imm2 = signExtend32(val: (inst >> 21 & 0b1111111111), bitWidth: 10)
            let imm3 = signExtend32(val: (inst >> 31), bitWidth: 1)
            let offset = (imm3 << 20) | (imm2 << 1) | (imm1 << 11) | imm
            cpu.xregs.write(rd, cpu.pc &+ 4)
            cpu.pc &+= offset
        },
        // JALR
        Instruction(name: "JALR", type: .I, opcode: 0b1100111, funct3: 0b000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            let offset = cpu.xregs.read(rs1) &+ imm
            cpu.xregs.write(rd, cpu.pc &+ 4)
            cpu.pc = offset
        },
        // BEQ
        Instruction(name: "BEQ", type: .B, opcode: 0b1100011, funct3: 0b000) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 8 & 0b1111_0000_0000) | (inst >> 25 & 0b0111_1111_0000), bitWidth: 13)
            if cpu.xregs.read(rs1) == cpu.xregs.read(rs2) {
                cpu.pc &+= imm
            } else {
                cpu.pc &+= 4
            }
        },
        // BNE
        Instruction(name: "BNE", type: .B, opcode: 0b1100011, funct3: 0b001) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 8 & 0b1111_0000_0000) | (inst >> 25 & 0b0111_1111_0000), bitWidth: 13)
            if cpu.xregs.read(rs1) != cpu.xregs.read(rs2) {
                cpu.pc &+= imm
            } else {
                cpu.pc &+= 4
            }
        },
        // BLT
        Instruction(name: "BLT", type: .B, opcode: 0b1100011, funct3: 0b100) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 8 & 0b1111_0000_0000) | (inst >> 25 & 0b0111_1111_0000), bitWidth: 13)
            if Int32(bitPattern: cpu.xregs.read(rs1)) < Int32(bitPattern: cpu.xregs.read(rs2)) {
                cpu.pc &+= imm
            } else {
                cpu.pc &+= 4
            }
        },
        // BGE
        Instruction(name: "BGE", type: .B, opcode: 0b1100011, funct3: 0b101) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 8 & 0b1111_0000_0000) | (inst >> 25 & 0b0111_1111_0000), bitWidth: 13)
            if Int32(bitPattern: cpu.xregs.read(rs1)) >= Int32(bitPattern: cpu.xregs.read(rs2)) {
                cpu.pc &+= imm
            } else {
                cpu.pc &+= 4
            }
        },
        // BLTU
        Instruction(name: "BLTU", type: .B, opcode: 0b1100011, funct3: 0b110) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 8 & 0b1111_0000_0000) | (inst >> 25 & 0b0111_1111_0000), bitWidth: 13)
            if cpu.xregs.read(rs1) < cpu.xregs.read(rs2) {
                cpu.pc &+= imm
            } else {
                cpu.pc &+= 4
            }
        },
        // BGEU
        Instruction(name: "BGEU", type: .B, opcode: 0b1100011, funct3: 0b111) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 8 & 0b1111_0000_0000) | (inst >> 25 & 0b0111_1111_0000), bitWidth: 13)
            if cpu.xregs.read(rs1) >= cpu.xregs.read(rs2) {
                cpu.pc &+= imm
            } else {
                cpu.pc &+= 4
            }
        },
        // LB
        Instruction(name: "LB", type: .I, opcode: 0b0000011, funct3: 0b000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            let addr = cpu.xregs.read(rs1) &+ imm
            let data = cpu.memory.read8(addr)
            cpu.xregs.write(rd, signExtend32(val: data, bitWidth: 8))
            cpu.pc &+= 4
        },
        // LH
        Instruction(name: "LH", type: .I, opcode: 0b0000011, funct3: 0b001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            let addr = cpu.xregs.read(rs1) &+ imm
            let data = cpu.memory.read16(addr)
            cpu.xregs.write(rd, signExtend32(val: data, bitWidth: 16))
            cpu.pc &+= 4
        },
        // LW
        Instruction(name: "LW", type: .I, opcode: 0b0000011, funct3: 0b010) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            let addr = cpu.xregs.read(rs1) &+ imm
            let data = cpu.memory.read32(addr)
            cpu.xregs.write(rd, data)
            cpu.pc &+= 4
        },
        // LBU
        Instruction(name: "LBU", type: .I, opcode: 0b0000011, funct3: 0b100) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            let addr = cpu.xregs.read(rs1) &+ imm
            let data = cpu.memory.read8(addr)
            cpu.xregs.write(rd, UInt32(data))
            cpu.pc &+= 4
        },
        // LHU
        Instruction(name: "LHU", type: .I, opcode: 0b0000011, funct3: 0b101) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            let addr = cpu.xregs.read(rs1) &+ imm
            let data = cpu.memory.read16(addr)
            cpu.xregs.write(rd, UInt32(data))
            cpu.pc &+= 4
        },
        // SB
        Instruction(name: "SB", type: .S, opcode: 0b0100011, funct3: 0b000) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 7 & 0b11111_00000) | (inst >> 25 & 0b11111), bitWidth: 12)
            let addr = cpu.xregs.read(rs1) &+ imm
            let data = UInt8(cpu.xregs.read(rs2) & 0xFF)
            cpu.memory.write8(addr, data)
            cpu.pc &+= 4
        },
        // SH
        Instruction(name: "SH", type: .S, opcode: 0b0100011, funct3: 0b001) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 7 & 0b11111_00000) | (inst >> 25 & 0b11111), bitWidth: 12)
            let addr = cpu.xregs.read(rs1) &+ imm
            let data = UInt16(cpu.xregs.read(rs2) & 0xFFFF)
            cpu.memory.write16(addr, data)
            cpu.pc &+= 4
        },
        // SW
        Instruction(name: "SW", type: .S, opcode: 0b0100011, funct3: 0b010) { cpu, inst in
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let imm = signExtend32(val: (inst >> 7 & 0b11111_00000) | (inst >> 25 & 0b11111), bitWidth: 12)
            let addr = cpu.xregs.read(rs1) &+ imm
            let data = cpu.xregs.read(rs2)
            cpu.memory.write32(addr, data)
            cpu.pc &+= 4
        },
        // ADDI
        Instruction(name: "ADDI", type: .I, opcode: 0b0010011, funct3: 0b000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &+ imm)
            cpu.pc &+= 4
        },
        // SLTI
        Instruction(name: "SLTI", type: .I, opcode: 0b0010011, funct3: 0b010) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) < imm ? 1 : 0)
            cpu.pc &+= 4
        },
        // SLTIU
        Instruction(name: "SLTIU", type: .I, opcode: 0b0010011, funct3: 0b011) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, UInt32(bitPattern: Int32(bitPattern: cpu.xregs.read(rs1)) < Int32(bitPattern: imm) ? 1 : 0))
            cpu.pc &+= 4
        },
        // XORI
        Instruction(name: "XORI", type: .I, opcode: 0b0010011, funct3: 0b100) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) ^ imm)
            cpu.pc &+= 4
        },
        // ORI
        Instruction(name: "ORI", type: .I, opcode: 0b0010011, funct3: 0b110) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) | imm)
            cpu.pc &+= 4
        },
        // ANDI
        Instruction(name: "ANDI", type: .I, opcode: 0b0010011, funct3: 0b111) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) & imm)
            cpu.pc &+= 4
        },
        // SLLI
        Instruction(name: "SLLI", type: .I, opcode: 0b0010011, funct3: 0b001, funct7: 0b0000000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let shamt = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) << shamt)
            cpu.pc &+= 4
        },
        // SRLI
        Instruction(name: "SRLI", type: .I, opcode: 0b0010011, funct3: 0b101, funct7: 0b0000000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let shamt = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) >> shamt)
            cpu.pc &+= 4
        },
        // SRAI
        Instruction(name: "SRAI", type: .I, opcode: 0b0010011, funct3: 0b101, funct7: 0b0100000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let shamt = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, UInt32(bitPattern: Int32(bitPattern: cpu.xregs.read(rs1)) >> shamt))
            cpu.pc &+= 4
        },
        // ADD
        Instruction(name: "ADD", type: .R, opcode: 0b0110011, funct3: 0b000, funct7: 0b0000000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &+ cpu.xregs.read(rs2))
            cpu.pc &+= 4
        },
        // SUB
        Instruction(name: "SUB", type: .R, opcode: 0b0110011, funct3: 0b000, funct7: 0b0100000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &- cpu.xregs.read(rs2))
            cpu.pc &+= 4
        },
        // SLL
        Instruction(name: "SLL", type: .R, opcode: 0b0110011, funct3: 0b001, funct7: 0b0000000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) << (cpu.xregs.read(rs2) & 0b11111))
            cpu.pc &+= 4
        },
        // SLT
        Instruction(name: "SLT", type: .R, opcode: 0b0110011, funct3: 0b010, funct7: 0b0000000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) < cpu.xregs.read(rs2) ? 1 : 0)
            cpu.pc &+= 4
        },
        // SLTU
        Instruction(name: "SLTU", type: .R, opcode: 0b0110011, funct3: 0b011, funct7: 0b0000000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) < cpu.xregs.read(rs2) ? 1 : 0)
            cpu.pc &+= 4
        },
    ]
}