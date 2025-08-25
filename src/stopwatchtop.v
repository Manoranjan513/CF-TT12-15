module stopwatchtop(
    input clk,
    input rst,
    input start,
    input stop,
    output [6:0] seg,
    output dp,
    output [3:0] an
    );

    wire [5:0] sec, min;
    reg [15:0] bcd;

    // Stopwatch instance
    stopwatch sw(
        .clk(clk),
        .rst(rst),
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
        .rst(rst),
        .bcd(bcd),
        .seg(seg),
        .dp(dp),
        .an(an)
    );

endmodule
