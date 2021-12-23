`default_nettype none
`include "linearize.svh"

module ws2812b
#(
    parameter NUM_LEDS = 7,
    parameter CLK_FREQ = 25000000,

    parameter integer T0H = $floor(CLK_FREQ / (1000000 / 0.4)), // 0.4us
    parameter integer T1H = $floor(CLK_FREQ / (1000000 / 0.8)), // 0.8us
    parameter integer T0L = $floor(CLK_FREQ / (1000000 / 0.85)), // 0.85us
    parameter integer T1L = $floor(CLK_FREQ / (1000000 / 0.45)), // 0.45us

    // Latch time as per datasheet is 50us, but LEDs don't work unless 200us
    parameter integer LATCH = $floor(CLK_FREQ / (1000000 / 200)), // 200us
    parameter integer PULSE_WIDTH = $floor(CLK_FREQ / (1000000 / 1.25))
) (
    output reg o_out,
    output wire is_refreshing,

    input wire [NUM_LEDS*24-1:0] data, // in GRB order
    input wire start_refresh,
    input wire i_clk
);

reg [NUM_LEDS*24-1:0] data_latch;

// LED Control Logic
reg [8:0] led_index = 0;
reg [5:0] bit_index = 0;
reg [6:0] current_bit_index = 0;
reg [17:0] latch_ctr = 0;
reg refresh = 0;

assign is_refreshing = refresh;

wire [23:0] cur_led_dat = data_latch[24*led_index +: 24];
wire [23:0] cur_led_dat_linear = {
    linearize(cur_led_dat[23:16]),
    linearize(cur_led_dat[15:8]),
    linearize(cur_led_dat[7:0])
};
wire cur_bit_dat = cur_led_dat_linear[23 - bit_index];

always @(posedge i_clk) begin
    o_out <= 0;

    if (refresh) begin
        if (latch_ctr > 1) begin
            latch_ctr <= latch_ctr - 1;
            o_out <= 0;
        end
        else if (latch_ctr == 1) begin
            refresh <= 0;
            latch_ctr <= 0;
            led_index <= 0;
            bit_index <= 0;
            current_bit_index <= 0;
        end
        else begin
            current_bit_index <= current_bit_index + 1;

            if (current_bit_index + 1 == PULSE_WIDTH) begin
                current_bit_index <= 0;
                bit_index <= bit_index + 1;

                if (bit_index + 1 == 24) begin
                    bit_index <= 0;

                    if (led_index + 1 == NUM_LEDS) begin
                        led_index <= 0;
                        latch_ctr <= LATCH;
                    end
                end

                // Pre-increment index so block RAM can be ready
                if (bit_index + 1 == 24) begin
                    led_index <= led_index + 1;
                end
            end

            o_out <= current_bit_index < (cur_bit_dat ? T1H : (T0H));
        end
    end
    else if (start_refresh) begin
        refresh <= 1;
        latch_ctr <= 0;
        led_index <= 0;
        bit_index <= 0;
        current_bit_index <= 0;
        data_latch <= data;
    end
end

endmodule
