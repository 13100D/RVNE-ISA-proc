`timescale 1ns / 1ps

module tb_riscv_pipeline_basic;
    reg clk;
    reg reset;

    // Instantiate the RISC-V pipeline module
    riscv_pipeline_basic uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Probe all signals from top.v
    wire [31:0] PC;
    wire [31:0] IF_ID_instr;
    wire [31:0] IF_ID_PC;

    wire [31:0] ID_EX_PC, ID_EX_instr;
    wire [31:0] ID_EX_read_data1, ID_EX_read_data2;
    wire [4:0]  ID_EX_rs1, ID_EX_rd;
    wire [0:0]  ID_EX_hint;
    wire [2:0]  ID_EX_funct3;
    wire [6:0]  ID_EX_funct7, ID_EX_opcode;
    wire [31:0] ID_EX_WVR_Out [0:15];
    wire [31:0] ID_EX_SVR_Out [0:3];
    wire [31:0] ID_EX_NSR_Out [0:15];

    wire [31:0] EX_MEM_alu_result;
    wire [4:0]  EX_MEM_rd;
    wire [0:0]  EX_MEM_hint;
    wire [2:0]  EX_MEM_funct3;
    wire [6:0]  EX_MEM_funct7, EX_MEM_opcode;
    wire [31:0] EX_MEM_N_ACC, EX_MEM_S_ACC;

    wire [31:0] MEM_WB_alu_result;
    wire [4:0]  MEM_WB_rd;
    wire [2:0]  MEM_WB_funct3;
    wire [6:0]  MEM_WB_funct7, MEM_WB_opcode;
    wire [31:0] MEM_WB_memOut [15:0];
    wire [31:0] MEM_WB_N_ACC, MEM_WB_S_ACC;

    wire [31:0] SVR_WVR [0:31];
    wire [31:0] RPR, VTR, NTR;
    wire [31:0] NSR [0:31];

    // Assign signals to their corresponding top.v signals
    assign PC = uut.PC;
    assign IF_ID_instr = uut.IF_ID_instr;
    assign IF_ID_PC = uut.IF_ID_PC;

    assign ID_EX_PC = uut.ID_EX_PC;
    assign ID_EX_instr = uut.ID_EX_instr;
    assign ID_EX_read_data1 = uut.ID_EX_read_data1;
    assign ID_EX_read_data2 = uut.ID_EX_read_data2;
    assign ID_EX_rs1 = uut.ID_EX_rs1;
    assign ID_EX_rd = uut.ID_EX_rd;
    assign ID_EX_hint = uut.ID_EX_hint;
    assign ID_EX_funct3 = uut.ID_EX_funct3;
    assign ID_EX_funct7 = uut.ID_EX_funct7;
    assign ID_EX_opcode = uut.ID_EX_opcode;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            assign ID_EX_WVR_Out[i] = uut.ID_EX_WVR_Out[i];
            assign ID_EX_NSR_Out[i] = uut.ID_EX_NSR_Out[i];
        end
    endgenerate
    for (i = 0; i < 4; i = i + 1) begin
        assign ID_EX_SVR_Out[i] = uut.ID_EX_SVR_Out[i];
    end

    assign EX_MEM_alu_result = uut.EX_MEM_alu_result;
    assign EX_MEM_rd = uut.EX_MEM_rd;
    assign EX_MEM_hint = uut.EX_MEM_hint;
    assign EX_MEM_funct3 = uut.EX_MEM_funct3;
    assign EX_MEM_funct7 = uut.EX_MEM_funct7;
    assign EX_MEM_opcode = uut.EX_MEM_opcode;
    assign EX_MEM_N_ACC = uut.EX_MEM_N_ACC;
    assign EX_MEM_S_ACC = uut.EX_MEM_S_ACC;

    assign MEM_WB_alu_result = uut.MEM_WB_alu_result;
    assign MEM_WB_rd = uut.MEM_WB_rd;
    assign MEM_WB_funct3 = uut.MEM_WB_funct3;
    assign MEM_WB_funct7 = uut.MEM_WB_funct7;
    assign MEM_WB_opcode = uut.MEM_WB_opcode;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            assign MEM_WB_memOut[i] = uut.MEM_WB_memOut[i];
        end
    endgenerate
    assign MEM_WB_N_ACC = uut.MEM_WB_N_ACC;
    assign MEM_WB_S_ACC = uut.MEM_WB_S_ACC;

    generate
        for (i = 0; i < 32; i = i + 1) begin
            assign SVR_WVR[i] = uut.SVR_WVR[i];
            assign NSR[i] = uut.NSR[i];
        end
    endgenerate
    assign RPR = uut.RPR;
    assign VTR = uut.VTR;
    assign NTR = uut.NTR;

    // Clock generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Initialize instruction memory
    initial begin
        uut.instruction_memory[0] = 32'b000100011000_00010_100_1_0010_0000001;  
        uut.instruction_memory[1] = 32'b101100000000_00101_100_0_0101_0000010;
        uut.instruction_memory[2] = 32'b0000000_01000_01110_000_00000_0000100;
        uut.instruction_memory[3] = 32'b0000001_01001_01101_010_00000_0000100;
        uut.instruction_memory[4] = 32'b0000010_01011_01111_100_00000_0000100;
        uut.instruction_memory[5] = 32'b1110000_00010_10001_000_00000_0001000;
        uut.instruction_memory[6] = 32'b1110001_00010_10001_000_00001_0001000;
        uut.instruction_memory[8] = 32'b1110001_00010_10001_000_00010_0001000;
        uut.instruction_memory[9] = 32'b1110001_00010_10001_000_00011_0001000;
        uut.instruction_memory[10] = 32'b1110000_00010_10001_000_00000_0001000;
    end

    // Assert RESET for one clock cycle
    initial begin
        reset = 1; 
        #10;       
        reset = 0; 
    end

    // Monitoring Signals
//        initial begin
//        $monitor("Time: %0t | clk: %b | reset: %b | PC: %h | IF/ID: PC=%h instr=%h | \
//            ID/EX: PC=%h instr=%h rd=%d rs1=%d hint=%b read_data1=%h read_data2=%h funct3=%b funct7=%b opcode=%b | \
//            EX/MEM: ALU=%h rd=%d hint=%b funct3=%b funct7=%b opcode=%b N_ACC=%h S_ACC=%h | \
//            MEM/WB: ALU=%h rd=%d funct7=%b opcode=%b memOut[0..15]=%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h \
//            N_ACC=%h S_ACC=%h | \
//            SVR_WVR[0..31]=%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h | \
//            RPR=%h | VTR=%h | NTR=%h | NSR[0..31]=%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
//            $time, clk, reset, PC,
//            IF_ID_PC, IF_ID_instr,
//            ID_EX_PC, ID_EX_instr, ID_EX_rd, ID_EX_rs1, ID_EX_hint, ID_EX_read_data1, ID_EX_read_data2, ID_EX_funct3, ID_EX_funct7, ID_EX_opcode,
//            EX_MEM_alu_result, EX_MEM_rd, EX_MEM_hint, EX_MEM_funct3, EX_MEM_funct7, EX_MEM_opcode, EX_MEM_N_ACC, EX_MEM_S_ACC,
//            MEM_WB_alu_result, MEM_WB_rd, MEM_WB_funct7, MEM_WB_opcode,
//            MEM_WB_memOut[0], MEM_WB_memOut[1], MEM_WB_memOut[2], MEM_WB_memOut[3], MEM_WB_memOut[4], MEM_WB_memOut[5], MEM_WB_memOut[6], MEM_WB_memOut[7],
//            MEM_WB_memOut[8], MEM_WB_memOut[9], MEM_WB_memOut[10], MEM_WB_memOut[11], MEM_WB_memOut[12], MEM_WB_memOut[13], MEM_WB_memOut[14], MEM_WB_memOut[15],
//            MEM_WB_N_ACC, MEM_WB_S_ACC,
//            SVR_WVR[0], SVR_WVR[1], SVR_WVR[2], SVR_WVR[3], SVR_WVR[4], SVR_WVR[5], SVR_WVR[6], SVR_WVR[7],
//            SVR_WVR[8], SVR_WVR[9], SVR_WVR[10], SVR_WVR[11], SVR_WVR[12], SVR_WVR[13], SVR_WVR[14], SVR_WVR[15],
//            SVR_WVR[16], SVR_WVR[17], SVR_WVR[18], SVR_WVR[19], SVR_WVR[20], SVR_WVR[21], SVR_WVR[22], SVR_WVR[23],
//            SVR_WVR[24], SVR_WVR[25], SVR_WVR[26], SVR_WVR[27], SVR_WVR[28], SVR_WVR[29], SVR_WVR[30], SVR_WVR[31],
//            RPR, VTR, NTR,
//            NSR[0], NSR[1], NSR[2], NSR[3], NSR[4], NSR[5], NSR[6], NSR[7],
//            NSR[8], NSR[9], NSR[10], NSR[11], NSR[12], NSR[13], NSR[14], NSR[15],
//            NSR[16], NSR[17], NSR[18], NSR[19], NSR[20], NSR[21], NSR[22], NSR[23],
//            NSR[24], NSR[25], NSR[26], NSR[27], NSR[28], NSR[29], NSR[30], NSR[31]
//        );
//    end


    // Simulation time
    initial begin
        #200; 
        $finish; 
    end
endmodule
