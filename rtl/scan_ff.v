module scan_ff
(
    input  wire clk,
    input  wire rst,

    // Functional Data Input
    input  wire d,

    // Scan Data Input
    input  wire si,

    // Scan Enable
    input  wire se,

    // Flip-Flop Output
    output reg  q,

    // Scan Output
    output wire so
);

    //-------------------------------------------------------
    // Scan Flip-Flop Operation
    //-------------------------------------------------------
    // se = 0  → Functional Mode
    // se = 1  → Scan Shift Mode
    //-------------------------------------------------------

    always @(posedge clk or posedge rst)
    begin

        if (rst)
        begin
            q <= 1'b0;
        end

        else if (se)
        begin
            q <= si;
        end

        else
        begin
            q <= d;
        end

    end

    //-------------------------------------------------------
    // Scan Output
    //-------------------------------------------------------

    assign so = q;

endmodule
