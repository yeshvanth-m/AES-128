/* Module to generate round key in for one round in key schedule */
module key_schedule (round_num, key_i, key_r);

input [7:0] round_num;
input [127:0] key_i;
output [127:0] key_r;

reg enc_or_dec_i;

/* Keys are same for encryption and decryption (used in other modules) */
initial enc_or_dec_i = 1'h1;

/* Rows and columns used in key schedule */
wire [31:0] row0_i, row1_i, row2_i, row3_i,
            row0_o, row1_o, row2_o, row3_o,
            col0_i, col1_i, col2_i, col3_i,
            col0_o, col1_o, col2_o, col3_o,
            rot_col_3, sub_col_o;
            
wire [7:0] rcon_o;        

assign { row0_i, row1_i, row2_i, row3_i } = key_i;

/* Rotate word with columns assignment */
assign col0_i = { row0_i[31:24], row1_i[31:24], row2_i[31:24], row3_i[31:24] };
assign col1_i = { row0_i[23:16], row1_i[23:16], row2_i[23:16], row3_i[23:16] };
assign col2_i = { row0_i[15:8],  row1_i[15:8],  row2_i[15:8],  row3_i[15:8]  };
assign col3_i = { row0_i[7:0],   row1_i[7:0],   row2_i[7:0],   row3_i[7:0]   };

/* Rotate column 3 */
assign rot_col_3 = { row1_i[7:0], row2_i[7:0], row3_i[7:0], row0_i[7:0] };

/* Substitute word */
sub_word
    col3 (.enc_or_dec_i(enc_or_dec_i), .word_i(rot_col_3), .word_o(sub_col_o));

/* Rcon column based on the key schedule round */
rcon
    rcon_sub (.in(round_num), .out(rcon_o));

/* Multiply the column with Rcon and previous column */
assign col0_o = col0_i ^ sub_col_o ^ {rcon_o, 24'b0};
assign col1_o = col1_i ^ col0_o;
assign col2_o = col2_i ^ col1_o;
assign col3_o = col3_i ^ col2_o;

assign row0_o = { col0_o[31:24], col1_o[31:24], col2_o[31:24], col3_o[31:24] };
assign row1_o = { col0_o[23:16], col1_o[23:16], col2_o[23:16], col3_o[23:16] };
assign row2_o = { col0_o[15:8],  col1_o[15:8],  col2_o[15:8],  col3_o[15:8]  };
assign row3_o = { col0_o[7:0],   col1_o[7:0],   col2_o[7:0],   col3_o[7:0]   };

/* Result key in the key round */
assign key_r = { row0_o, row1_o, row2_o, row3_o };

endmodule
