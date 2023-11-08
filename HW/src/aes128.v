/* Module encrypt or decrypt 128-bits of data using AES-128 (Rijndael Cipher) */
module aes128 (clk_i, reset_key_i, load_data_i, plain_text_i, cipher_key_i, enc_or_dec_i, cipher_text_o, key_ready_o, cipher_ready_o);

/* Input clock, reset key, load data - plainText or cipherText, encryption or decryption */
input clk_i, reset_key_i, load_data_i, enc_or_dec_i;
/* Plain text and cipher key input */
input [127:0] plain_text_i, cipher_key_i;

/* Output for cipherText or plainText after encryption / decryption */
output reg [127:0] cipher_text_o;
/* Output to indicate cipher ready and key ready */
output reg cipher_ready_o, key_ready_o;

/* Registers for counters - Key round and statre round numbers */
reg [7:0] key_round_num, state_round_num;

/* Wire to decide if the round needs mix column operation */
wire mix_col_i;

/* Initial value of key round number, state round number and key ready */
initial key_round_num = 8'h0;
initial state_round_num = 8'h0;
initial key_ready_o = 1'h0;

/* Decide whether mix column stage is required for that particular round based on encryption or decryption process */
assign mix_col_i = (enc_or_dec_i) ? ((state_round_num == 8'hB) ? 1'h0 : 1'h1) : ((state_round_num == 8'hFF) ? 1'h0 : 1'h1);

/* Register to store the state, input to key schedule and input round key */
reg [127:0] state_i, key_schedule_i, state_key_i;
/* Output from key scheudle and encryption or decryption round */
wire [127:0] key_schedule_o, state_o;

/* 
    Key schedule states
    1. STATE_KEYGEN_IN_PROG: Key generation is in progress
    2. STATE_KEYGEN_FINAL: Final round in key generation
    3. STATE_KEY_GEN_DONE: Key Generation completed
*/
localparam  STATE_KEYGEN_IN_PROG = 3'd0,
            STATE_KEYGEN_FINAL = 3'd1,
            STATE_KEY_GEN_DONE = 3'd2;

/* Register to store the key schedule state */
reg [2:0] key_schedule_state;

/* Memory to store the round keys (will be used at add round key stage) */
reg [127:0] round_keys [0:10];

/* Instantiate the key schedule module */
key_schedule
    key_rounds (.round_num(key_round_num), .key_i(key_schedule_i), .key_r(key_schedule_o));

/* FSM to generate keys in key schedule */
always @ (posedge clk_i)
begin
    /* New Key is loaded into the AES module */
    if (reset_key_i)
    begin
        key_ready_o <= 8'h0; // Clear the key ready line since key schedule is starting
        key_round_num <= 8'h1; // Reset key schedule round number to 1
        round_keys[0] <= cipher_key_i; // Save the initial cipher key in location 0
        key_schedule_i <= cipher_key_i; // Also input the key to the key schedule
        key_schedule_state <= STATE_KEYGEN_IN_PROG; // Change the state to key gen in progress
    end
    else 
    begin
        case (key_schedule_state)
            STATE_KEYGEN_IN_PROG:
            begin
                /* Store the obtained key in respective memory location */
                round_keys[key_round_num] <= key_schedule_o;
                if (key_round_num == 8'hA)
                begin
                    /* 10th round is the final round in key schedule 
                        hence change the state to final */
                    key_schedule_state <= STATE_KEYGEN_FINAL;
                end
                else
                begin
                    key_schedule_i <= key_schedule_o; // Feed the output of previous round as input
                    key_round_num <= key_round_num + 8'h1; // Update the key schedule round number
                end     
            end
            STATE_KEYGEN_FINAL:
            begin
                key_ready_o <= 1'h1; // Set the key ready line as key generation is complete 
                key_schedule_state <= STATE_KEY_GEN_DONE; // Change the state to key generation complete
            end
        endcase      
    end
end

/* 
    Encryption states: 
    1. STATE_ENCRYPT_IN_PROG: Encryption is in progress
    2. STATE_ENCRYPT_DONE: Encryption completed

    Decryption states:
    1. STATE_DECRYPT_IN_PROG: Encryption is in progress
    2. STATE_DECRYPT_DONE: Encryption completed 

*/
localparam  STATE_ENCRYPT_IN_PROG = 3'd0,
            STATE_ENCRYPT_DONE = 3'd1;
            
localparam  STATE_DECRYPT_IN_PROG = 3'd0,
            STATE_DECRYPT_DONE = 3'd1;        

/* Registers to store the encryption and decryption states */
reg [2:0] encrypt_state;
reg [2:0] decrypt_state;

/* Instaintiate the round module to perform one round of encryption / decryption with selective mix columns */
round
    rounds (.state_i(state_i), .key_i(state_key_i), .mix_col_i(mix_col_i), .enc_or_dec_i(enc_or_dec_i), .state_o(state_o));

always @ (posedge clk_i)
begin
    if (enc_or_dec_i) // Encryption
    begin
        if (key_ready_o & load_data_i) // Load the data only if the keys are ready
        begin 
            cipher_ready_o <= 1'h0; // Clear the cipher ready line as encryption is starting
            state_key_i <= round_keys[1]; // Load the key 1 from memory 
            state_i <= (plain_text_i ^ round_keys[0]); // Add 0th round key with plain text and send it as I/P
            state_round_num <= 8'h2; // Set the state round number to 2, as that key will only be used next
            encrypt_state <= STATE_ENCRYPT_IN_PROG; // Set the encrypt state to in progress
        end
        else
            case (encrypt_state)
                STATE_ENCRYPT_IN_PROG:
                begin
                    state_i <= state_o; // Feed the output of previous round as input
                    if (state_round_num == 8'hB) // 10 rounds in encryption for AES-128
                    begin
                        cipher_text_o <= state_o; // Set the cipher text as the encryption is over
                        cipher_ready_o <= 1'h1; // Set the cipher ready line
                        encrypt_state <= STATE_ENCRYPT_DONE; // Set the state to encryption done
                    end
                    else
                    begin
                        state_key_i <= round_keys[state_round_num]; // Input the appropriate key from memory
                        state_round_num <= state_round_num + 8'h1; // Update the round number
                    end                  
                end                
        endcase
        end        
    else // Decryption
    begin
        if (key_ready_o & load_data_i) // Load the data only if the keys are ready
        begin
            cipher_ready_o <= 1'h0; // Clear the cipher ready line as encryption is starting
            state_key_i <= round_keys[9]; // Load the key 9 from memory 
            state_i <= (plain_text_i ^ round_keys[10]); // Add 10th round key with plain text and send it as I/P
            state_round_num <= 8'h8; // Set the state round number to 8, as that key will only be used next
            decrypt_state <= STATE_DECRYPT_IN_PROG; // Set the decrypt state to in progress
        end
        else
        begin
            case (decrypt_state)
                STATE_DECRYPT_IN_PROG:
                begin
                   state_i <= state_o; // Feed the output of previous round as input
                   if (state_round_num == 8'hFF) // 10 rounds in encryption for AES-128 (rollover to FF upon decerement)
                   begin
                        cipher_text_o <= state_o; // Set the cipher text as the encryption is over
                        cipher_ready_o <= 1'h1; // Set the cipher ready line
                        decrypt_state <= STATE_DECRYPT_DONE; // Set the state to decryption done
                   end
                   else
                   begin
                        state_key_i <= round_keys[state_round_num]; // Input the appropriate key from memory
                        state_round_num <= state_round_num - 8'h1; // Update the round number
                    end
                end
            endcase
        end
    end
end    

endmodule
