`timescale 1ns / 1ps

module tb_riscv_pipeline_basic();

    reg clk;
    reg reset;

    // Instantiate the RISC-V processor
    riscv_pipeline_basic uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Clock period of 10ns (100MHz)
    end

    // Testbench initialization
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;

        // Apply reset
        #10 reset = 0;
        
        // Initialize instruction memory with some simple RISC-V instructions
        uut.instruction_memory[0] = 32'b00000000000100000000000110110011; // ADD x3, x0, x1 (x3 = x0 + x1)
        uut.instruction_memory[1] = 32'b00000000001000010000001000110011; // ADD x4, x1, x2 (x4 = x1 + x2)
        uut.instruction_memory[2] = 32'b00000000001100100000001100110011; // ADD x6, x2, x3 (x6 = x2 + x3)

        // Initialize register values
        uut.register_file[0] = 0;  // x0 = 0 (hardwired zero)
        uut.register_file[1] = 10; // x1 = 10
        uut.register_file[2] = 20; // x2 = 20

        // Run the simulation for some time to execute the instructions
        #100;

        // Check the results after execution
        $display("Register x3: %d", uut.register_file[3]); // Expected x3 = 10
        $display("Register x4: %d", uut.register_file[4]); // Expected x4 = 30
        $display("Register x6: %d", uut.register_file[6]); // Expected x6 = 40

        // Finish the simulation
        #10;
        $finish;
    end

endmodule
