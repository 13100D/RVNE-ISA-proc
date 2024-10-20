module riscv_pipeline_basic (
    input clk,
    input reset
);

    // Instruction memory, register file, SVR_WVR, and data memory
    reg [31:0] instruction_memory [0:255];  // 256 instructions
    reg [31:0] data_memory [0:255];         // 256 words of data
    reg [31:0] register_file [0:31];        // 32 general-purpose registers
    reg [31:0] SVR_WVR [0:31];              // 16 SVR, 16 WVR

    // Pipeline registers
    reg [31:0] IF_ID_instr, IF_ID_PC;
    
    reg [31:0] ID_EX_PC, ID_EX_instr;
    reg [31:0] ID_EX_read_data;
    reg [4:0] ID_EX_rs1, ID_EX_rd;
    reg [0:0] ID_EX_hint;
    reg [11:0] ID_EX_imm;
    reg [2:0] ID_EX_funct3;
    
    reg [31:0] EX_MEM_alu_result;
    reg [4:0]  EX_MEM_rd;
    reg [0:0] EX_MEM_hint;
    reg [2:0] EX_MEM_funct3;
    
    reg [31:0] MEM_WB_alu_result;
    reg [4:0]  MEM_WB_rd;
    reg [2:0] MEM_WB_funct3;
    reg [31:0] MEM_WB_memOut [15:0];

    // Program Counter (PC)
    reg [31:0] PC;

    // Iterator 
    integer i;

    // Initialize components
    initial begin
        PC = 0;
       
        // Initialize the register file
        for (i = 0; i < 32; i = i + 1) begin
            register_file[i] <= i;
        end
        
        // Initialize the data memory
        for (i = 0; i < 256; i = i + 1) begin
            data_memory[i] <= i;
        end
    end

    // FETCH stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IF_ID_instr <= 0;
            IF_ID_PC <= 0;
        end else begin
            IF_ID_instr <= instruction_memory[PC[7:0]];  // Fetch instruction
            IF_ID_PC <= PC;
            PC <= PC + 1;  // Increment PC
        end
    end

    // DECODE stage
    wire [6:0] opcode = IF_ID_instr[6:0];
    wire [4:0] rd = {(IF_ID_instr[0]), IF_ID_instr[10:7]};
    wire [0:0] hint = IF_ID_instr[11];
    wire [2:0] funct3 = IF_ID_instr[14:12];
    wire [4:0] rs1 = IF_ID_instr[19:15];
    wire [11:0] imm = IF_ID_instr[31:20];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_EX_PC <= 0;
            ID_EX_instr <= 0;
        end else begin
            ID_EX_PC <= IF_ID_PC;
            ID_EX_instr <= IF_ID_instr;
            ID_EX_rd <= rd;
            ID_EX_read_data <= register_file[rs1];
            ID_EX_rs1 <= rs1;
            ID_EX_hint <= hint;
            ID_EX_imm <= imm;
            ID_EX_funct3 <= funct3;
        end
    end

    // EXECUTE stage
    wire [31:0] alu_input1 = ID_EX_read_data;
    wire [31:0] alu_input2 = ID_EX_imm;
    reg [31:0] alu_result = 0;

    always @(*) begin
        alu_result = alu_input1 + alu_input2;  
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_alu_result <= 0;
        end else begin
            EX_MEM_alu_result <= alu_result;
            EX_MEM_rd <= ID_EX_rd;
            EX_MEM_hint <= ID_EX_hint;
            EX_MEM_funct3 <= ID_EX_funct3;
        end
    end

    // MEMORY stage
    reg [31:0] memOut [15:0];
    
    always @ (*) begin
        case(EX_MEM_funct3)
            3'b001: begin 
                    memOut[EX_MEM_rd[3:0]] = data_memory[EX_MEM_alu_result%256];
                end
            3'b010: begin
                    for (i = 0; i < 4; i = i + 1) begin
                        memOut[(EX_MEM_rd[3:0] + i)%16] = data_memory[(EX_MEM_alu_result + i)%256];
                    end
                end
            3'b100: begin
                    for (i = 0; i < 16; i = i + 1) begin
                        memOut[(EX_MEM_rd[3:0] + i)%16] = data_memory[(EX_MEM_alu_result + i)%256];
                    end
                end
        endcase
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_alu_result <= 0;
        end else begin
            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_rd <= EX_MEM_rd;
            MEM_WB_funct3 <= EX_MEM_funct3;
            
            for (i = 0; i < 16; i = i + 1) begin
                MEM_WB_memOut[i] <= memOut[i];
            end
        end
    end

    // WRITEBACK stage
    reg [3:0] SVR_WVR_Addr; 
    
    always @ (*) begin
        if (!reset) begin   
            case(MEM_WB_funct3)
                3'b001: begin 
                        SVR_WVR[MEM_WB_rd] = MEM_WB_memOut[MEM_WB_rd[3:0]];
                    end
                3'b010: begin
                    for (i = 0; i < 4; i = i + 1) begin
                        SVR_WVR_Addr = ((MEM_WB_rd[3:0] + i)%16);
                        SVR_WVR[{MEM_WB_rd[4],SVR_WVR_Addr}] = MEM_WB_memOut[(MEM_WB_rd[3:0] + i)%16];
                    end
                end
                3'b100: begin
                    for (i = 0; i < 16; i = i + 1) begin
                        SVR_WVR_Addr = ((MEM_WB_rd[3:0] + i)%16);
                        SVR_WVR[{MEM_WB_rd[4],SVR_WVR_Addr}] = MEM_WB_memOut[(MEM_WB_rd[3:0] + i)%16];
                    end
                end
            endcase
        end 
    end

endmodule