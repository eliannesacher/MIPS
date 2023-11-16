module mux4_1
    (
        input logic [31:0] a, [31:0] b, [31:0] c, [31:0] d, 
        input s0, s1,
        output [31:0] out
    );
    assign out = s1 ? (s0 ? d:c) : (s0 ? b:a);
endmodule 