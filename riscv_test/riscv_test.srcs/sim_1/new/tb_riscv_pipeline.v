`timescale 1ns / 1ps

module tb_riscv_pipeline_basic;
    reg clk;
    reg reset;

    // Instantiate the RISC-V pipeline module
    riscv_pipeline_basic uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Probe Signals 
    wire [31:0] PC;
    wire [31:0] IF_ID_instr;
    wire [31:0] IF_ID_PC;
    
    wire [31:0] ID_EX_PC;
    wire [31:0] ID_EX_instr;
    wire [31:0] ID_EX_read_data;
    wire [4:0]  ID_EX_rs1;
    wire [4:0]  ID_EX_rd;
    wire [0:0]  ID_EX_hint;
    wire [11:0] ID_EX_imm;
    wire [2:0]  ID_EX_funct3;
    
    wire [31:0] EX_MEM_alu_result;
    wire [4:0]  EX_MEM_rd;
    wire        EX_MEM_hint;
    wire [2:0]  EX_MEM_funct3;
    
    wire [31:0] MEM_WB_alu_result;
    wire [4:0]  MEM_WB_rd;

    wire [31:0] MEM_WB_memOut [15:0];
    wire [31:0] SVR_WVR [0:31];
    
    assign PC = uut.PC;
    assign IF_ID_instr = uut.IF_ID_instr;
    assign IF_ID_PC = uut.IF_ID_PC;
    
    assign ID_EX_PC = uut.ID_EX_PC;
    assign ID_EX_instr = uut.ID_EX_instr;
    assign ID_EX_read_data = uut.ID_EX_read_data;
    assign ID_EX_rs1 = uut.ID_EX_rs1;
    assign ID_EX_rd = uut.ID_EX_rd;
    assign ID_EX_hint = uut.ID_EX_hint;
    assign ID_EX_imm = uut.ID_EX_imm;
    assign ID_EX_funct3 = uut.ID_EX_funct3;
    
    assign EX_MEM_alu_result = uut.EX_MEM_alu_result;
    assign EX_MEM_rd = uut.EX_MEM_rd;
    assign EX_MEM_hint = uut.EX_MEM_hint;
    assign EX_MEM_funct3 = uut.EX_MEM_funct3;
    
    assign MEM_WB_alu_result = uut.MEM_WB_alu_result;
    assign MEM_WB_rd = uut.MEM_WB_rd;

    assign MEM_WB_memOut[0] = uut.MEM_WB_memOut[0];
    assign MEM_WB_memOut[1] = uut.MEM_WB_memOut[1];
    assign MEM_WB_memOut[2] = uut.MEM_WB_memOut[2];
    assign MEM_WB_memOut[3] = uut.MEM_WB_memOut[3];
    assign MEM_WB_memOut[4] = uut.MEM_WB_memOut[4];
    assign MEM_WB_memOut[5] = uut.MEM_WB_memOut[5];
    assign MEM_WB_memOut[6] = uut.MEM_WB_memOut[6];
    assign MEM_WB_memOut[7] = uut.MEM_WB_memOut[7];
    assign MEM_WB_memOut[8] = uut.MEM_WB_memOut[8];
    assign MEM_WB_memOut[9] = uut.MEM_WB_memOut[9];
    assign MEM_WB_memOut[10] = uut.MEM_WB_memOut[10];
    assign MEM_WB_memOut[11] = uut.MEM_WB_memOut[11];
    assign MEM_WB_memOut[12] = uut.MEM_WB_memOut[12];
    assign MEM_WB_memOut[13] = uut.MEM_WB_memOut[13];
    assign MEM_WB_memOut[14] = uut.MEM_WB_memOut[14];
    assign MEM_WB_memOut[15] = uut.MEM_WB_memOut[15];

    assign SVR_WVR[0] = uut.SVR_WVR[0];
    assign SVR_WVR[1] = uut.SVR_WVR[1];
    assign SVR_WVR[2] = uut.SVR_WVR[2];
    assign SVR_WVR[3] = uut.SVR_WVR[3];
    assign SVR_WVR[4] = uut.SVR_WVR[4];
    assign SVR_WVR[5] = uut.SVR_WVR[5];
    assign SVR_WVR[6] = uut.SVR_WVR[6];
    assign SVR_WVR[7] = uut.SVR_WVR[7];
    assign SVR_WVR[8] = uut.SVR_WVR[8];
    assign SVR_WVR[9] = uut.SVR_WVR[9];
    assign SVR_WVR[10] = uut.SVR_WVR[10];
    assign SVR_WVR[11] = uut.SVR_WVR[11];
    assign SVR_WVR[12] = uut.SVR_WVR[12];
    assign SVR_WVR[13] = uut.SVR_WVR[13];
    assign SVR_WVR[14] = uut.SVR_WVR[14];
    assign SVR_WVR[15] = uut.SVR_WVR[15];
    assign SVR_WVR[16] = uut.SVR_WVR[16];
    assign SVR_WVR[17] = uut.SVR_WVR[17];
    assign SVR_WVR[18] = uut.SVR_WVR[18];
    assign SVR_WVR[19] = uut.SVR_WVR[19];
    assign SVR_WVR[20] = uut.SVR_WVR[20];
    assign SVR_WVR[21] = uut.SVR_WVR[21];
    assign SVR_WVR[22] = uut.SVR_WVR[22];
    assign SVR_WVR[23] = uut.SVR_WVR[23];
    assign SVR_WVR[24] = uut.SVR_WVR[24];
    assign SVR_WVR[25] = uut.SVR_WVR[25];
    assign SVR_WVR[26] = uut.SVR_WVR[26];
    assign SVR_WVR[27] = uut.SVR_WVR[27];
    assign SVR_WVR[28] = uut.SVR_WVR[28];
    assign SVR_WVR[29] = uut.SVR_WVR[29];
    assign SVR_WVR[30] = uut.SVR_WVR[30];
    assign SVR_WVR[31] = uut.SVR_WVR[31];


    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Initialize instruction memory
    initial begin
        uut.instruction_memory[0] = 32'b000011100000_00000_001_1_0000_0000001; 
        uut.instruction_memory[1] = 32'b000000000100_00001_010_0_0001_0000001; 
        uut.instruction_memory[2] = 32'b000100011000_00010_100_1_0010_0000001; 
        uut.instruction_memory[3] = 32'b000000010000_00011_001_0_0011_0000010;
        uut.instruction_memory[4] = 32'b000001010000_00100_010_1_0100_0000010; 
        uut.instruction_memory[5] = 32'b101100000000_00101_100_0_0101_0000010;
    end

    // Assert RESET for one clock cycle
    initial begin
        reset = 1; 
        #10;       
        reset = 0; 
    end
    
     // Monitoring Signals 
    initial begin
        $monitor(
            "Time: %0dns | PC: %0d | IF_ID_instr: %h | IF_ID_PC: %d | ID_EX_PC: %d | ID_EX_instr: %h | ID_EX_read_data: %d | ID_EX_rd: %d | ID_EX_rs1: %d | ID_EX_hint: %b | ID_EX_imm: %d | ID_EX_funct3: %b | EX_MEM_alu_result: %d | EX_MEM_rd: %d | EX_MEM_hint: %b | EX_MEM_funct3: %b | MEM_WB_alu_result: %d | MEM_WB_rd: %d | MEM_WB_memOut[0]: %d | MEM_WB_memOut[1]: %d | MEM_WB_memOut[2]: %d | MEM_WB_memOut[3]: %d | MEM_WB_memOut[4]: %d | MEM_WB_memOut[5]: %d | MEM_WB_memOut[6]: %d | MEM_WB_memOut[7]: %d | MEM_WB_memOut[8]: %d | MEM_WB_memOut[9]: %d | MEM_WB_memOut[10]: %d | MEM_WB_memOut[11]: %d | MEM_WB_memOut[12]: %d | MEM_WB_memOut[13]: %d | MEM_WB_memOut[14]: %d | MEM_WB_memOut[15]: %d | SVR_WVR[0]: %d | SVR_WVR[1]: %d | SVR_WVR[2]: %d | SVR_WVR[3]: %d | SVR_WVR[4]: %d | SVR_WVR[5]: %d | SVR_WVR[6]: %d | SVR_WVR[7]: %d | SVR_WVR[8]: %d | SVR_WVR[9]: %d | SVR_WVR[10]: %d | SVR_WVR[11]: %d | SVR_WVR[12]: %d | SVR_WVR[13]: %d | SVR_WVR[14]: %d | SVR_WVR[15]: %d | SVR_WVR[16]: %d | SVR_WVR[17]: %d | SVR_WVR[18]: %d | SVR_WVR[19]: %d | SVR_WVR[20]: %d | SVR_WVR[21]: %d | SVR_WVR[22]: %d | SVR_WVR[23]: %d | SVR_WVR[24]: %d | SVR_WVR[25]: %d | SVR_WVR[26]: %d | SVR_WVR[27]: %d | SVR_WVR[28]: %d | SVR_WVR[29]: %d | SVR_WVR[30]: %d | SVR_WVR[31]: %d",
            $time,
            uut.PC,
            uut.IF_ID_instr,
            uut.IF_ID_PC,
            uut.ID_EX_PC,
            uut.ID_EX_instr,
            uut.ID_EX_read_data,
            uut.ID_EX_rd,
            uut.ID_EX_rs1,
            uut.ID_EX_hint,
            uut.ID_EX_imm,
            uut.ID_EX_funct3,
            uut.EX_MEM_alu_result,
            uut.EX_MEM_rd,
            uut.EX_MEM_hint,
            uut.EX_MEM_funct3,
            uut.MEM_WB_alu_result,
            uut.MEM_WB_rd,
            uut.MEM_WB_memOut[0],
            uut.MEM_WB_memOut[1],
            uut.MEM_WB_memOut[2],
            uut.MEM_WB_memOut[3],
            uut.MEM_WB_memOut[4],
            uut.MEM_WB_memOut[5],
            uut.MEM_WB_memOut[6],
            uut.MEM_WB_memOut[7],
            uut.MEM_WB_memOut[8],
            uut.MEM_WB_memOut[9],
            uut.MEM_WB_memOut[10],
            uut.MEM_WB_memOut[11],
            uut.MEM_WB_memOut[12],
            uut.MEM_WB_memOut[13],
            uut.MEM_WB_memOut[14],
            uut.MEM_WB_memOut[15],
            uut.SVR_WVR[0],
            uut.SVR_WVR[1],
            uut.SVR_WVR[2],
            uut.SVR_WVR[3],
            uut.SVR_WVR[4],
            uut.SVR_WVR[5],
            uut.SVR_WVR[6],
            uut.SVR_WVR[7],
            uut.SVR_WVR[8],
            uut.SVR_WVR[9],
            uut.SVR_WVR[10],
            uut.SVR_WVR[11],
            uut.SVR_WVR[12],
            uut.SVR_WVR[13],
            uut.SVR_WVR[14],
            uut.SVR_WVR[15],
            uut.SVR_WVR[16],
            uut.SVR_WVR[17],
            uut.SVR_WVR[18],
            uut.SVR_WVR[19],
            uut.SVR_WVR[20],
            uut.SVR_WVR[21],
            uut.SVR_WVR[22],
            uut.SVR_WVR[23],
            uut.SVR_WVR[24],
            uut.SVR_WVR[25],
            uut.SVR_WVR[26],
            uut.SVR_WVR[27],
            uut.SVR_WVR[28],
            uut.SVR_WVR[29],
            uut.SVR_WVR[30],
            uut.SVR_WVR[31]
        );
    end

    // Simulation time
    initial begin
        #200; 
        $finish; 
    end
endmodule
