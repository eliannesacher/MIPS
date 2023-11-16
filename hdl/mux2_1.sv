module mux2_1
    (
        input logic [31:0] a, [31:0] b, 
        input logic sel,
        output logic [31:0] f
    );
    

    logic [31:0] f1;
    logic [31:0] f2;
    genvar m;
    generate
        for (m = 0; m < 32; m = m+1) begin
            and g1 (f1[m], a[m], ~sel);
            and g2 (f2[m], b[m], sel);
            or g3 (f[m], f1[m], f2[m]);    
        end
    endgenerate
endmodule