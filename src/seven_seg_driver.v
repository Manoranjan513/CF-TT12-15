module seven_seg_driver(
    input clk,
    input rst,
    input [15:0] bcd,
    output reg [6:0] seg,
    output reg dp,
    output reg [3:0] an
    );

    reg [1:0] digit_select = 0;
    reg [3:0] current_digit;
    reg [16:0] refresh_counter = 0; // ~1 kHz refresh for 4 digits

    // Refresh Counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 0;
            digit_select <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            digit_select <= refresh_counter[16:15]; 
        end
    end

    // Digit Selection (Active-Low)
    always @(*) begin
        case(digit_select)
            2'b00: begin an = 4'b1110; current_digit = bcd[3:0];   end
            2'b01: begin an = 4'b1101; current_digit = bcd[7:4];   end
            2'b10: begin an = 4'b1011; current_digit = bcd[11:8];  end
            2'b11: begin an = 4'b0111; current_digit = bcd[15:12]; end
        endcase
    end

    // Active-Low Segment Decoder
    always @(*) begin
        case(current_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; 
        endcase
        dp = 1'b1; // Decimal point OFF (Active-Low)
    end
endmodule
