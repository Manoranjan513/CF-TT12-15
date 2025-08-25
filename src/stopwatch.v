module stopwatch(
    input  wire clk,       // 50 MHz input clock
    input  wire rst_n,     // active low reset
    input  wire start,
    input  wire stop,
    output reg [5:0] sec,
    output reg [5:0] min
);

    // Convert to active-high reset
    wire rst = ~rst_n;

    // Run/stop state
    reg running;

    always @(posedge clk or posedge rst) begin
        if (rst)
            running <= 0;
        else if (start)
            running <= 1;
        else if (stop)
            running <= 0;
    end

    // Divider for ~1 Hz (assuming 50 MHz input clock)
    reg [25:0] div_counter;
    wire one_sec_enable = (div_counter == 26'd49_999_999);

    always @(posedge clk or posedge rst) begin
        if (rst)
            div_counter <= 0;
        else if (div_counter == 26'd49_999_999)
            div_counter <= 0;
        else
            div_counter <= div_counter + 1;
    end

    // Time counters
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sec <= 0;
            min <= 0;
        end
        else if (running && one_sec_enable) begin
            if (sec == 59) begin
                sec <= 0;
                if (min == 59)
                    min <= 0;
                else
                    min <= min + 1;
            end else begin
                sec <= sec + 1;
            end
        end
    end

endmodule
