module tt_um_stopwatchtop(
    input  wire [7:0] ui_in,   // user inputs
    output wire [7:0] uo_out,  // user outputs
    input  wire [7:0] uio_in,  // bidir inputs
    output wire [7:0] uio_out, // bidir outputs
    output wire [7:0] uio_oe,  // bidir enables
    input  wire       ena,     // always 1 when enabled
    input  wire       clk,     // global TT clock (~12 MHz)
    input  wire       rst_n    // global reset (active low)
);

    // Control signals
    wire start = ui_in[0];
    wire stop  = ui_in[1];

    // 7-seg display outputs
    reg [6:0] seg;
    reg       dp;
    reg [3:0] an;

    assign uo_out[6:0] = seg;
    assign uo_out[7]   = dp;

    // Use only lower 4 bits of uio_out
    assign uio_oe       = 8'h0F;     // [3:0] outputs, [7:4] inputs
    assign uio_out[3:0] = an;
    assign uio_out[7:4] = 4'h0;      // tie low → avoid floating

    // Stopwatch outputs
    wire [5:0] sec;
    wire [5:0] min;

    // BCD representation
    reg [15:0] bcd;

    // Stopwatch instance
    stopwatch sw(
        .clk(clk),
        .rst(~rst_n),   // convert active-low reset to active-high
        .start(start),
        .stop(stop),
        .sec(sec),
        .min(min)
    );

    // Synthesizable sec/min → BCD converter
    reg [5:0] sec_tmp, min_tmp;

    always @(*) begin
        // seconds tens
        sec_tmp = sec;
        if (sec_tmp >= 50) begin bcd[7:4] = 5; sec_tmp = sec_tmp - 50; end
        else if (sec_tmp >= 40) begin bcd[7:4] = 4; sec_tmp = sec_tmp - 40; end
        else if (sec_tmp >= 30) begin bcd[7:4] = 3; sec_tmp = sec_tmp - 30; end
        else if (sec_tmp >= 20) begin bcd[7:4] = 2; sec_tmp = sec_tmp - 20; end
        else if (sec_tmp >= 10) begin bcd[7:4] = 1; sec_tmp = sec_tmp - 10; end
        else bcd[7:4] = 0;
        bcd[3:0] = sec_tmp[3:0];  // ones

        // minutes tens
        min_tmp = min;
        if (min_tmp >= 50) begin bcd[15:12] = 5; min_tmp = min_tmp - 50; end
        else if (min_tmp >= 40) begin bcd[15:12] = 4; min_tmp = min_tmp - 40; end
        else if (min_tmp >= 30) begin bcd[15:12] = 3; min_tmp = min_tmp - 30; end
        else if (min_tmp >= 20) begin bcd[15:12] = 2; min_tmp = min_tmp - 20; end
        else if (min_tmp >= 10) begin bcd[15:12] = 1; min_tmp = min_tmp - 10; end
        else bcd[15:12] = 0;
        bcd[11:8] = min_tmp[3:0]; // ones
    end

    // 7-seg display driver
    seven_seg_driver ssd(
        .clk(clk),
        .rst(~rst_n),
        .bcd(bcd),
        .seg(seg),
        .dp(dp),
        .an(an)
    );

    // Prevent unused warnings
    wire _unused;
    assign _unused = &{ena, ui_in[7:2], uio_in};

endmodule
