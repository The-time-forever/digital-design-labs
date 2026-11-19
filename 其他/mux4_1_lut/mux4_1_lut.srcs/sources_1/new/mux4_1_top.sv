module mux4_1_top (
    input  logic [3:0] din,   
    input  logic [1:0] sel,   
    output logic [7:0] led    
);

    logic y;

    mux4_1 u_mux4_1 (
        .d   (din),
        .sel (sel),
        .y   (y)
    );

    assign led[0] = y;

    assign led[1] = din[0];
    assign led[2] = din[1];
    assign led[3] = din[2];
    assign led[4] = din[3];
   
    assign led[5] = sel[0];
    assign led[6] = sel[1];

    assign led[7] = 1'b0;

endmodule