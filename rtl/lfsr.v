module lfsr #(
    parameter WIDTH = 4
)
(
    //-------------------------------------------------------
    // Inputs
    //-------------------------------------------------------

    input  wire                 clk,
    input  wire                 rst,

    // Shift Enable
    input  wire                 enable,

    // Seed Control
    input  wire                 load_seed,

    // Initial Seed
    input  wire [WIDTH-1:0]     seed,

    //-------------------------------------------------------
    // Output
    //-------------------------------------------------------

    output reg  [WIDTH-1:0]     lfsr_out
);

    //-------------------------------------------------------
    // Primitive Polynomial Feedback Function
    //-------------------------------------------------------

    function automatic feedback_fn;

        input [WIDTH-1:0] value;

        begin

            case (WIDTH)

                //-------------------------------------------------
                // x^4 + x^3 + 1
                //-------------------------------------------------
                4:
                    feedback_fn =
                        value[3] ^
                        value[2];

                //-------------------------------------------------
                // x^8 + x^6 + x^5 + x^4 + 1
                //-------------------------------------------------
                8:
                    feedback_fn =
                        value[7] ^
                        value[5] ^
                        value[4] ^
                        value[3];

                //-------------------------------------------------
                // x^16 + x^14 + x^13 + x^11 + 1
                //-------------------------------------------------
                16:
                    feedback_fn =
                        value[15] ^
                        value[13] ^
                        value[12] ^
                        value[10];

                //-------------------------------------------------
                // Default Polynomial
                //-------------------------------------------------
                default:
                    feedback_fn =
                        value[WIDTH-1] ^
                        value[WIDTH-2];

            endcase

        end

    endfunction

    //-------------------------------------------------------
    // Feedback Bit
    //-------------------------------------------------------

    wire feedback;

    assign feedback = feedback_fn(lfsr_out);

    //-------------------------------------------------------
    // LFSR Operation
    //-------------------------------------------------------

    always @(posedge clk or posedge rst)
    begin

        //---------------------------------------------------
        // Reset
        //---------------------------------------------------

        if (rst)
        begin

            // Default Non-Zero State

            lfsr_out <= {WIDTH{1'b1}};

        end

        //---------------------------------------------------
        // Load Initial Seed
        //---------------------------------------------------

        else if (load_seed)
        begin

            //------------------------------------------------
            // Prevent All-Zero Lock-Up State
            //------------------------------------------------

            if (seed == {WIDTH{1'b0}})
                lfsr_out <= {WIDTH{1'b1}};
            else
                lfsr_out <= seed;

        end

        //---------------------------------------------------
        // Shift
        //---------------------------------------------------

        else if (enable)
        begin

            lfsr_out <=
            {
                lfsr_out[WIDTH-2:0],
                feedback
            };

        end

        //---------------------------------------------------
        // Hold State
        //---------------------------------------------------

        else
        begin

            lfsr_out <= lfsr_out;

        end

    end

endmodule

