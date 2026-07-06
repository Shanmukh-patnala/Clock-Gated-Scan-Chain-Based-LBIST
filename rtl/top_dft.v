module top_dft #(
    parameter WIDTH = 4,
    parameter SHIFT_COUNT = WIDTH,
    parameter [WIDTH-1:0] GOLDEN_SIGNATURE = 4'b1011
)
(
    //-------------------------------------------------------
    // Inputs
    //-------------------------------------------------------

    input  wire                 clk,
    input  wire                 rst,
    input  wire                 start,

    input  wire [WIDTH-1:0]     seed,
    input  wire [WIDTH-1:0]     functional_data,

    //-------------------------------------------------------
    // Outputs
    //-------------------------------------------------------

    output wire [WIDTH-1:0]     lfsr_pattern,
    output wire [WIDTH-1:0]     scan_q,
    output wire [WIDTH-1:0]     signature,

    output wire                 pass,
    output wire                 fail,

    output wire                 done,

    output wire [2:0]           current_state
);

    //-------------------------------------------------------
    // Internal Control Signals
    //-------------------------------------------------------

    wire clk_en;
    wire se;

    wire load_seed;
    wire lfsr_enable;

    wire misr_enable;
    wire misr_clear;

    //-------------------------------------------------------
    // Internal Datapath Signals
    //-------------------------------------------------------

    wire scan_serial_out;

    //-------------------------------------------------------
    // BIST Controller
    //-------------------------------------------------------

    bist_controller #(
        .WIDTH(WIDTH),
        .SHIFT_COUNT(SHIFT_COUNT)
    )
    U_BIST_CONTROLLER
    (
        .clk(clk),
        .rst(rst),

        .start(start),

        .clk_en(clk_en),
        .se(se),

        .load_seed(load_seed),
        .lfsr_enable(lfsr_enable),

        .misr_enable(misr_enable),
        .misr_clear(misr_clear),

        .done(done),

        .current_state(current_state)
    );

    //-------------------------------------------------------
    // LFSR
    //-------------------------------------------------------

    lfsr #(
        .WIDTH(WIDTH)
    )
    U_LFSR
    (
        .clk(clk),
        .rst(rst),

        .enable(lfsr_enable),

        .load_seed(load_seed),

        .seed(seed),

        .lfsr_out(lfsr_pattern)
    );

    //-------------------------------------------------------
    // Scan Chain
    //-------------------------------------------------------

    scan_chain #(
        .WIDTH(WIDTH)
    )
    U_SCAN_CHAIN
    (
        .clk(clk),
        .rst(rst),

        .clk_en(clk_en),

        .se(se),

        .scan_in(lfsr_pattern[0]),

        .d(functional_data),

        .q(scan_q),

        .scan_out(scan_serial_out)
    );

    //-------------------------------------------------------
    // MISR
    //-------------------------------------------------------

    misr #(
        .WIDTH(WIDTH)
    )
    U_MISR
    (
        .clk(clk),
        .rst(rst),

        .enable(misr_enable),

        .clear(misr_clear),

        .scan_in(scan_serial_out),

        .signature(signature)
    );

    //-------------------------------------------------------
    // Signature Comparator
    //-------------------------------------------------------

    signature_comparator #(
        .WIDTH(WIDTH),
        .GOLDEN_SIGNATURE(GOLDEN_SIGNATURE)
    )
    U_SIGNATURE_COMPARATOR
    (
        .signature(signature),

        .pass(pass),

        .fail(fail)
    );

endmodule