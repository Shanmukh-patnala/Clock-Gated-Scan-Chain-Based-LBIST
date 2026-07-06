`timescale 1ns/1ps

module tb_top_dft;

parameter WIDTH = 4;
parameter SHIFT_COUNT = WIDTH;

//-----------------------------------------------------------
// Testbench Signals
//-----------------------------------------------------------

reg clk;
reg rst;
reg start;

reg [WIDTH-1:0] seed;
reg [WIDTH-1:0] functional_data;

//-----------------------------------------------------------
// DUT Outputs
//-----------------------------------------------------------

wire [WIDTH-1:0] lfsr_pattern;
wire [WIDTH-1:0] scan_q;
wire [WIDTH-1:0] signature;

wire pass;
wire fail;

wire done;

wire [2:0] current_state;

//-----------------------------------------------------------
// DUT
//-----------------------------------------------------------

top_dft #(
    .WIDTH(WIDTH),
    .SHIFT_COUNT(SHIFT_COUNT),
    .GOLDEN_SIGNATURE(4'b1011)
)
DUT
(
    .clk(clk),
    .rst(rst),
    .start(start),

    .seed(seed),
    .functional_data(functional_data),

    .lfsr_pattern(lfsr_pattern),
    .scan_q(scan_q),
    .signature(signature),

    .pass(pass),
    .fail(fail),

    .done(done),

    .current_state(current_state)
);

//-----------------------------------------------------------
// Clock Generation
//-----------------------------------------------------------

always #5 clk = ~clk;

//-----------------------------------------------------------
// VCD Dump
//-----------------------------------------------------------

initial
begin
    $dumpfile("top_dft.vcd");
    $dumpvars(0, tb_top_dft);
end

//-----------------------------------------------------------
// Monitor
//-----------------------------------------------------------

initial
begin

$display("-------------------------------------------------------------------------------");
$display("TIME   STATE DONE PASS FAIL   LFSR   SCAN_Q SIGNATURE");
$display("-------------------------------------------------------------------------------");

$monitor("%4t    %0d     %b    %b    %b     %b    %b     %b",

        $time,
        current_state,
        done,
        pass,
        fail,
        lfsr_pattern,
        scan_q,
        signature);

end

//-----------------------------------------------------------
// Main Test Sequence
//-----------------------------------------------------------

initial
begin

//-------------------------------------------------------
// Initialize
//-------------------------------------------------------

clk = 0;
rst = 1;
start = 0;

seed = 4'b1101;
functional_data = 4'b1010;

#20;

rst = 0;

#20;


//=======================================================
// TEST-1
//=======================================================

$display("");
$display("========================================");
$display("TEST 1 : NORMAL BIST");
$display("========================================");

start = 1;

wait(done);

#20;

if(pass)
    $display("TEST-1 PASSED");
else
    $display("TEST-1 FAILED");

$display("Signature = %b",signature);

start = 0;

#50;


//=======================================================
// TEST-2
//=======================================================

$display("");
$display("========================================");
$display("TEST 2 : DIFFERENT SEED");
$display("========================================");

rst = 1;

#20;

rst = 0;

seed = 4'b1010;
functional_data = 4'b0101;

#20;

start = 1;

wait(done);

#20;

$display("Signature = %b",signature);

if(pass)
    $display("TEST-2 PASSED");
else
    $display("TEST-2 FAILED");

start = 0;

#50;


//=======================================================
// TEST-3
//=======================================================

$display("");
$display("========================================");
$display("TEST 3 : RESET RECOVERY");
$display("========================================");

start = 1;

#30;

rst = 1;

#20;

rst = 0;

start = 1;

wait(done);

#20;

if(pass)
    $display("RESET RECOVERY PASSED");
else
    $display("RESET RECOVERY FAILED");

start = 0;

#50;


//=======================================================
// END
//=======================================================

$display("");
$display("========================================");
$display("ALL TESTS COMPLETED");
$display("========================================");

$finish;

end

endmodule