module stopwatch(
    input  wire clk,
    input  wire rst,     // active high reset
    input  wire start,
    input  wire stop,
    output reg [5:0] sec,
    output reg [5:0] min
);

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

    // Divider for ~1 Hz (assuming 12 MHz input clock)
    reg [23:0] div_counter;
    wire one_sec_enable = (div_counter == 24'd11_999_999);

    always @(posedge clk or posedge rst) begin
        if (rst)
            div_counter <= 0;
        else if (div_counter == 24'd11_999_999)
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
