module tt_um_stopwatchtop(
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire   ena,
    input  wire   clk,
    input  wire   rst_n 
);
    
    wire start = ui_in[0];
    wire stop = ui_in[1];
    reg [6:0] seg;
    reg dp;
    reg [3:0] an;
    assign uo_out[6:0] = seg;
    assign uo_out[7] = dp;
    assign uio_oe = 8'h0F;
    assign uio_out[3:0] = an;
    assign uio_out[7:4] = 4'h0;
    wire [5:0] sec, min;
    reg [15:0] bcd;

    // Stopwatch instance
    stopwatch sw(
        .clk(clk),
        .rst(rst_n),
        .start(start),
        .stop(stop),
        .sec(sec),
        .min(min)
    );

    // Convert minutes:seconds to 4-digit BCD
    always @(*) begin
        bcd[3:0]   = sec % 10;
        bcd[7:4]   = sec / 10;
        bcd[11:8]  = min % 10;
        bcd[15:12] = min / 10;
    end

    // 7-segment display driver
    seven_seg_driver ssd(
        .clk(clk),
        .rst(rst_n),
        .bcd(bcd),
        .seg(seg),
        .dp(dp),
        .an(an)
    );
    // Prevent unused warnings (like in example)
    wire _unused = &{ena, ui_in[7:2], uio_in};

endmodule
