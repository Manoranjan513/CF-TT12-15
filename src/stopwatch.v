module stopwatch(
    input  wire clk,       // 50 MHz input clock
    input  wire rst_n,     // active low reset
    input  wire start,
    input  wire stop,
    output reg [5:0] sec,
    output reg [5:0] min
);

    // Active-high reset
    wire rst = ~rst_n;

    // Run/stop state
    reg running;

    always @(posedge clk or posedge rst) begin
        if (rst)
            running <= 1'b0;
        else if (start)
            running <= 1'b1;
        else if (stop)
            running <= 1'b0;
    end

    // Divider for ~1 Hz (assuming 50 MHz input clock)
    reg [25:0] div_counter;
    wire one_sec_enable = (div_counter == 26'd49_999_999);

    always @(posedge clk or posedge rst) begin
        if (rst)
            div_counter <= 26'd0;
        else if (one_sec_enable)
            div_counter <= 26'd0;
        else
            div_counter <= div_counter + 1'b1;
    end

    // Time counters
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sec <= 6'd0;
            min <= 6'd0;
        end
        else if (running && one_sec_enable) begin
            if (sec == 6'd59) begin
                sec <= 6'd0;
                if (min == 6'd59)
                    min <= 6'd0;
                else
                    min <= min + 1'b1;
            end else begin
                sec <= sec + 1'b1;
            end
        end
    end
endmodule
