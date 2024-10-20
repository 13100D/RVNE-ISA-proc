`timescale 1ns / 1ps

module top(
    input clk,
    output [31:0] wvr_status,
    output [31:0] svr_status
    );
    
    reg [31:0] [31:0] regFile;
    reg [31:0] [31:0] WVR_SVR;
    reg [1023:0] [31:0] dataMemory;
    reg [4:0] PC = 5'b00000;
    reg [31:0] instrReg;
    
    wire [4:0] WVR_SVR_addr;
    
    wire [31:0] base; 
    
    wire [31:0] dataMemAddr;
    
    wire [31:0] rdata;
    
    instrMemory IM(.PC(PC), .instruction(instrReg));
    controlUnit CU(.opCode(instrReg[6:0]), .funct3(instrReg[14:12]), .rd(instrReg[10:7]), .WVR_SVR_addr(WVR_SVR_addr));
    
    // Fetch Stage
    always @ (*)
    begin
        PC = PC + 1;
    end    
    
    // Decode Stage
    always @ (*)
    begin
        base = regFile[instrReg[19:15]];
    end
    
    // Execute Stage
    always @ (*)
    begin
        dataMemAddr = base + instrReg[31:20];
    end
    
    // Memory Stage 
    always @ (*)
    begin
        rdata = dataMemory[dataMemAddr];
    end
    
    // Writeback Stage 
    always @ (*)
    begin
        WVR_SVR[WVR_SVR_addr] = rdata;
    end
    
endmodule
