// Top-level wrapper for TinyTapeout stopwatch project
module tt_um_stopwatchtop (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Output enable
    input  wire ena,            // Enable signal (not used but required)
    input  wire clk,            // Clock
    input  wire rst_n           // Reset (active low)
);

    // Control inputs from ui_in
    wire start = ui_in[0];  // Start signal
    wire stop  = ui_in[1];  // Stop signal

    // Stopwatch outputs
    wire [5:0] sec;
    wire [5:0] min;

    // Drive outputs to uo_out (observe stopwatch time)
    assign uo_out[5:0] = sec;        // Seconds → lower 6 bits
    assign uo_out[7:6] = min[1:0];   // Minutes → upper 2 bits

    // Unused IOs → tie off
    wire [7:0] unused_uio_in = uio_in; // prevent "unused input" warning
    wire unused_ena = ena;             // prevent "unused ena" warning
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Stopwatch instance
    stopwatch sw (
        .clk   (clk),
        .rst_n (rst_n), 
        .start (start),
        .stop  (stop),
        .sec   (sec),
        .min   (min)
    );

    // 7-segment display driver
    wire [6:0] seg;
    wire dp;
    wire [3:0] an;

    seven_seg_driver ssd (
        .clk   (clk),
        .rst_n (rst_n), 
        .bcd   ({min, sec}), // Concatenate minutes and seconds
        .seg   (seg),
        .dp    (dp),
        .an    (an)
    );

    // Optional: expose 7-seg signals for debugging
    // assign uo_out = {seg[3:0], dp, an[2:0]};

endmodule
