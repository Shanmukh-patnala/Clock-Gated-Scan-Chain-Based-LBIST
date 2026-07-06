module signature_comparator #(
    parameter WIDTH = 4,
    parameter [WIDTH-1:0] GOLDEN_SIGNATURE = 4'b1011
)
(
    //-------------------------------------------------------
    // Inputs
    //-------------------------------------------------------

    input wire [WIDTH-1:0] signature,

    //-------------------------------------------------------
    // Outputs
    //-------------------------------------------------------

    output wire pass,
    output wire fail
);

    //-------------------------------------------------------
    // Signature Comparison
    //-------------------------------------------------------

    assign pass = (signature == GOLDEN_SIGNATURE);

    assign fail = ~pass;

endmodule
