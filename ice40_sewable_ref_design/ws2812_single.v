// Single WS2812 LED controller. Automatically refreshes when the input RGB
// data is changed.
`default_nettype none

module ws2812_single
#(
    parameter CLK_FREQ = 16000000,

    parameter integer T0H = $floor(CLK_FREQ / (1000000 / 0.4)), // 0.4us
    parameter integer T1H = $floor(CLK_FREQ / (1000000 / 0.8)), // 0.8us
    parameter integer T0L = $floor(CLK_FREQ / (1000000 / 0.85)), // 0.85us
    parameter integer T1L = $floor(CLK_FREQ / (1000000 / 0.45)), // 0.45us

    // Latch time as per datasheet is 50us, but LEDs don't work unless 200us
    parameter integer LATCH = $floor(CLK_FREQ / (1000000 / 200)), // 200us
    parameter integer PULSE_WIDTH = $floor(CLK_FREQ / (1000000 / 1.25)),
) (
    // Output to LED
    output reg o_ws2812,

    input wire i_clk,

    input wire [7:0] i_red,
    input wire [7:0] i_green,
    input wire [7:0] i_blue
);

// Bit ordering of WS2812B protocol
wire [23:0] bits = {i_green, i_red, i_blue}; // G R B
reg [23:0] last_bits;

// start_refresh is a queued-up refresh operation, refresh is if refresh is
// in-progress
reg start_refresh = 0;
reg refresh = 0;

// LED Control Logic
reg [5:0] bit_index = 0;
reg [6:0] current_bit_index = 0;
reg [17:0] latch_ctr = 0;

always @(posedge i_clk) begin
    o_ws2812 <= 0;

    last_bits <= bits;

    if (bits != last_bits) begin
        start_refresh <= 1;
    end

    if (refresh) begin
        if (latch_ctr > 1) begin
            latch_ctr <= latch_ctr - 1;
            o_ws2812 <= 0;
        end
        else if (latch_ctr == 1) begin
            refresh <= 0;
            latch_ctr <= 0;
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
                    latch_ctr <= LATCH;
                end

            end

            o_ws2812 <= current_bit_index < (bits[23 - bit_index] ? T1H : (T0H));
        end
    end
    else if (start_refresh) begin
        refresh <= 1;
        start_refresh <= 0;
        latch_ctr <= 0;
        bit_index <= 0;
        current_bit_index <= 0;
    end
end

endmodule
