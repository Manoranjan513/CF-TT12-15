// Top-level wrapper for TinyTapeout stopwatch project
module tt_um_stopwatchtop (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe, 
    input  wire ena, 
    input  wire clk,            // Clock
    input  wire rst_n           // Active-low reset
);

    // Inputs
    wire start = ui_in[0];  // Start signal
    wire stop  = ui_in[1];  // Stop signal

    // Stopwatch outputs
    wire [5:0] sec;
    wire [5:0] min;

    // Drive outputs to uo_out (just for observing on pins)
    assign uo_out[5:0] = sec;   // Seconds to lower 6 bits
    assign uo_out[7:6] = min[1:0]; // Lower 2 bits of minutes

    // Not using bidirectional IOs
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Stopwatch instance
    stopwatch sw (
        .clk(clk),
        .rst_n(rst_n),   // Fixed reset connection
        .start(start),
        .stop(stop),
        .sec(sec),
        .min(min)
    );

    // 7-seg display driver instance
    wire [6:0] seg;
    wire dp;
    wire [3:0] an;

    seven_seg_driver ssd (
        .clk(clk),
        .rst_n(rst_n),  // Ensure your seven_seg_driver also uses rst_n
        .bcd({min, sec}), // Concatenate min:sec into BCD input
        .seg(seg),
        .dp(dp),
        .an(an)
    );

    // Optionally, map some 7-seg signals to outputs for debugging
    // (comment out if you don’t want them on uo_out)
    // assign uo_out = {seg[3:0], dp, an[2:0]};

endmodule
