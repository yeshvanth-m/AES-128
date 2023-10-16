module round (state_i, key_i, mix_col_i, enc_or_dec_i, state_o);

input mix_col_i, enc_or_dec_i;
input [127:0] state_i, key_i;
output [127:0] state_o;

wire [127:0] sb_i, sr_i, mc_i, ark_i, sb_o, sr_o, mc_o, ark_o, enc_mc_i, dec_mc_i, enc_mc_o, dec_mc_o;

assign enc_mc_i = (enc_or_dec_i == 1) ? mc_i: 0;
assign dec_mc_i = (enc_or_dec_i == 1) ? 0 : mc_i;
assign mc_o = (enc_or_dec_i == 1) ? enc_mc_o : dec_mc_o; 

sub_bytes
	sb (.sb_i(sb_i), .enc_or_dec_i(enc_or_dec_i), .sb_o(sb_o));

shift_rows
    sr (.sr_i(sr_i), .enc_or_dec_i(enc_or_dec_i), .sr_o(sr_o));

mix_cols_enc
	enc_mc (.mix_col_i(mix_col_i), .mc_i(enc_mc_i), .mc_o(enc_mc_o));
	
mix_cols_dec
	dec_mc (.mix_col_i(mix_col_i), .mc_i(dec_mc_i), .mc_o(dec_mc_o));
	
add_round_key
    rk (.state_i(ark_i), .key_i(key_i), .state_o(ark_o));
    
assign sb_i =    (enc_or_dec_i == 1) ? state_i : sr_o;
assign sr_i =    (enc_or_dec_i == 1) ? sb_o : state_i;
assign mc_i =    (enc_or_dec_i == 1) ? sr_o : ark_o;
assign ark_i =   (enc_or_dec_i == 1) ? mc_o : sb_o;
assign state_o = (enc_or_dec_i == 1) ? ark_o : mc_o;

endmodule

module sub_bytes (sb_i, enc_or_dec_i, sb_o);

input enc_or_dec_i;
input [127:0] sb_i;
output [127:0] sb_o;

wire [31:0] row0_i, row1_i, row2_i, row3_i,
		    row0_o, row1_o, row2_o, row3_o;

assign { row0_i, row1_i, row2_i, row3_i } = sb_i;

sub_word
	row0 (.enc_or_dec_i(enc_or_dec_i), .word_i(row0_i), .word_o(row0_o)),
	row1 (.enc_or_dec_i(enc_or_dec_i), .word_i(row1_i), .word_o(row1_o)),
	row2 (.enc_or_dec_i(enc_or_dec_i), .word_i(row2_i), .word_o(row2_o)),
	row3 (.enc_or_dec_i(enc_or_dec_i), .word_i(row3_i), .word_o(row3_o));
	
assign sb_o = { row0_o, row1_o, row2_o, row3_o };

endmodule

module shift_rows (sr_i, enc_or_dec_i, sr_o);

input enc_or_dec_i;
input [127:0] sr_i;
output [127:0] sr_o;

wire [31:0] row0_i, row1_i, row2_i, row3_i,
		    enc_row0_o, enc_row1_o, enc_row2_o, enc_row3_o,
		    dec_row0_o, dec_row1_o, dec_row2_o, dec_row3_o;

assign { row0_i, row1_i, row2_i, row3_i } = sr_i;
	
assign enc_row0_o =  row0_i;
assign enc_row1_o = { row1_i[23:0], row1_i[31:24] };
assign enc_row2_o = { row2_i[15:0], row2_i[31:16] };
assign enc_row3_o = { row3_i[7:0],  row3_i[31:8] };

assign dec_row0_o =  row0_i;
assign dec_row1_o = { row1_i[7:0],   row1_i[31:8] };
assign dec_row2_o = { row2_i[15:0],  row2_i[31:16] };
assign dec_row3_o = { row3_i[23:0],  row3_i[31:24] };
	
assign sr_o = (enc_or_dec_i == 1) ? {enc_row0_o, enc_row1_o, enc_row2_o, enc_row3_o} : 
                                      {dec_row0_o, dec_row1_o, dec_row2_o, dec_row3_o};

endmodule

module mix_cols_enc (mix_col_i, mc_i, mc_o);

input mix_col_i;
input [127:0] mc_i;
output [127:0] mc_o;

wire [31:0] row0_i, row1_i, row2_i, row3_i,
            row0_o, row1_o, row2_o, row3_o,
            col0_i, col1_i, col2_i, col3_i,
            col0_o, col1_o, col2_o, col3_o;

assign { row0_i, row1_i, row2_i, row3_i } = mc_i;

assign col0_i = { row0_i[31:24], row1_i[31:24], row2_i[31:24], row3_i[31:24] };
assign col1_i = { row0_i[23:16], row1_i[23:16], row2_i[23:16], row3_i[23:16] };
assign col2_i = { row0_i[15:8],  row1_i[15:8],  row2_i[15:8],  row3_i[15:8] };
assign col3_i = { row0_i[7:0],   row1_i[7:0],   row2_i[7:0],   row3_i[7:0] };

mul_cols_enc
    mul_col_0 (col0_i, col0_o),
    mul_col_1 (col1_i, col1_o),
    mul_col_2 (col2_i, col2_o),
    mul_col_3 (col3_i, col3_o);
    
assign row0_o = { col0_o[31:24], col1_o[31:24], col2_o[31:24], col3_o[31:24] };
assign row1_o = { col0_o[23:16], col1_o[23:16], col2_o[23:16], col3_o[23:16] };
assign row2_o = { col0_o[15:8],  col1_o[15:8],  col2_o[15:8],  col3_o[15:8]  };
assign row3_o = { col0_o[7:0],   col1_o[7:0],   col2_o[7:0],   col3_o[7:0]   };

/* No mix columns in round 10 */
assign mc_o = (mix_col_i == 1) ? { row0_o, row1_o, row2_o, row3_o } : mc_i;

endmodule

module mix_cols_dec (mix_col_i, mc_i, mc_o);

input mix_col_i;
input [127:0] mc_i;
output [127:0] mc_o;

wire [31:0] row0_i, row1_i, row2_i, row3_i,
            row0_o, row1_o, row2_o, row3_o,
            col0_i, col1_i, col2_i, col3_i,
            col0_o, col1_o, col2_o, col3_o;

assign { row0_i, row1_i, row2_i, row3_i } = mc_i;

assign col0_i = { row0_i[31:24], row1_i[31:24], row2_i[31:24], row3_i[31:24] };
assign col1_i = { row0_i[23:16], row1_i[23:16], row2_i[23:16], row3_i[23:16] };
assign col2_i = { row0_i[15:8],  row1_i[15:8],  row2_i[15:8],  row3_i[15:8] };
assign col3_i = { row0_i[7:0],   row1_i[7:0],   row2_i[7:0],   row3_i[7:0] };

mul_cols_dec
    mul_col_0 (col0_i, col0_o),
    mul_col_1 (col1_i, col1_o),
    mul_col_2 (col2_i, col2_o),
    mul_col_3 (col3_i, col3_o);
    
assign row0_o = { col0_o[31:24], col1_o[31:24], col2_o[31:24], col3_o[31:24] };
assign row1_o = { col0_o[23:16], col1_o[23:16], col2_o[23:16], col3_o[23:16] };
assign row2_o = { col0_o[15:8],  col1_o[15:8],  col2_o[15:8],  col3_o[15:8]  };
assign row3_o = { col0_o[7:0],   col1_o[7:0],   col2_o[7:0],   col3_o[7:0]   };

/* No mix columns in round 10 */
assign mc_o = (mix_col_i == 1) ? { row0_o, row1_o, row2_o, row3_o } : mc_i;

endmodule

module mul_cols_enc (col_i, col_o);

input [31:0] col_i;
output [31:0] col_o;

wire [31:0] col_enc_o, col_dec_o;

wire [7:0] c0_mul_2_o, c0_mul_3_o,
           c1_mul_2_o, c1_mul_3_o,
           c2_mul_2_o, c2_mul_3_o,
           c3_mul_2_o, c3_mul_3_o;
           
mul_by_2
    c0_2 (col_i[31:24], c0_mul_2_o),
    c1_2 (col_i[23:16], c1_mul_2_o),
    c2_2 (col_i[15:8],  c2_mul_2_o),
    c3_2 (col_i[7:0],   c3_mul_2_o);
    
mul_by_3
    c0_3 (col_i[23:16], c0_mul_3_o),
    c1_3 (col_i[15:8],  c1_mul_3_o),
    c2_3 (col_i[7:0],   c2_mul_3_o),
    c3_3 (col_i[31:24], c3_mul_3_o);

assign col_enc_o[31:24] = (c0_mul_2_o   ^ c0_mul_3_o   ^ col_i[15:8] ^ col_i[7:0]);
assign col_enc_o[23:16] = (col_i[31:24] ^ c1_mul_2_o   ^ c1_mul_3_o  ^ col_i[7:0]);
assign col_enc_o[15:8]  = (col_i[31:24] ^ col_i[23:16] ^ c2_mul_2_o  ^ c2_mul_3_o);
assign col_enc_o[7:0]   = (c3_mul_3_o   ^ col_i[23:16] ^ col_i[15:8] ^ c3_mul_2_o);

assign col_o = col_enc_o;

endmodule

module mul_cols_dec (col_i, col_o);

input [31:0] col_i;
output [31:0] col_o;

wire [31:0] col_enc_o, col_dec_o;

wire [7:0] c0_mul_9_o, c0_mul_b_o, c0_mul_d_o, c0_mul_e_o,
           c1_mul_9_o, c1_mul_b_o, c1_mul_d_o, c1_mul_e_o,
           c2_mul_9_o, c2_mul_b_o, c2_mul_d_o, c2_mul_e_o,
           c3_mul_9_o, c3_mul_b_o, c3_mul_d_o, c3_mul_e_o;
           
mul_by_9
    c0_9 (col_i[7:0],   c0_mul_9_o),
    c1_9 (col_i[31:24], c1_mul_9_o),
    c2_9 (col_i[23:16], c2_mul_9_o),
    c3_9 (col_i[15:8],  c3_mul_9_o);
    
mul_by_b
    c0_b (col_i[23:16], c0_mul_b_o),
    c1_b (col_i[15:8],  c1_mul_b_o),
    c2_b (col_i[7:0],   c2_mul_b_o),
    c3_b (col_i[31:24], c3_mul_b_o);

mul_by_d
    c0_d (col_i[15:8],  c0_mul_d_o),
    c1_d (col_i[7:0],   c1_mul_d_o),
    c2_d (col_i[31:24], c2_mul_d_o),
    c3_d (col_i[23:16], c3_mul_d_o);
    
mul_by_e
    c0_e (col_i[31:24], c0_mul_e_o),
    c1_e (col_i[23:16], c1_mul_e_o),
    c2_e (col_i[15:8],  c2_mul_e_o),
    c3_e (col_i[7:0],   c3_mul_e_o);

assign col_dec_o[31:24] = (c0_mul_9_o ^ c0_mul_b_o ^ c0_mul_d_o ^ c0_mul_e_o);
assign col_dec_o[23:16] = (c1_mul_9_o ^ c1_mul_b_o ^ c1_mul_d_o ^ c1_mul_e_o);
assign col_dec_o[15:8]  = (c2_mul_9_o ^ c2_mul_b_o ^ c2_mul_d_o ^ c2_mul_e_o);
assign col_dec_o[7:0]   = (c3_mul_9_o ^ c3_mul_b_o ^ c3_mul_d_o ^ c3_mul_e_o);

assign col_o = col_dec_o;

endmodule 

module add_round_key (state_i, key_i, state_o);

input [127:0] state_i, key_i;
output [127:0] state_o;

assign state_o = state_i ^ key_i;

endmodule