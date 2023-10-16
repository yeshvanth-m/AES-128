`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2023 07:47:33 AM
// Design Name: 
// Module Name: sub_bytes_shft_rows_tb
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


module sub_bytes_shft_rows_tb;

reg [127:0] sb_i;
wire [127:0] sb_o;

sub_bytes_shft_rows 
    sbsr(.sb_i(sb_i), .sb_o(sb_o));

initial sb_i = {8'h4C, 8'h6D, 8'h73, 8'h64,
                8'h6F, 8'h20, 8'h75, 8'h6F,
                8'h72, 8'h69, 8'h6D, 8'h6C,
                8'h65, 8'h70, 8'h20, 8'h6F};

// Apply input stimulus
initial
begin
    #20	$finish;
end

endmodule
