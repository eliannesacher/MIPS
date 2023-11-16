`include "cpu.svh"
    
module fsm_tb;
        logic clk_100M, clk_en, rst;
        logic [5:0] opcode;
        logic IorD, ALUSrcA, IRWrite, PCWrite, MemWrite, MemRead, RegWrite, PCWriteCond, RegtoDst, MemtoReg;
        logic [1:0] ALUSrcB, ALUOp, PCSrc;
        
        logic debug_out;
    //run modules
    clk_divider clkdiv (.clk(clk_100M), .rst(rst), .out_clk(clk_en), .max(28'd5), .dbg_out(debug_out));
    control_unit CUTEST (.clk_100M(clk_100M), .clk_en(clk_en), .rst(rst), .opcode(opcode), .IorD(IorD), .ALUSrcA(ALUSrcA), .IRWrite(IRWrite), .PCWrite(PCWrite), .MemWrite(MemWrite), .MemRead(MemRead), .RegWrite(RegWrite), .PCWriteCond(PCWriteCond), .RegtoDst(RegtoDst), .MemtoReg(MemtoReg), .ALUSrcB(ALUSrcB), .ALUOp(ALUOp), .PCSrc(PCSrc));
    
    always #1ps clk_100M = ~clk_100M;
    
    initial begin 
    
        clk_100M = 0;
        rst = 0;
        opcode = 6'b000000;
        #2000ps;
   

    $finish;  
    end 

endmodule
