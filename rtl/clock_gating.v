module clock_gating
(
    input  wire clk,
    input  wire enable,

    output wire gated_clk
);

    //-------------------------------------------------------
    // Internal Latch
    //-------------------------------------------------------

    reg enable_latch;

    //-------------------------------------------------------
    // Latch Enable During Clock Low Phase
    //-------------------------------------------------------
    // The enable signal is sampled only while the clock
    // is LOW. This prevents glitches on the gated clock.
    //-------------------------------------------------------

    always @(*)
    begin
        if (!clk)
            enable_latch = enable;
    end

    //-------------------------------------------------------
    // Clock Gating Logic
    //-------------------------------------------------------

    assign gated_clk = clk & enable_latch;

endmodule