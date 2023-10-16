`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2023 08:38:39 AM
// Design Name: 
// Module Name: key_rounds_tb
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


module key_schedule_tb;

reg [127:0] cipher_key;
reg [7:0] round;

initial round = 8'h0;

wire [127:0] key_o;

initial cipher_key = {8'h2B, 8'h28, 8'hAB, 8'h09,
                     8'h7E, 8'hAE, 8'hF7, 8'hCF,
                     8'h15, 8'hD2, 8'h15, 8'h4F,
                     8'h16, 8'hA6, 8'h88, 8'h3C};

//aes128 
    //encrypt (.clk_i(clk), .reset_i(reset), .cipher_key_i(cipher_key), .key_o(key_o));

key_schedule
    rounds (.round_num(round), .key_i(cipher_key), .key_r(key_o));

initial
begin
        #20 $finish;
end

endmodule
