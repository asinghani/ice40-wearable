`default_nettype none

module nekomimi_left (
    output logic ws, // LED

    input logic gpio4,
    inout logic gpio5,
    inout logic gpio6
);

    logic clk;
    logic [23:0] rgb0, rgb1, rgb2, rgb3, rgb4, rgb5, rgb6;

    nekomimi_base ctrl (.*);
    
    always_comb begin
        rgb0 = {8'h80, 8'h00, 8'h00}; // Red
        rgb1 = {8'h80, 8'h28, 8'h00};
        rgb2 = {8'h80, 8'h50, 8'h00}; // Orange
        rgb3 = {8'h80, 8'h68, 8'h00};
        rgb4 = {8'h80, 8'h80, 8'h00}; // Yellow
        rgb5 = {8'h40, 8'h80, 8'h00};
        rgb6 = {8'h00, 8'h80, 8'h00}; // Green
    end

endmodule
