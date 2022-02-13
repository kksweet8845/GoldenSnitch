# Golden Snitch Specs



# Concepts
This project is based on the CV32E40P project, this is also a 4 stages, IF, ID, EX, WB.
The IF stage will fetch the instruction from memory and forward to the next stage. Each 
stage has the ready and valid signal, which represents ready to receive data and the data
sent by this stage is valid. Then ID stage will decodes the instruction and controlled by a 
controller to decide this instruction can be dispatch or not. Then the EX stage will execute 
the operation like ALU, Multipiply, Division then forward to the Register File.

The IF stage will fetch the instruction. Before they fetched the instructioin, the state of IF stage will be ready and ~valid. That means the IF stage is ready to receive the pc selectioin but the current instructioin signal is not valid.

After the IF stage fetched the data, the data will be forwarded to the ID stage and then if the ID stage is not ready, the IF stage will be halted until the ID stage is ready.

After the ID stage receives the instruction and finish decoding the instruction, it will depend on controller that the data should be forwarded to EX stage based on ready stage and other situations, such as load to use, multiple cycle instruction, branch jump, unconditional jump, etc.
- Load to use 
- Multiple cycle instruction
- branch jump
- unconditional jump

The register file has two write back ports, one is for instruction from ex stage, and the other one is for load instruction. 


# Decoder Output signals
The following list is the list of decoder output signals. 
- ImmType       : The type of immediate value of a instruction
    - 3'd0 :    No imm is needed
    - 3'd1 :    I type
    - 3'd2 :    S type, SW, SB, SH
    - 3'd3 :    B-type
    - 3'd4 :    U type, AUIPC, LUI
    - 3'd5 :    J-type, JAL
- PCtoRegSrc    : 
    - 1'b0 :  pc + 4
    - 1'b1 :  pc + imm
- ALUType       :
    - The operation of ALU actually needs to work
    - This includes the operation of branch jump

- BType         : Indicate the current instruction is a branch
- PCSrc         : Indicate the next selection of pc address should be.
    - 2'b00     : pc + 4
    - 2'b01     : pc + imm
    - 2'b10     : rs1 + imm
    - 2'b11     : The selection depends on branch result

- MemWrite, MemRead : Indicate the current instruction is Store or Load instr.
- RDSrc         : The src of write back, rd (deprecated, no need for this signals)
    - 1'b1      : pc
    - 1'b0      : alu_out

- MemtoRegSrc   : Indicate would the memory value to register
    - 1'b0      : pc_or_alu_out
    - 1'b1      : mem_out

- ALUSrc        : Indicate the src of imm or rs2
    - 1'b0      : imm
    - 1'b1      : rs2

- RegWrite      : Indicate the current instr needs write back or not
    - 1'b0      : no write back
    - 1'b1      : write back

- DataSize      : Indicate the desired size of load/store data from load/store instruction































