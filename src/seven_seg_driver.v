module seven_seg_driver(
    input  wire clk,
    input  wire rst_n,        // active-low reset
    input  wire [15:0] bcd,
    output reg [6:0] seg,
    output reg        dp,
    output reg [3:0]  an
);

    // internal active-high reset
    wire rst = ~rst_n;

    reg [1:0]  digit_select;    // which digit active
    reg [3:0]  digit_value;
    reg [15:0] refresh_counter;

    // Refresh rate divider (digit multiplexing)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 0;
            digit_select    <= 0;
        end else begin
            if (refresh_counter == 16'd49_999) begin
                refresh_counter <= 0;
                digit_select <= digit_select + 1;
            end else begin
                refresh_counter <= refresh_counter + 1;
            end
        end
    end

    // Select which digit to display
    always @(*) begin
        case(digit_select)
            2'b00: begin digit_value = bcd[3:0];   an = 4'b1110; end
            2'b01: begin digit_value = bcd[7:4];   an = 4'b1101; end
            2'b10: begin digit_value = bcd[11:8];  an = 4'b1011; end
            2'b11: begin digit_value = bcd[15:12]; an = 4'b0111; end
            default: begin digit_value = 4'd0;     an = 4'b1111; end
        endcase
        dp = 1'b1; // decimal point off
    end

    // 7-seg decoder (active-high segments)
    always @(*) begin
        case(digit_value)
            4'd0: seg = 7'b1111110;
            4'd1: seg = 7'b0110000;
            4'd2: seg = 7'b1101101;
            4'd3: seg = 7'b1111001;
            4'd4: seg = 7'b0110011;
            4'd5: seg = 7'b1011011;
            4'd6: seg = 7'b1011111;
            4'd7: seg = 7'b1110000;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1111011;
            default: seg = 7'b0000001; // dash
        endcase
    end
endmodule
