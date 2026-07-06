module misr #(
    parameter WIDTH = 4
)
(
    //-------------------------------------------------------
    // Inputs
    //-------------------------------------------------------

    input  wire                 clk,
    input  wire                 rst,

    // Enable Signature Generation
    input  wire                 enable,

    // Clear Signature Register
    input  wire                 clear,

    // Scan Chain Serial Output
    input  wire                 scan_in,

    //-------------------------------------------------------
    // Output
    //-------------------------------------------------------

    output reg [WIDTH-1:0]      signature
);

    //-------------------------------------------------------
    // Primitive Polynomial Feedback Function
    //-------------------------------------------------------

    function automatic feedback_fn;

        input [WIDTH-1:0] value;
        input             scan_bit;

        begin

            case (WIDTH)

                // x^4 + x^3 + 1
                4:
                    feedback_fn =
                        value[3] ^
                        value[2] ^
                        scan_bit;

                // x^8 + x^6 + x^5 + x^4 + 1
                8:
                    feedback_fn =
                        value[7] ^
                        value[5] ^
                        value[4] ^
                        value[3] ^
                        scan_bit;

                // x^16 + x^14 + x^13 + x^11 + 1
                16:
                    feedback_fn =
                        value[15] ^
                        value[13] ^
                        value[12] ^
                        value[10] ^
                        scan_bit;

                // Default Primitive Polynomial
                default:
                    feedback_fn =
                        value[WIDTH-1] ^
                        value[WIDTH-2] ^
                        scan_bit;

            endcase

        end

    endfunction

    //-------------------------------------------------------
    // Feedback Bit
    //-------------------------------------------------------

    wire feedback;

    assign feedback = feedback_fn(signature, scan_in);

    //-------------------------------------------------------
    // MISR Register
    //-------------------------------------------------------

    always @(posedge clk or posedge rst)
    begin

        if (rst)
        begin

            signature <= {WIDTH{1'b0}};

        end

        else if (clear)
        begin

            signature <= {WIDTH{1'b0}};

        end

        else if (enable)
        begin

            signature <=
            {
                signature[WIDTH-2:0],
                feedback
            };

        end

    end

endmodule

