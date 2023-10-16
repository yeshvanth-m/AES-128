`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Yeshvanth M
// Email: yeshvanthmuniraj@gmail.com 
// 
// Create Date: 09/29/2023 08:21:45 PM
// Design Name: AES128 Core
// Module Name: aes128_tb
// Project Name: AES128
// Target Devices: NA
// Tool Versions: Vivado 2023.1
// Description: Testbench for Verilog testbench
// 
// Dependencies: Design files
// 
// Revision: 1
// Revision 0.01 - File Created
// Additional Comments: None
// 
//////////////////////////////////////////////////////////////////////////////////


module aes128_tb;

reg clk;

/* Clock period */
localparam CLK_PERIOD = 10;
initial clk = 1'b0;

/* Generate clock */
always # (CLK_PERIOD / 2.0)
    clk = ~clk;

/* Declarations for using AES128 module */
reg reset_key_i, load_data_i, enc_or_dec_i;
reg [127:0] plain_text, plain_text_i, cipher_text_i, cipher_text_o;
reg [127:0] cipher_key, cipher_key_i;

wire [127:0] cipher_text, round_o, round_key_i;
wire cipher_ready, key_ready;

/* Initial values for reset key, plain text, cipher key */
initial reset_key_i = 0;
initial load_data_i = 0;
initial enc_or_dec_i = 1;

initial plain_text =  { 8'h4C, 8'h6D, 8'h73, 8'h64,
                        8'h6F, 8'h20, 8'h75, 8'h6F,
                        8'h72, 8'h69, 8'h6D, 8'h6C,
                        8'h65, 8'h70, 8'h20, 8'h6F };
                    
initial cipher_key =  { 8'h2B, 8'h28, 8'hAB, 8'h09,
                        8'h7E, 8'hAE, 8'hF7, 8'hCF,
                        8'h15, 8'hD2, 8'h15, 8'h4F,
                        8'h16, 8'hA6, 8'h88, 8'h3C };   
                    
initial cipher_text_o = {  8'hBF, 8'hC4, 8'hC7, 8'h71, 
                           8'hD7, 8'h2C, 8'hD6, 8'h5B,
                           8'h5C, 8'h4D, 8'hFA, 8'hAE, 
                           8'hFF, 8'hF8, 8'h0E, 8'hDB };                 

/* There is only one 128-bit lane through which the input can be fed */
initial cipher_key_i = cipher_key;
initial plain_text_i = cipher_key;

/* Instantiate AES128 module within TB */
aes128 
    encrypt (.clk_i(clk), .reset_key_i(reset_key_i), .load_data_i(load_data_i),.plain_text_i(plain_text_i), 
            .cipher_key_i(cipher_key_i), .enc_or_dec_i(enc_or_dec_i), .cipher_text_o(cipher_text), .cipher_ready_o(cipher_ready),
            .key_ready_o(key_ready), .round_o(round_o), .round_key_i(round_key_i));
integer i;

initial
begin
    /* Make the reset key high for one clock cycle to load the cipher key */
    reset_key_i = 1; #10;
    reset_key_i = 0; #10;
    
    assert (key_ready == 0) $display ("Key ready line assered low success");
    else $error("Key ready line not low after key load");
    
    /* It takes 10 cycles for key schedule to complete */
    for (i = 0; i < 10; i++)
        #10;
    
    assert (key_ready == 1) $display ("Key schedule completed in 10 cycles");
    else $error("Key schedule failed to complete in 10 cycles");
               
    /* There is only one 128-bit lane through which the input can be fed */           
    cipher_key_i = plain_text;
    plain_text_i = plain_text;
    
    /* Make the load data high to load the data (plain text) */
    load_data_i = 1; #10; 
    load_data_i = 0; #10;
    
    assert (cipher_ready == 0) $display ("Cipher ready line assered low success (1)");
    else $error("Cipher ready line not low after data load (1)");
    
    /* It takes 10 cycles for encyption to complete */
    for (i = 0; i < 10; i++)
        #10;
        
    assert (cipher_ready == 1) $display ("Encryption completed in 10 cycles");
    else $error("Encryption failed to complete in 10 cycles");
    
    assert (cipher_text_o == cipher_text) $display ("Cipher text generated correctly");
    else $error("Cipher text incorrect");
    
    
    /* Repetetive load data test */
    /* Make the load data high to load the data (plain text) */
    load_data_i = 1; #10; 
    load_data_i = 0; #10;
    
    assert (cipher_ready == 0)
    else $error("Cipher ready Low: Repetetive load data iteration 1 failed");
    
    /* It takes 10 cycles for encyption to complete */
    for (i = 0; i < 10; i++)
        #10;
        
    assert (cipher_ready == 1)
    else $error("Cipher ready High: Repetetive load data iteration 1 failed");
    
    assert (cipher_text_o == cipher_text)
    else $error("Cipher text: Repetetive load data iteration 1 failed");
    
    /* Make the load data high to load the data (plain text) */
    load_data_i = 1; #10; 
    load_data_i = 0; #10;
    
    assert (cipher_ready == 0)
    else $error("Cipher ready: Repetetive load data iteration 2 failed");
    
    /* It takes 10 cycles for encyption to complete */
    for (i = 0; i < 10; i++)
        #10;
        
    assert (cipher_ready == 1)
    else $error("Cipher ready: Repetetive load data iteration 2 failed");
    
    assert (cipher_text_o == cipher_text)
    else $error("Cipher text: Repetetive load data iteration 2 failed");
    
    /* Repetetive load key test */
    /* There is only one 128-bit lane through which the input can be fed */
    cipher_key_i = cipher_key;
    plain_text_i = cipher_key;
    
    /* Make the reset key high for one clock cycle to load the cipher key */
    reset_key_i = 1; #10;
    reset_key_i = 0; #10;
    
    assert (key_ready == 0)
    else $error("Key ready Low: Repetetive load key iteration 1 failed");
    
    /* It takes 10 cycles for key schedule to complete */
    for (i = 0; i < 10; i++)
        #10;
    
    assert (key_ready == 1)
    else $error("Key ready High: Repetetive load key iteration 1 failed");
    
    /* There is only one 128-bit lane through which the input can be fed */
    cipher_key_i = plain_text;
    plain_text_i = plain_text;
    
     /* Make the load data high to load the data (plain text) */
    load_data_i = 1; #10; 
    load_data_i = 0; #10;
    
    assert (cipher_ready == 0)
    else $error("Cipher ready: Repetetive load data iteration 3 failed");
    
    /* It takes 10 cycles for encyption to complete */
    for (i = 0; i < 10; i++)
        #10;
        
    assert (cipher_ready == 1)
    else $error("Cipher ready: Repetetive load data iteration 3 failed");
    
    assert (cipher_text_o == cipher_text)
    else $error("Cipher text: Repetetive load data iteration 3 failed");
        
    /* Decryption test, make the control line low */
    enc_or_dec_i = 0;
    
    /* Get the output cipher text and give it as input */
    cipher_text_i = cipher_text;
    cipher_key_i = cipher_text_i;
    plain_text_i = cipher_text_i;
    
    /* Make the load data high to load the data (cipher text) */
    load_data_i = 1; #10; 
    load_data_i = 0; #10;
    
    assert (cipher_ready == 0) $display ("Cipher ready line assered low success (2)");
    else $error("Cipher ready line not low after data load (2)");
    
    /* It takes 10 cycles for encyption to complete */
    for (i = 0; i < 10; i++)
        #10;
        
    assert (cipher_ready == 1) $display ("Decryption completed in 10 cycles");
    else $error("Decryption failed to complete in 10 cycles");
    
    assert (cipher_text == plain_text) $display ("Plain text generated correctly");
    else $error("Plain text incorrect");
    
    #10	$finish;
    
end

endmodule
