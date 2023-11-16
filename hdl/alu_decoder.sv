`include "cpu.svh"

module alu_decoder
    (
        input logic [5:0] funct,
        //new//
        input logic [5:0] opcode,
        //new//
        input logic PCWrite,
        input logic [1:0] ALUop,
        output logic [3:0] ALUControl
    );

    always_comb begin

    if (ALUop == 2'd0) begin
        if (PCWrite == 1'b1) begin
            ALUControl = `ALU_ADD; end
        else begin
            if ((opcode == `OP_LW) | (opcode == `OP_SW) | (opcode == `OP_ADDI))
                ALUControl = `ALU_ADD;
            else if (opcode == `OP_ANDI)
                ALUControl = `ALU_AND;
            else if (opcode == `OP_ORI)
                ALUControl = `ALU_OR;
            else if (opcode == `OP_XORI)
                ALUControl = `ALU_XOR;
            else if (opcode == `OP_SLTI)
                ALUControl = `ALU_SLT; 
            end
        end   

        else if (ALUop [0] == 1)
            ALUControl = `ALU_SUB;
        else if (ALUop [1] == 1)
        begin
            case (funct)
                `F_SLL: begin
                    ALUControl = `ALU_SLL;                     
                end
                `F_SRA: begin
                    ALUControl = `ALU_SRA;                     
                end
                `F_SRL: begin
                    ALUControl = `ALU_SRL;                     
                end
                `F_XOR: begin
                    ALUControl = `ALU_XOR;                     
                end
                `F_ADD: begin
                    ALUControl = `ALU_ADD;
                end
                `F_SUB: begin
                    ALUControl = `ALU_SUB;               
                end
                `F_AND: begin
                    ALUControl = `ALU_AND;                      
                end
                `F_OR: begin
                    ALUControl = `ALU_OR;                   
                end
                `F_SLT: begin
                    ALUControl = `ALU_SLT;                     
                end                
                `F_NOR: begin
                    ALUControl = `ALU_NOR;                     
                end                                
                `F_XOR: begin
                    ALUControl = `ALU_XOR;                     
                end               
                `F_SLT: begin
                    ALUControl = `ALU_SLT;                     
                end
                `F_JR: begin
                    ALUControl = `ALU_ADD;                     
                end                
            endcase
         end
    end

endmodule

