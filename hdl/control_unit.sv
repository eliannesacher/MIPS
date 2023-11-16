`include "cpu.svh"


module control_unit
    (
        input logic clk_100M, clk_en, rst, 
        input logic [5:0] opcode,
        input logic [5:0] funct,
        output logic PCWrite, Branch, ALUSrcA, RegtoWrite, IorD, MemtoWrite, IRWrite,  
        output logic [1:0] MemtoReg,ALUSrcB, PCSrc, ALUop, RegDst
    );
    
    typedef enum {S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S13, S14, S15} state_t;
    state_t state, next_state;
    
    always_ff @(posedge clk_100M) begin
        if (rst) begin
            state <= S0;
        end
        else if (clk_en) begin
            state <= next_state;
        end
    end

    always_comb begin
        case (state)
            S0: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 1;
                PCWrite = 1; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 0;
                ALUSrcB = 2'b01;
                RegtoWrite = 0; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                next_state = S1;
            end
            S1: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 0;
                ALUSrcB = 2'b11;
                RegtoWrite = 0;
                MemtoReg = 2'b00;
                RegDst = 2'b00;
                if (opcode == `OP_RTYPE & funct != `F_JR)
                    next_state = S6;
                else if (opcode == `OP_LW | opcode == `OP_SW)
                    next_state = S2;
                else if (opcode == `OP_BEQ | opcode == `OP_BNE)
                    next_state = S8;
                else if (opcode == `OP_J)
                    next_state = S11;
                else if (opcode == `OP_ADDI | opcode == `OP_ORI | opcode == `OP_XORI | opcode == `OP_SLTI | opcode == `OP_ANDI)
                    next_state = S9;
                else if (opcode == `OP_RTYPE & funct == `F_JR)
                    next_state = S13;
                else if (opcode == `OP_JAL)
                    next_state = S14;
            end
            S6: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b10; 
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                RegtoWrite = 0; 
                MemtoReg = 2'b00;
                RegDst = 2'b00;
                next_state = S7;  
            end
            S7: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                RegtoWrite = 1;
                MemtoReg = 2'b00;
                RegDst = 2'b01;
                next_state = S0;
            end
            S2: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 1;
                ALUSrcB = 2'b10;
                RegtoWrite = 0; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                if (opcode == `OP_LW)
                    next_state = S3;
                else if (opcode == `OP_SW)
                    next_state = S5;
            end
            S3: begin
                IorD = 1;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 0;
                ALUSrcB = 2'b00;
                RegtoWrite = 0; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                next_state = S4;
            end
            S4: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 0;
                ALUSrcB = 2'b00;
                RegtoWrite = 1; 
                MemtoReg = 2'b01; 
                RegDst = 2'b00;
                next_state = S0;
            end
            S5: begin
                IorD = 1;
                MemtoWrite = 1; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 0;
                ALUSrcB = 2'b00;
                RegtoWrite = 0; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                next_state = S0;
            end
            S8: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 1; 
                PCSrc = 2'b01;
                ALUop = 2'b01;
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                RegtoWrite = 0; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                next_state = S0;
            end
          
            S11: begin //j-type
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 1; 
                Branch = 0; 
                PCSrc = 2'b10;
                ALUop = 2'b00;
                ALUSrcA = 0;
                ALUSrcB = 2'b00;
                RegtoWrite = 0; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                next_state = S0;
            end   

            S9: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 1;
                ALUSrcB = 2'b10;
                RegtoWrite = 0; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                next_state = S10;
            end                
            S10: begin
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 0;
                ALUSrcB = 2'b00;
                RegtoWrite = 1; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                next_state = S0;
            end  
            S13: begin //JR
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 1; 
                Branch = 0; 
                PCSrc = 2'b11;
                ALUop = 2'b00;
                ALUSrcA = 1;
                ALUSrcB = 2'b00;
                RegtoWrite = 0; 
                MemtoReg = 2'b00; 
                RegDst = 2'b00;
                next_state = S0; 
            end                                                               
            S14: begin //jal-type
                IorD = 0;
                MemtoWrite = 0; 
                IRWrite = 0;
                PCWrite = 0; 
                Branch = 0; 
                PCSrc = 2'b00;
                ALUop = 2'b00;
                ALUSrcA = 0;
                ALUSrcB = 2'b00;
                RegtoWrite = 1; 
                MemtoReg = 2'b10; 
                RegDst = 2'b10;
                next_state = S11;
            end             
        endcase
    end
endmodule
