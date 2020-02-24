This project exhibits a CPU I designed as part of a computer architecture class at UTK. This is an 8-bit CPU implemented in Logisim that facilitates 16-bit instructions performing logical/arithmetic operations as well as basic branching and memory operations.

Instruction Format
All instructions for the CPU are 16-bits (2 bytes). There are two instruction types:

Type	Format

Register (R-type):	Rd[15:14], Rs1[13:12], Rs2[11:10], Shift[9:7], Unused[6:5], Op[4:0]

Immediate (I-type):	Rd/Rs2[15:14], Rs1[13:12], Imm[11:5], Op[4:0]


Opcodes

The CPU decodes the following opcodes to the given instruction.

Opcode	Type	Instruction	Description

00000	R-type	add rd, rs1, rs2	rd = rs1 + rs2

00100	R-type	sub rd, rs1, rs2	rd = rs1 - rs2

10000	R-type	and rd, rs1, rs2	rd = rs1 & rs2

10100	R-type	or rd, rs1, rs2	rd = rs1 | rs2

11000	R-type	xor rd, rs1, rs2	rd = rs1 ^ rs2

00101	I-type	lb rd, imm(rs1)	rd = *(rs1 + imm)

00111	I-type	sb rs2, imm(rs1)	*(rs1 + imm) = rs2

00001	I-type	addi rd, rs1, imm	rd = rs1 + imm

10011	I-type	beq rs1, rs2, label	if rs1 == rs2 then pc += imm

10111	I-type	bne rs1, rs2, label	if rs1 != rs2 then pc += imm

11011	I-type	blt rs1, rs2, label	if rs1 < rs2 then pc += imm

11111	I-type	ble rs1, rs2, label	if rs1 <= rs2 then pc += imm


If you wish to try out the CPU, simply download logisim and open the CPU.circ file. You must manually program the ROM contents with encoded instructions, then cycle the clock to increment the program counter PC and thereby execute the instructions. The four registers (corresponding to bits 00-11 in the instruction format) can be seen in the Register File. Examine their contents while executing instructions to verify the CPU functions correctly.

I also include a few screenshots if you just wish to get a general idea of how everything works together.
