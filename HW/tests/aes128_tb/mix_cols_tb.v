`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2023 08:14:57 AM
// Design Name: 
// Module Name: mix_cols_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mix_cols_tb;

reg mix_col_i;

reg [127:0] mc_i;
wire [127:0] mc_o;

mix_cols 
    mc (.mix_col_i(mix_col_i), .mc_i(mc_i), .mc_o(mc_o));

initial mix_col_i = 1'h0;

initial mc_i = {8'h4C, 8'h6D, 8'h73, 8'h64,
                8'h6F, 8'h20, 8'h75, 8'h6F,
                8'h72, 8'h69, 8'h6D, 8'h6C,
                8'h65, 8'h70, 8'h20, 8'h6F};

// Apply input stimulus
initial
begin
    #10	$finish;
end

endmodule
