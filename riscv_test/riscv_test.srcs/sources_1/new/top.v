module riscv_pipeline_basic (
    input clk,
    input reset
);

    // Instruction memory, register file, and data memory
    reg [31:0] instruction_memory [0:255];  // 256 instructions
    reg [31:0] data_memory [0:255];         // 256 words of data
    reg [31:0] register_file [0:31];        // 32 general-purpose registers

    // Pipeline registers
    reg [31:0] IF_ID_instr, IF_ID_PC;
    reg [31:0] ID_EX_PC, ID_EX_instr;
    reg [31:0] ID_EX_read_data1, ID_EX_read_data2;
    reg [4:0]  ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
    reg [31:0] EX_MEM_alu_result, EX_MEM_read_data2;
    reg [4:0]  EX_MEM_rd;
    reg [31:0] MEM_WB_alu_result;
    reg [4:0]  MEM_WB_rd;

    // Program Counter (PC)
    reg [31:0] PC;

    // Initialize components
    initial begin
        PC = 0;
        // Initialize instruction memory, data memory, and register file here if needed
    end

    // FETCH stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IF_ID_instr <= 0;
            IF_ID_PC <= 0;
        end else begin
            IF_ID_instr <= instruction_memory[PC[31:2]];  // Fetch instruction
            IF_ID_PC <= PC;
            PC <= PC + 4;  // Increment PC
        end
    end

    // DECODE stage
    wire [6:0] opcode = IF_ID_instr[6:0];
    wire [4:0] rs1 = IF_ID_instr[19:15];
    wire [4:0] rs2 = IF_ID_instr[24:20];
    wire [4:0] rd = IF_ID_instr[11:7];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_EX_PC <= 0;
            ID_EX_instr <= 0;
        end else begin
            ID_EX_PC <= IF_ID_PC;
            ID_EX_instr <= IF_ID_instr;
            ID_EX_read_data1 <= register_file[rs1];
            ID_EX_read_data2 <= register_file[rs2];
            ID_EX_rs1 <= rs1;
            ID_EX_rs2 <= rs2;
            ID_EX_rd <= rd;
        end
    end

    // EXECUTE stage
    wire [31:0] alu_input1 = ID_EX_read_data1;
    wire [31:0] alu_input2 = ID_EX_read_data2;
    reg [31:0] alu_result;

    always @(*) begin
        case (opcode)
            7'b0110011: alu_result = alu_input1 + alu_input2;  // Example for R-type (ADD)
            7'b0010011: alu_result = alu_input1 + {{20{ID_EX_instr[31]}}, ID_EX_instr[31:20]}; // Example for I-type (ADDI)
            default: alu_result = 0;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_alu_result <= 0;
        end else begin
            EX_MEM_alu_result <= alu_result;
            EX_MEM_read_data2 <= ID_EX_read_data2;
            EX_MEM_rd <= ID_EX_rd;
        end
    end

    // MEMORY stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_alu_result <= 0;
        end else begin
            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_rd <= EX_MEM_rd;
        end
    end

    // WRITEBACK stage
    always @(posedge clk or posedge reset) begin
        if (!reset) begin
            register_file[MEM_WB_rd] <= MEM_WB_alu_result;  // Write back to register file
        end
    end

endmodule
