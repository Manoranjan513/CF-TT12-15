`default_nettype none
`timescale 1ns / 1ps

/*Testbench for TinyTapeout stopwatch project*/
module tb ();

  // Dump the signals to a VCD file (for GTKWave)
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // Inputs to DUT
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;

  // Outputs from DUT
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate DUT (Device Under Test)
  tt_um_stopwatchtop user_project (
`ifdef GL_TEST
      .VPWR   (VPWR),
      .VGND   (VGND),
`endif
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // active low reset
  );

  // Clock generation: 50 MHz (20 ns period)
  initial clk = 0;
  always #10 clk = ~clk;

  // Reset + stimulus
  initial begin
    // Initial values
    rst_n  = 0;
    ena    = 0;
    ui_in  = 8'h00;
    uio_in = 8'h00;

    // Apply reset for first 100 ns
    #100;
    rst_n = 1;
    ena   = 1;   // enable design

    // Example stimulus
    #200 ui_in = 8'h01;   // maybe "start stopwatch"
    #500 ui_in = 8'h02;   // maybe "stop"
    #300 ui_in = 8'h03;   // maybe "reset stopwatch"

    // Run for some times
    #2000;
    $finish;
  end

endmodule
