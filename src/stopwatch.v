module stopwatch(
    input clk, rst, start, stop,
    output reg [5:0] sec, min
    );
    
    wire clk_out;
    reg running;

    clk_divider cd(.clk(clk), .rst(rst), .clk_out(clk_out));

    always @(posedge clk or posedge rst) begin
        if (rst)
            running <= 0;
        else if (start)
            running <= 1;
        else if (stop)
            running <= 0;
    end

    always @(posedge clk_out or posedge rst) begin
        if (rst) begin
            sec <= 0;
            min <= 0;
        end
        else if (running) begin
            if (sec == 59) begin
                sec <= 0;
                min <= min + 1;
            end
            else
                sec <= sec + 1;
        end
    end
endmodule
