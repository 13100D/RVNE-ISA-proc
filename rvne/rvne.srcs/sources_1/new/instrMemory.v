`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.10.2024 16:32:01
// Design Name: 
// Module Name: instrMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instrMemory(
    input [4:0] PC,
    output [31:0] instruction
    );
    
    reg [31:0] [31:0] instrMemory;
    
    assign instruction = instrMemory[PC];
    
endmodule
