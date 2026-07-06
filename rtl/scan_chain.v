module scan_chain #(
    parameter WIDTH = 4
)
(
    //-------------------------------------------------------
    // Inputs
    //-------------------------------------------------------

    input  wire                 clk,
    input  wire                 rst,

    // Clock Gating Enable
    input  wire                 clk_en,

    // Scan Enable
    input  wire                 se,

    // External Scan Input
    input  wire                 scan_in,

    // Functional Inputs
    input  wire [WIDTH-1:0]     d,

    //-------------------------------------------------------
    // Outputs
    //-------------------------------------------------------

    output wire [WIDTH-1:0]     q,

    // External Scan Output
    output wire                 scan_out
);

    //-------------------------------------------------------
    // Internal Signals
    //-------------------------------------------------------

    wire gated_clk;

    // Internal Scan Connections
    wire [WIDTH:0] scan_link;

    //-------------------------------------------------------
    // Clock Gating
    //-------------------------------------------------------

    clock_gating U_CLOCK_GATING
    (
        .clk       (clk),
        .enable    (clk_en),
        .gated_clk (gated_clk)
    );

    //-------------------------------------------------------
    // Scan Chain Connections
    //-------------------------------------------------------

    assign scan_link[0] = scan_in;

    assign scan_out = scan_link[WIDTH];

    //-------------------------------------------------------
    // Generate Scan Flip-Flops
    //-------------------------------------------------------

    genvar i;

    generate

        for(i = 0; i < WIDTH; i = i + 1)
        begin : GEN_SCAN_FF

            scan_ff U_SCAN_FF
            (
                .clk (gated_clk),

                .rst (rst),

                .d   (d[i]),

                .si  (scan_link[i]),

                .se  (se),

                .q   (q[i]),

                .so  (scan_link[i+1])
            );

        end

    endgenerate

endmodule