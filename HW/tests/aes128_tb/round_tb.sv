`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2023 07:16:38 PM
// Design Name: 
// Module Name: round_tb
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


module round_tb;

reg [127:0] plain_text, cipher_key, key_i;
reg mix_col_i, enc_or_dec_i;
wire [127:0] state_o, state_i, sb_out, sr_out, mc_out;

initial plain_text =  { 8'h4C, 8'h6D, 8'h73, 8'h64,
                        8'h6F, 8'h20, 8'h75, 8'h6F,
                        8'h72, 8'h69, 8'h6D, 8'h6C,
                        8'h65, 8'h70, 8'h20, 8'h6F };
                    
initial cipher_key =  { 8'h2B, 8'h28, 8'hAB, 8'h09,
                        8'h7E, 8'hAE, 8'hF7, 8'hCF,
                        8'h15, 8'hD2, 8'h15, 8'h4F,
                        8'h16, 8'hA6, 8'h88, 8'h3C};

initial key_i       = { 8'hA0, 8'h88, 8'h23, 8'h2A,
                        8'hFA, 8'h54, 8'hA3, 8'h6C,
                        8'hFE, 8'h2C, 8'h39, 8'h76,
                        8'h17, 8'hB1, 8'h39, 8'h05};


initial mix_col_i = 1'h1;
initial enc_or_dec_i = 1'h1;

assign state_i = plain_text ^ cipher_key;

round 
    one_round (.state_i(state_i), .key_i(key_i), .mix_col_i(mix_col_i), .enc_or_dec_i(enc_or_dec_i),
               .sb_out(sb_out), .sr_out(sr_out), .mc_out(mc_out), .state_o(state_o));

initial
begin
    #10;	$finish;
end

endmodule
