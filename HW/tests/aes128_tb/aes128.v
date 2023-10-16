
module aes128 (clk_i, reset_key_i, load_data_i, plain_text_i, cipher_key_i, enc_or_dec_i, cipher_text_o, key_ready_o, cipher_ready_o, round_o, round_key_i);

input clk_i, reset_key_i, load_data_i, enc_or_dec_i;
input [127:0] plain_text_i, cipher_key_i;
output reg [127:0] cipher_text_o;
output reg cipher_ready_o, key_ready_o;
output [127:0] round_o, round_key_i;

reg [7:0] key_round_num, state_round_num;

wire mix_col_i;

initial key_round_num = 8'h0;
initial state_round_num = 8'h0;
initial key_ready_o = 1'h0;

assign mix_col_i = (enc_or_dec_i) ? ((state_round_num == 8'hB) ? 1'h0 : 1'h1) : ((state_round_num == 8'hFF) ? 1'h0 : 1'h1);

reg [127:0] state_i, key_schedule_i, state_key_i;
wire [127:0] key_schedule_o, state_o;

localparam  STATE_KEYGEN_IN_PROG = 3'd0,
            STATE_KEYGEN_FINAL = 3'd1,
            STATE_KEY_GEN_DONE = 3'd2;

reg [2:0] key_schedule_state;

reg [127:0] round_keys [0:10];

assign round_o = state_i;
assign round_key_i = state_key_i;

key_schedule
    key_rounds (.round_num(key_round_num), .key_i(key_schedule_i), .key_r(key_schedule_o));

always @ (posedge clk_i)
begin
    if (reset_key_i)
    begin
        key_ready_o <= 8'h0;
        key_round_num <= 8'h1;
        round_keys[0] <= cipher_key_i;
        key_schedule_i <= cipher_key_i;
        key_schedule_state <= STATE_KEYGEN_IN_PROG;
    end
    else 
    begin
        case (key_schedule_state)
            STATE_KEYGEN_IN_PROG:
            begin
                round_keys[key_round_num] <= key_schedule_o;
                if (key_round_num == 8'hA)
                begin
                    key_schedule_state <= STATE_KEYGEN_FINAL;
                end
                else
                begin
                    key_schedule_i <= key_schedule_o;
                    key_round_num <= key_round_num + 8'h1; 
                end     
            end
            STATE_KEYGEN_FINAL:
            begin
                key_ready_o <= 1'h1;
                key_schedule_state <= STATE_KEY_GEN_DONE;
            end
        endcase      
    end
end


localparam  STATE_ENCRYPT_IN_PROG = 3'd0,
            STATE_ENCRYPT_DONE = 3'd1;
            
localparam  STATE_DECRYPT_IN_PROG = 3'd0,
            STATE_DECRYPT_DONE = 3'd1;        

reg [2:0] encrypt_state;
reg [2:0] decrypt_state;

round
    rounds (.state_i(state_i), .key_i(state_key_i), .mix_col_i(mix_col_i), .enc_or_dec_i(enc_or_dec_i), .state_o(state_o));

always @ (posedge clk_i)
begin
    if (enc_or_dec_i)
    begin
        if (key_ready_o & load_data_i)
        begin
            cipher_ready_o <= 1'h0;
            state_key_i <= round_keys[1];
            state_i <= (plain_text_i ^ round_keys[0]);
            state_round_num <= 8'h2;
            encrypt_state <= STATE_ENCRYPT_IN_PROG;
        end
        else
            case (encrypt_state)
                STATE_ENCRYPT_IN_PROG:
                begin
                    state_i <= state_o;
                    if (state_round_num == 8'hB)
                    begin
                        cipher_text_o <= state_o;
                        cipher_ready_o <= 1'h1;
                        encrypt_state <= STATE_ENCRYPT_DONE;
                    end
                    else
                    begin
                        state_key_i <= round_keys[state_round_num];
                        state_round_num <= state_round_num + 8'h1;
                    end                  
                end                
        endcase
        end        
    else
    begin
        if (key_ready_o & load_data_i)
        begin
            cipher_ready_o <= 1'h0;
            state_key_i <= round_keys[9];
            state_i <= (plain_text_i ^ round_keys[10]);
            state_round_num <= 8'h8;
            decrypt_state <= STATE_DECRYPT_IN_PROG;
        end
        else
        begin
            case (decrypt_state)
                STATE_DECRYPT_IN_PROG:
                begin
                   state_i <= state_o;
                   if (state_round_num == 8'hFF)
                   begin
                        cipher_text_o <= state_o;
                        cipher_ready_o <= 1'h1; 
                        decrypt_state <= STATE_DECRYPT_DONE;
                   end
                   else
                   begin
                        state_key_i <= round_keys[state_round_num];
                        state_round_num <= state_round_num - 8'h1;
                    end
                end
            endcase
        end
    end
end    

endmodule

