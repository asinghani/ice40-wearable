`default_nettype none

module nekomimi_base (
    output logic ws,
    output logic clk, // 16 MHz

    input logic [23:0] rgb0,
    input logic [23:0] rgb1,
    input logic [23:0] rgb2,
    input logic [23:0] rgb3,
    input logic [23:0] rgb4,
    input logic [23:0] rgb5,
    input logic [23:0] rgb6
);

    logic clk48;
    SB_HFOSC inthosc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk48));
    pll pll(
        .clock_in(clk48),
        .clock_out(clk),
        .locked()
    );

    logic [167:0] led_data, last_data;
    logic start_refresh, last_start_refresh, is_refreshing;
    logic [23:0] counter;

    assign led_data = {
        rgb6[15:8], rgb6[23:16], rgb6[7:0],
        rgb5[15:8], rgb5[23:16], rgb5[7:0],
        rgb4[15:8], rgb4[23:16], rgb4[7:0],
        rgb3[15:8], rgb3[23:16], rgb3[7:0],
        rgb2[15:8], rgb2[23:16], rgb2[7:0],
        rgb1[15:8], rgb1[23:16], rgb1[7:0],
        rgb0[15:8], rgb0[23:16], rgb0[7:0]
    };

    ws2812b #(
        .NUM_LEDS(7),
        .CLK_FREQ(16000000)
    ) ws2812 (
        .o_out(ws), 
        .i_clk(clk), 
        .data(led_data), 
        .start_refresh(start_refresh),
        .is_refreshing(is_refreshing)
    );

    // Refresh when data changed or every 20ms
    always_ff @(posedge clk) begin
        counter <= counter + 1;

        if (led_data != last_data) begin
            start_refresh <= '1;
        end
        else if (counter >= 320000) begin
            counter <= '0;
            start_refresh <= '1;
        end
        else if (start_refresh && last_start_refresh && !is_refreshing) begin
            start_refresh <= '0;
        end

        last_data <= led_data;
        last_start_refresh <= start_refresh;
    end

endmodule

