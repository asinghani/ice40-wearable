`default_nettype none

module nekomimi_right (
    output logic ws, // LED

    input logic gpio4,
    inout logic gpio5,
    inout logic gpio6
);

    logic clk;
    logic [23:0] rgb0, rgb1, rgb2, rgb3, rgb4, rgb5, rgb6;

    nekomimi_base ctrl (.*);
    
    always_comb begin
        rgb0 = {8'h00, 8'h80, 8'h00}; // Green
        rgb1 = {8'h06, 8'h60, 8'h58}; 
        rgb2 = {8'h0B, 8'h40, 8'h90}; // Blue
        rgb3 = {8'h06, 8'h20, 8'h98};
        rgb4 = {8'h00, 8'h00, 8'hA0}; // Indigo
        rgb5 = {8'h40, 8'h00, 8'hA0};
        rgb6 = {8'h80, 8'h00, 8'hA0}; // Purple
    end

endmodule
