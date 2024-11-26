module riscv_pipeline_basic (
    input clk,
    input reset
);

    // Instruction memory, register file, SVR_WVR, and data memory
    reg [31:0] instruction_memory [0:255];  // 256 instructions
    reg [31:0] data_memory [0:255];         // 256 words of data
    reg [31:0] register_file [0:31];        // 32 GPR
    reg [31:0] SVR_WVR [0:31];              // 16 SVR, 16 WVR
    reg [31:0] RPR;                         // 1 RPR 
    reg [31:0] VTR;                         // 1 VTR 
    reg [31:0] NTR;                         // 1 NTR 
    reg [31:0] NSR [0:31];                   // 32 NSR

    reg [31:0] Vt [0:31];
    reg [31:0] It [0:31];
    
    // Pipeline registers
    reg [31:0] IF_ID_instr, IF_ID_PC;
    
    reg [31:0] ID_EX_PC, ID_EX_instr;
    reg [31:0] ID_EX_read_data1;
    reg [31:0] ID_EX_read_data2;
    reg [4:0] ID_EX_rs1, ID_EX_rd;
    reg [0:0] ID_EX_hint;
    reg [2:0] ID_EX_funct3;
    reg [6:0] ID_EX_funct7;
    reg [6:0] ID_EX_opcode;
    reg [31:0] ID_EX_WVR_Out [0:15];
    reg [31:0] ID_EX_SVR_Out [0:3];
    reg [31:0] ID_EX_NSR_Out [0:31];
    
    reg [31:0] EX_MEM_alu_result;
    reg [4:0]  EX_MEM_rd;
    reg [0:0] EX_MEM_hint;
    reg [2:0] EX_MEM_funct3;
    reg [6:0] EX_MEM_funct7;
    reg [6:0] EX_MEM_opcode;
    reg [7:0] EX_MEM_N_ACC;
    reg [31:0] EX_MEM_S_ACC [0:31];
    
    reg [31:0] MEM_WB_alu_result;
    reg [4:0]  MEM_WB_rd;
    reg [2:0] MEM_WB_funct3;
    reg [6:0] MEM_WB_funct7;
    reg [31:0] MEM_WB_memOut [15:0];
    reg [6:0] MEM_WB_opcode;
    reg [7:0] MEM_WB_N_ACC;
    reg [31:0] MEM_WB_S_ACC [0:31];

    // Program Counter (PC)
    reg [31:0] PC;

    // Iterator 
    integer i, j;

    // Initialize register file and data memory 
    initial begin
        PC = 0;
       
        // Initialize the register file
        for (i = 0; i < 32; i = i + 1) begin
            register_file[i] <= i;
            NSR[i] <= 0;
        end
        
        for (i = 0; i<32; i = i + 1) begin
            Vt[i] <= 0;
            It[i] <= 0;
        end
        
        // Initialize the data memory
        for (i = 0; i < 256; i = i + 1) begin
            data_memory[i] <= i;
        end
        
        RPR = 32'b0;
        VTR = 32'b0;    
        NTR = 32'b0;
                 
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
    reg [6:0] opcode;
    reg [4:0] rd;
    reg [0:0] hint;
    reg [2:0] funct3;
    reg [4:0] rs1;
    reg [11:0] imm;
    reg [4:0] rs2;
    reg [6:0] funct7;
    reg [3:0] SVR_WVR_Addr1;
    reg [31:0] WVR_Out [0:15];
    reg [31:0] SVR_Out [0:3];
    reg [31:0] NSR_Out [0:31];
    
    always @ (*)
    begin
        opcode = IF_ID_instr[6:0];
    
        if ((opcode == 7'b0000001) || (opcode == 7'b0000010))
        begin
            rd = {(IF_ID_instr[0]), IF_ID_instr[10:7]};
            hint = IF_ID_instr[11];
            funct3 = IF_ID_instr[14:12];
            rs1 = IF_ID_instr[19:15];
            imm = IF_ID_instr[31:20];
            rs2 = 5'b0;
            funct7 = 7'b0;
        end
        
        else if (opcode == 7'b0000100)
        begin   
            rd = IF_ID_instr[11:7];
            funct3 = IF_ID_instr[14:12];
            rs1 = IF_ID_instr[19:15];
            rs2 = IF_ID_instr[24:20];
            funct7 = IF_ID_instr[31:25];
            hint = 1'b0;
            imm = 12'b0;
        end
        
        else if (opcode == 7'b0001000)
        begin
            rd = IF_ID_instr[11:7];
            funct3 = IF_ID_instr[14:12];
            rs1 = IF_ID_instr[19:15];
            rs2 = IF_ID_instr[24:20];
            funct7 = IF_ID_instr[31:25];
            hint = 1'b0;
            imm = 12'b0;

            for (i = 0; i < 16; i = i + 1) begin
                SVR_WVR_Addr1 = ((rs1[3:0] + i)%16);
                WVR_Out[i] = SVR_WVR[{rs1[4], SVR_WVR_Addr1}];
            end
            
            for (i = 0; i < 32; i = i + 1) begin
                NSR_Out[i] = NSR[(rd + i)%32];
                
            end
                
            for (i = 0; i < 4; i = i + 1) begin
                SVR_WVR_Addr1 = ((rs2[3:0] + i)%16);
                SVR_Out[i] = SVR_WVR[{rs2[4], SVR_WVR_Addr1}];
            end
        end
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_EX_PC <= 0;
            ID_EX_instr <= 0;
        end else begin
            ID_EX_PC <= IF_ID_PC;
            ID_EX_instr <= IF_ID_instr;
            ID_EX_rd <= rd;
            ID_EX_rs1 <= rs1;
            ID_EX_hint <= hint;
            ID_EX_funct3 <= funct3;
            ID_EX_opcode <= opcode;  
            ID_EX_funct7 <= funct7;
            
            if ((opcode == 7'b0000001) || (opcode == 7'b0000010))
            begin
                ID_EX_read_data1 <= register_file[rs1];
                ID_EX_read_data2 <= imm;
            end
            else if (opcode == 7'b0000100)
            begin
                ID_EX_read_data1 <= register_file[rs1];
                ID_EX_read_data2 <= register_file[rs2]; 
            end
            else if (opcode == 7'b0010000)
            begin
                for (i = 0; i < 32; i = i + 1)
                begin                
                    ID_EX_NSR_Out[i] <= NSR_Out[i]; 
                end
            end              
            else if (opcode == 7'b0001000)
            begin
                for (i = 0; i < 16; i = i + 1)
                begin
                    ID_EX_WVR_Out[i] <= WVR_Out[i];
                end
                
                for (i = 0; i < 4; i = i + 1)
                begin
                    ID_EX_SVR_Out[i] <= SVR_Out[i];
                end
                
                for (i = 0; i < 32; i = i + 1)
                begin                
                    ID_EX_NSR_Out[i] <= NSR_Out[i]; 
                end
            end      
        end
    end

    // EXECUTE stage
    wire [31:0] alu_input1 = ID_EX_read_data1;
    wire [31:0] alu_input2 = ID_EX_read_data2;
    
    reg [31:0] alu_result = 0;
    reg [7:0] N_ACC = 0;
    reg [31:0] S_ACC [0:31];
    
    reg [31:0] cnt1 = 0;
    reg [31:0] cnt2 = 0;
    reg [31:0] cnt3 = 0;
    reg [31:0] rnd_i = 0;
    reg [31:0] rnd_v = 0;
    
    always @(*) begin
        if (ID_EX_opcode == 7'b0001000)
        begin
            case(ID_EX_funct7)
                7'b1110000:
                begin
                    N_ACC = 0;
                    for (i = 0; i < 32; i = i + 1)
                    begin
                        cnt1 = i / 8;
                        cnt2 = i % 8;
                        case (cnt2)
                            0: N_ACC = N_ACC + (ID_EX_SVR_Out[0][i] * ID_EX_WVR_Out[cnt1][3:0]);
                            1: N_ACC = N_ACC + (ID_EX_SVR_Out[0][i] * ID_EX_WVR_Out[cnt1][7:4]);
                            2: N_ACC = N_ACC + (ID_EX_SVR_Out[0][i] * ID_EX_WVR_Out[cnt1][11:8]);
                            3: N_ACC = N_ACC + (ID_EX_SVR_Out[0][i] * ID_EX_WVR_Out[cnt1][15:12]);
                            4: N_ACC = N_ACC + (ID_EX_SVR_Out[0][i] * ID_EX_WVR_Out[cnt1][19:16]);
                            5: N_ACC = N_ACC + (ID_EX_SVR_Out[0][i] * ID_EX_WVR_Out[cnt1][23:20]);
                            6: N_ACC = N_ACC + (ID_EX_SVR_Out[0][i] * ID_EX_WVR_Out[cnt1][27:24]);
                            7: N_ACC = N_ACC + (ID_EX_SVR_Out[0][i] * ID_EX_WVR_Out[cnt1][31:28]);
                        endcase
                    end
                    
                    N_ACC = N_ACC + ID_EX_NSR_Out[0][7:0];
                end
                
                7'b1110001: 
                begin
                N_ACC = 0;
                    for (i = 0; i < 4; i = i + 1)
                    begin
                        for (j = 0; j < 32; j = j + 1)
                        begin
                            cnt1 = (4 * i) + (j / 8);
                            cnt2 = j % 8;
                            
                            case (cnt2)
                                0: N_ACC = N_ACC + (ID_EX_SVR_Out[i][j] * ID_EX_WVR_Out[cnt1][3:0]);
                                1: N_ACC = N_ACC + (ID_EX_SVR_Out[i][j] * ID_EX_WVR_Out[cnt1][7:4]);
                                2: N_ACC = N_ACC + (ID_EX_SVR_Out[i][j] * ID_EX_WVR_Out[cnt1][11:8]);
                                3: N_ACC = N_ACC + (ID_EX_SVR_Out[i][j] * ID_EX_WVR_Out[cnt1][15:12]);
                                4: N_ACC = N_ACC + (ID_EX_SVR_Out[i][j] * ID_EX_WVR_Out[cnt1][19:16]);
                                5: N_ACC = N_ACC + (ID_EX_SVR_Out[i][j] * ID_EX_WVR_Out[cnt1][23:20]);
                                6: N_ACC = N_ACC + (ID_EX_SVR_Out[i][j] * ID_EX_WVR_Out[cnt1][27:24]);
                                7: N_ACC = N_ACC + (ID_EX_SVR_Out[i][j] * ID_EX_WVR_Out[cnt1][31:28]);
                            endcase
                            
                            
                            
                        end
                    end
                    
                    N_ACC = N_ACC + ID_EX_NSR_Out[0][7:0];
                    
                    $display(" %b %b ", ID_EX_NSR_Out[0], N_ACC);
                end   
                
                7'b1110100: 
                begin
                for (i = 0; i < 32; i = i + 1) begin
                    S_ACC[i] = 0;
                end
                    for (i = 0; i < 32; i = i + 1)
                    begin
                        cnt1 = i / 8;
                        cnt2 = i % 8;
                        cnt3 = i / 4;
                        
                        case (cnt2)
                            0: S_ACC[cnt3][7:0] = ID_EX_NSR_Out[cnt3][7:0] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][3:0]);
                            1: S_ACC[cnt3][15:8] = ID_EX_NSR_Out[cnt3][15:8] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][7:4]);
                            2: S_ACC[cnt3][23:16] = ID_EX_NSR_Out[cnt3][23:16] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][11:8]);
                            3: S_ACC[cnt3][31:24] = ID_EX_NSR_Out[cnt3][31:24] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][15:12]);
                            4: S_ACC[cnt3][7:0] = ID_EX_NSR_Out[cnt3][7:0] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][19:16]);
                            5: S_ACC[cnt3][15:8] = ID_EX_NSR_Out[cnt3][15:8] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][23:20]);
                            6: S_ACC[cnt3][23:16] = ID_EX_NSR_Out[cnt3][23:16] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][27:24]);
                            7: S_ACC[cnt3][31:24] = ID_EX_NSR_Out[cnt3][31:24] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][31:28]);
                        endcase
                    end
                end
                
                7'b1110101: 
                begin
                for (i = 0; i < 32; i = i + 1) begin
                    S_ACC[i] = 0;
                end
                for ( j = 0; j < 4; j = j + 1 ) 
                begin
                    for (i = 0; i < 32; i = i + 1)
                    begin
                        cnt1 = (4 * j) + (i / 8);
                        cnt2 = i % 8;
                        cnt3 = (8 * j) + (i / 4);
                        $display("SACC: %b %b %b ", cnt3, S_ACC[cnt3], ID_EX_NSR_Out[cnt3]);
                        case (cnt2)
                            0: S_ACC[cnt3][7:0] = ID_EX_NSR_Out[cnt3][7:0] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][3:0]);
                            1: S_ACC[cnt3][15:8] = ID_EX_NSR_Out[cnt3][15:8] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][7:4]);
                            2: S_ACC[cnt3][23:16] = ID_EX_NSR_Out[cnt3][23:16] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][11:8]);
                            3: S_ACC[cnt3][31:24] = ID_EX_NSR_Out[cnt3][31:24] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][15:12]);
                            4: S_ACC[cnt3][7:0] = ID_EX_NSR_Out[cnt3][7:0] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][19:16]);
                            5: S_ACC[cnt3][15:8] = ID_EX_NSR_Out[cnt3][15:8] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][23:20]);
                            6: S_ACC[cnt3][23:16] = ID_EX_NSR_Out[cnt3][23:16] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][27:24]);
                            7: S_ACC[cnt3][31:24] = ID_EX_NSR_Out[cnt3][31:24] + (ID_EX_SVR_Out[0][0] * ID_EX_WVR_Out[cnt1][31:28]);
                        endcase
                    end
                    end  
                end 
                
            endcase
        end
        else if (ID_EX_opcode == 7'b0010000)
        begin
            case(ID_EX_funct7)
                7'b1110100:
                begin
                   rnd_i = It[0]>>2;
                   rnd_v = Vt[0]>>2;
                   Vt[0] = Vt[0] - rnd_i + ID_EX_NSR_Out[0] - rnd_v; 
                   It[0] = ID_EX_NSR_Out[0];
                   if (Vt[0] > VTR)
                        Vt[0] = 0;
                end
                7'b1110101:
                begin
                   for (i = 0; i < 8; i = i + 1) begin
                       rnd_i = It[i]>>2;
                       rnd_v = Vt[i]>>2;
                       Vt[i] = Vt[i] - rnd_i + ID_EX_NSR_Out[i] - rnd_v; 
                       It[i] = ID_EX_NSR_Out[i];
                       if (Vt[i] > VTR)
                            Vt[i] = 0;    
                   end
                end
                7'b1110110:
                begin
                   for (i = 0; i < 32; i = i + 1) begin
                       rnd_i = It[i]>>2;
                       rnd_v = Vt[i]>>2;
                       Vt[i] = Vt[i] - rnd_i + ID_EX_NSR_Out[i] - rnd_v; 
                       It[i] = ID_EX_NSR_Out[i];
                       if (Vt[i] > VTR)
                            Vt[i] = 0;    
                   end
                end
            endcase
                
        end
        else
            alu_result = alu_input1 + alu_input2;       
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_alu_result <= 0;
            EX_MEM_N_ACC <= 0;
             for (i = 0; i < 32; i = i + 1) begin
                EX_MEM_S_ACC[i] <=0;
             end
        end else begin
            EX_MEM_alu_result <= alu_result;
            EX_MEM_rd <= ID_EX_rd;
            EX_MEM_hint <= ID_EX_hint;
            EX_MEM_funct3 <= ID_EX_funct3;
            EX_MEM_funct7 <= ID_EX_funct7;
            EX_MEM_opcode <= ID_EX_opcode;
            EX_MEM_N_ACC <= N_ACC;
            
            for (i = 0; i < 32; i = i + 1) begin
            
                EX_MEM_S_ACC[i] <= S_ACC[i];
                $display("SACC testing:  %b %b %b ",i,S_ACC[i],EX_MEM_S_ACC[i]);
                end
        end
    end

    // MEMORY stage
    reg [31:0] memOut [15:0];
    
    always @ (*) begin
        if ((EX_MEM_opcode == 7'b0000001) || (EX_MEM_opcode == 7'b0000010))
        begin
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
        
        else 
        begin 
            memOut[0] = data_memory[EX_MEM_alu_result];
        end  
    end  
     
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_alu_result <= 0;
            MEM_WB_N_ACC <= 0;
           for (i = 0; i < 32; i = i + 1) begin
                MEM_WB_S_ACC[i] <=0;
             end
        end else begin
            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_rd <= EX_MEM_rd;
            MEM_WB_funct3 <= EX_MEM_funct3;
            MEM_WB_funct7 <= EX_MEM_funct7;
            MEM_WB_opcode <= EX_MEM_opcode;
            MEM_WB_N_ACC <= EX_MEM_N_ACC;
            
            for (i = 0; i < 32; i = i + 1)
                MEM_WB_S_ACC[i] <= EX_MEM_S_ACC[i];
            
            for (i = 0; i < 16; i = i + 1) begin
                MEM_WB_memOut[i] <= memOut[i];
            end
        end
    end

    // WRITEBACK stage
    reg [3:0] SVR_WVR_Addr; 
    
    always @ (*) begin
        if (!reset) begin   
            if ((MEM_WB_opcode == 7'b0000001) || (MEM_WB_opcode == 7'b0000010))
            begin
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
        
            else if (MEM_WB_opcode == 7'b0000100)
            begin
                case(MEM_WB_funct7)
                    7'b0000000: RPR = MEM_WB_memOut[0];
                    7'b0000001: VTR = MEM_WB_memOut[0];
                    7'b0000010: NTR = MEM_WB_memOut[0];
                endcase  
            end 
            
            else if (MEM_WB_opcode == 7'b0001000)
            begin
                if (!MEM_WB_funct7[2])
                    NSR[MEM_WB_rd][7:0] = MEM_WB_N_ACC;
                else
                    begin
                    if (!MEM_WB_funct7[0]) begin
                        for (i = 0; i < 8; i = i + 1) begin
                            NSR[(MEM_WB_rd + i)%32] = MEM_WB_S_ACC[i];
                            $display("write:  %b %b ",MEM_WB_S_ACC[i], NSR[(MEM_WB_rd + i)%32]);
                            end
                    end
                    else 
                    begin
                        for (i = 0; i < 32; i = i + 1) begin
                            NSR[(MEM_WB_rd + i)%32] = MEM_WB_S_ACC[i];
                            $display("write:  %b %b ",MEM_WB_S_ACC[i], NSR[(MEM_WB_rd + i)%32]);
                            end
                    end
                        
                    end
            end       
        end
    end

endmodule