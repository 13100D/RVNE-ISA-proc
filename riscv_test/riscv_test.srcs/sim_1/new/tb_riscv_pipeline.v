`timescale 1ns / 1ps

module tb_riscv_pipeline_basic;
    reg clk;
    reg reset;

    // Instantiate the RISC-V pipeline module
    riscv_pipeline_basic uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units clock period
    end

    // Initialize memory and registers to specific values
    initial begin
        // Initialize some instructions in the instruction memory
        uut.instruction_memory[0] = 32'b000011100000_00000_001_1_0000_0000001; 
        uut.instruction_memory[1] = 32'b000000000100_00001_010_0_0001_0000001; 
        uut.instruction_memory[2] = 32'b000100011000_00010_100_1_0010_0000001; 
        uut.instruction_memory[3] = 32'b000000010000_00011_001_0_0011_0000010;
        uut.instruction_memory[4] = 32'b000001010000_00100_010_1_0100_0000010; 
        uut.instruction_memory[5] = 32'b101100000000_00101_100_0_0101_0000010;
    end

    // Reset sequence
    initial begin
        reset = 1; // Assert reset
        #10;       // Hold reset for 10 time units
        reset = 0; // Deassert reset
    end

    // VCD file generation
    initial begin
        $dumpfile("riscv_pipeline.vcd"); // Specify the VCD file name
        $dumpvars(0, tb_riscv_pipeline_basic); // Dump all variables in the module and its submodules
    end

    // Monitoring signals including SVR_WVR registers
    initial begin
        // Monitor the relevant signals and all entries in SVR_WVR
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
        #200; // Run the simulation for 200 time units
        $finish; // End simulation
    end
endmodule
