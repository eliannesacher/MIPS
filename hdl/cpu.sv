`include "cpu.svh"

module cpu
    (
        input logic clk_100M, clk_en, rst,
        input logic [31:0] r_data,
        output logic wr_en,
        output logic [31:0] mem_addr, w_data,
        input logic [4:0] rdbg_addr,
        output logic [31:0] rdbg_data,
        output logic [31:0] instr
    );
    
    // define variables used
    logic PCWrite, Branch, ALUSrcA, RegtoWrite, IorD,MemtoWrite,IRWrite, zero;
    logic [1:0] ALUSrcB, PCSrc, ALUop, RegDst, MemtoReg;
    logic [3:0] ALUControl;
    logic [4:0] rs, rt, rd, shamt;
    logic [5:0] opcode, funct;
    logic [15:0] imm;
    logic [25:0] addr;
    logic [31:0] next_pc,ALUResult, ALUOut, PC, shamt_ext, SrcA, SrcB, A3, WD3, rd0, rd1, imm_ext;
    logic PCWrite_en; //for beq and bne
    
    // run control unit
    control_unit cunu1 (.clk_100M, .clk_en, .rst, .opcode, .funct, .PCWrite, .Branch, .PCSrc, .ALUSrcA, .RegtoWrite, .IorD, .MemtoWrite, .IRWrite, .MemtoReg, .RegDst, .ALUSrcB, .ALUop);

    // run alu decode
    alu_decoder au1 (.funct,.ALUop,.ALUControl, .PCWrite, .opcode);
       
    // for ALUOut   
    reg_en reg6 (.clk(clk_100M), .rst(rst), .en(clk_en), .d(ALUResult), .q(ALUOut));
    
    // run alu
    alu alu_unit (.x(SrcA), .y(SrcB), .z(ALUResult), .op(ALUControl), .zero(zero));    

    // PC part in the beginning
    reg_en #(.INIT(`I_START_ADDRESS)) reg0 (.clk(clk_100M), .rst(rst), .en(PCWrite_en & clk_en), .d(next_pc), .q(PC)); 

    // instructions or data
    mux2_1 mux1 (.a(PC), .b(ALUOut), .sel(IorD),.f(mem_addr)); 
    reg_en reg1 (.clk(clk_100M), .rst(rst), .en(IRWrite & clk_en), .d(r_data), .q(instr));

   ///////////// insturctions
    // intruction devision for R-Type
    assign opcode = instr[31:26];
    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign rd = instr[15:11];
    assign shamt = instr[10:6];
    assign funct = instr[5:0];
    
    // intruction devision for I-Type
    assign imm = instr[15:0];

    // intruction devision for J-Type
    assign addr = instr[25:0];

    // extend the imm (sign extension)
    assign imm_ext = {{16{imm[15]}},imm};
    
    // extend the shift (unsigned extension)
    assign shamt_ext = {{27'd0},shamt};
           
    //////////// data
    logic [31:0] data;
    reg_en reg2 (.clk(clk_100M), .rst(rst), .en(clk_en), .d(r_data), .q(data)); 
    
    // mux for a3 and wd3 in register file
    logic [31:0] A3_ext;
    mux4_1 mux2 (.a({27'd0,rt}), .b({27'd0,rd}), .c(32'd31), .d(32'd0), .s0(RegDst[0]), .s1(RegDst[1]), .out(A3_ext));
    
    assign A3 = A3_ext[5:0];    
    
    // extend mux
    mux4_1 mux3 (.a(ALUOut), .b(data), .c(PC), .d(32'd0), .s0(MemtoReg[0]), .s1(MemtoReg[1]), .out(WD3));
   
    // register file
    reg_file reg3 (.clk(clk_100M), .wr_en(RegtoWrite & clk_en), .w_addr(A3), .r0_addr(rs), .r1_addr(rt), .w_data(WD3), .r0_data(rd0), .r1_data(rd1), .rdbg_addr, .rdbg_data);
    
    //above is fine
    // last portion
    logic [31:0] a1, a2, b1, b2;
    reg_en reg4 (.clk(clk_100M), .rst(rst), .en(clk_en), .d(rd0), .q(a1)); //fine
    reg_en reg5 (.clk(clk_100M), .rst(rst), .en(clk_en), .d(rd1), .q(b1)); //fine
    mux2_1 mux4 (.a(a1), .b(b1), .sel(ALUControl[3]), .f(a2));    
    mux2_1 mux5 (.a(b1), .b(shamt_ext), .sel(ALUControl[3]), .f(b2));

    // muxes for sources for the alu
    mux2_1 mux6 (.a(PC), .b(a2), .sel(ALUSrcA), .f(SrcA));
    
    mux4_1 mux7 (.a(b2), .b(32'd4), .c(imm_ext), .d(imm_ext*4), .s0(ALUSrcB[0]), .s1(ALUSrcB[1]), .out(SrcB));


    //for branch for bne and beq
    logic op;
    assign op = opcode[0]; //to distinguish between beq and bne
    logic branch_mux_out;
    logic PCWrite_branch;
    mux2_1 mux8 (.a({31'd0,zero}), .b({32'd0,~zero}), .sel(op), .f(branch_mux_out)); 
    assign PCWrite_branch = Branch & branch_mux_out; //
    assign PCWrite_en = PCWrite | PCWrite_branch;

    //for jump
    logic [31:0] ext_addr;
    assign ext_addr = instr[25:0]*4;

    // for next PC
    mux4_1 mux9 (.a(ALUResult), .b(ALUOut), .c(ext_addr), .d(rd0), .s0(PCSrc[0]), .s1(PCSrc[1]), .out(next_pc));
    
    // for memory
    assign wr_en = MemtoWrite;
    assign w_data = b1; 

endmodule
