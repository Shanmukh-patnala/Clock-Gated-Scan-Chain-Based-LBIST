module bist_controller #(
    parameter WIDTH       = 4,
    parameter SHIFT_COUNT = WIDTH
)
(
    //-------------------------------------------------------
    // Inputs
    //-------------------------------------------------------

    input  wire clk,
    input  wire rst,

    // Start BIST
    input  wire start,

    //-------------------------------------------------------
    // Outputs
    //-------------------------------------------------------

    output reg clk_en,
    output reg se,

    output reg load_seed,
    output reg lfsr_enable,

    output reg misr_enable,
    output reg misr_clear,

    output reg done,

    output reg [2:0] current_state
);

    //-------------------------------------------------------
    // State Encoding
    //-------------------------------------------------------

    localparam IDLE      = 3'd0;
    localparam CLEAR     = 3'd1;
    localparam LOAD      = 3'd2;
    localparam SHIFT     = 3'd3;
    localparam COMPARE   = 3'd4;
    localparam DONE      = 3'd5;

    reg [2:0] next_state;

    //-------------------------------------------------------
    // Shift Counter
    //-------------------------------------------------------

    reg [$clog2(SHIFT_COUNT):0] shift_counter;

    //-------------------------------------------------------
    // State Register
    //-------------------------------------------------------

    always @(posedge clk or posedge rst)
    begin

        if(rst)
            current_state <= IDLE;
        else
            current_state <= next_state;

    end

    //-------------------------------------------------------
    // Shift Counter
    //-------------------------------------------------------

    always @(posedge clk or posedge rst)
    begin

        if(rst)

            shift_counter <= 0;

        else
        begin

            if(current_state == SHIFT)
            begin

                if(shift_counter < SHIFT_COUNT)

                    shift_counter <= shift_counter + 1'b1;

            end

            else

                shift_counter <= 0;

        end

    end

    //-------------------------------------------------------
    // Next State Logic
    //-------------------------------------------------------

    always @(*)
    begin

        next_state = current_state;

        case(current_state)

        //---------------------------------------------------
        // IDLE
        //---------------------------------------------------

        IDLE:

            if(start)

                next_state = CLEAR;

        //---------------------------------------------------
        // CLEAR MISR
        //---------------------------------------------------

        CLEAR:

            next_state = LOAD;

        //---------------------------------------------------
        // LOAD LFSR SEED
        //---------------------------------------------------

        LOAD:

            next_state = SHIFT;

        //---------------------------------------------------
        // SHIFT TEST PATTERNS
        //---------------------------------------------------

        SHIFT:

            if(shift_counter == SHIFT_COUNT)

                next_state = COMPARE;

        //---------------------------------------------------
        // COMPARE SIGNATURE
        //---------------------------------------------------

        COMPARE:

            next_state = DONE;

        //---------------------------------------------------
        // DONE
        //---------------------------------------------------

        DONE:

            if(!start)

                next_state = IDLE;

        default:

            next_state = IDLE;

        endcase

    end

    //-------------------------------------------------------
    // Output Logic (Moore FSM)
    //-------------------------------------------------------

    always @(*)
    begin

        //---------------------------------------------------
        // Default Outputs
        //---------------------------------------------------

        clk_en      = 1'b0;
        se          = 1'b0;

        load_seed   = 1'b0;
        lfsr_enable = 1'b0;

        misr_enable = 1'b0;
        misr_clear  = 1'b0;

        done        = 1'b0;

        //---------------------------------------------------
        // State Outputs
        //---------------------------------------------------

        case(current_state)

        //-----------------------------------------------
        // IDLE
        //-----------------------------------------------

        IDLE:
        begin
        end

        //-----------------------------------------------
        // CLEAR
        //-----------------------------------------------

        CLEAR:
        begin

            clk_en     = 1'b1;
            misr_clear = 1'b1;

        end

        //-----------------------------------------------
        // LOAD
        //-----------------------------------------------

        LOAD:
        begin

            clk_en    = 1'b1;
            load_seed = 1'b1;

        end

        //-----------------------------------------------
        // SHIFT
        //-----------------------------------------------

        SHIFT:
        begin

            clk_en      = 1'b1;
            se          = 1'b1;

            lfsr_enable = 1'b1;
            misr_enable = 1'b1;

        end

        //-----------------------------------------------
        // COMPARE
        //-----------------------------------------------

        COMPARE:
        begin

            clk_en = 1'b1;

        end

        //-----------------------------------------------
        // DONE
        //-----------------------------------------------

        DONE:
        begin

            done = 1'b1;

        end

        endcase

    end

endmodule

