`default_nettype none

module demo (
    // 16 MHz clock
    input wire clk,
    
    // USB - set as input to make it high-impedance when not using it
    input wire usbp,
    input wire usbn,
    input wire usbdet,

    // Flash - set as input to make it high-impedance when not using it
    input wire flash_csn,
    input wire flash_sck,
    input wire flash_io0,
    input wire flash_io1,

    // Sewing pad I/Os
    input wire io_0,
    input wire io_1,
    input wire io_2,
    input wire io_3,
    input wire io_4,
    input wire io_5,
    input wire io_6,
    input wire io_7,
    input wire io_8,
    input wire io_9,
    input wire io_10,
    input wire io_11,

    // User peripherals
    output wire led_user,
    input wire  btn_user_n,
    output wire rgb_led
);

localparam CLK_FREQ = 16000000;

// When button pressed and then released, turn on LED for one second
reg [$clog2(CLK_FREQ):0] ctr = 0;
assign led_user = ~(ctr > 0);
reg last_btn_n = 1;
always @(posedge clk) begin
    last_btn_n <= btn_user_n;
    if (ctr > 0) ctr <= ctr - 1;

    if (~last_btn_n && btn_user_n) begin // Button was released
        ctr <= 1 * CLK_FREQ; // One second delay
    end
end

// Send slowly-changing colors to the RGB LED using lookup tables
localparam LUT_SIZE = 6;
wire [(LUT_SIZE * 8 - 1):0] rgb_red_lut = {8'h0F, 8'h00, 8'h00, 8'h00, 8'h0F, 8'h0F};
wire [(LUT_SIZE * 8 - 1):0] rgb_grn_lut = {8'h00, 8'h00, 8'h0F, 8'h0F, 8'h0F, 8'h00};
wire [(LUT_SIZE * 8 - 1):0] rgb_blu_lut = {8'h0F, 8'h0F, 8'h0F, 8'h00, 8'h00, 8'h00};

reg [$clog2(LUT_SIZE):0] lut_index = 0;
reg [$clog2(CLK_FREQ):0] rgb_change_ctr = 0;

always @(posedge clk) begin
    rgb_change_ctr <= rgb_change_ctr - 1;
    if (rgb_change_ctr == 0) begin
        rgb_change_ctr <= 1 * CLK_FREQ;
        lut_index <= lut_index + 1;

        if (lut_index >= LUT_SIZE - 1) begin
            lut_index <= 0;
        end
    end
end


// Use SB_IO to enable pull-up for io_0 pad
wire io_0_b;
SB_IO #( 
    .PIN_TYPE(6'b1010_01), 
    .PULLUP(1) 
) io_0_buf ( 
    .PACKAGE_PIN(io_0), 
    .OUTPUT_ENABLE(0), 
    .D_IN_0(io_0_b) 
); 

// Drive the LED from the lookup tables (if io_0 is high, then blank the LED)
ws2812_single #(
    .CLK_FREQ(CLK_FREQ)
) rgb_controller (
    .o_ws2812(rgb_led),
    .i_clk(clk),
    .i_red(~io_0_b ? 0 : rgb_red_lut[8*lut_index +: 8]),
    .i_green(~io_0_b ? 0 : rgb_grn_lut[8*lut_index +: 8]),
    .i_blue(~io_0_b ? 0 : rgb_blu_lut[8*lut_index +: 8])
);

endmodule
