#include "aes128.h"

uint8_t aes128_state[16u] = 
{
    0x4C, 0x6D, 0x73, 0x64,
    0x6F, 0x20, 0x75, 0x6F,
    0x72, 0x69, 0x6D, 0x6C,
    0x65, 0x70, 0x20, 0x6F
};

uint8_t aes128_cipherKey[16u] = 
{
    0x2B, 0x28, 0xAB, 0x09,
    0x7E, 0xAE, 0xF7, 0xCF,
    0x15, 0xD2, 0x15, 0x4F,
    0x16, 0xA6, 0x88, 0x3C
};

void aes128_add_round_key (uint8_t round, bool aes128_is_encrypt)
{
    uint8_t *round_key;

    if (aes128_is_encrypt)
    {
        if (round == 0)
        {
            round_key = aes128_cipherKey;
        }
        else
        {
            round--;
            round_key = aes128_round_keys[round];
        }
    }
    else
    {
        round = 10 - round;
        if (round == 0)
        {
            round_key = aes128_cipherKey;
        }
        else
        {
            round--;
            round_key = aes128_round_keys[round];
        }
    }
    
    for (uint8_t idx = 0; idx < 16u; idx++)
    {
        aes128_state[idx] ^= round_key[idx];
    }
    
}

void aes128_substitute_bytes (bool aes128_is_encrypt)
{
    const uint8_t *sBoxMat;
    if (aes128_is_encrypt)
    {
        sBoxMat = aes128_sBox;
    }
    else
    {
        sBoxMat = aes128_sBox_Inv;
    }
    for (uint8_t idx = 0u; idx < 4u; idx++)
    {
        aes128_state[idx] = sBoxMat[aes128_state[idx]];
    }
}

void aes128_shift_rows (bool aes128_is_encrypt)
{
    if (aes128_is_encrypt)
    {
        for (uint8_t row = 1u; row < 4u; row++)
        {
            uint8_t shift = row;
            while (shift > 0u)
            {
                uint8_t col = 0u, temp = aes128_state[(row * STATE_ROWS) + col];
                while (col < 3u)
                {
                    aes128_state[(row * STATE_ROWS) + col] = aes128_state[(row * STATE_ROWS) + col + 1u];
                    col++;
                }
                aes128_state[(row * STATE_ROWS) + col] = temp;
                shift--;
            }
        }
    }
    else
    {
        for (uint8_t row = 1u; row < 4u; row++)
        {
            uint8_t shift = row;
            while (shift > 0u)
            {
                uint8_t col = 3u, temp = aes128_state[(row * STATE_ROWS) + col];
                while (col > 0u)
                {
                    aes128_state[(row * STATE_ROWS) + col] = aes128_state[(row * STATE_ROWS) + col - 1u];
                    col--;
                }
                aes128_state[(row * STATE_ROWS) + col] = temp;
                shift--;
            }
        }
    }
    
}

uint8_t aes128_mul_bytes (uint8_t *lut, uint8_t byte)
{
    return lut[byte];
}

void aes128_mix_columns (bool aes128_is_encrypt)
{
    uint8_t *column_mix_matrix;

    if (aes128_is_encrypt)
    {
        column_mix_matrix = aes128_column_mix_matrix;
    }
    else
    {
        column_mix_matrix = aes128_column_mix_matrix_inv;
    }

    for (uint8_t state_col = 0u; state_col < 4u; state_col++)
    {
        uint8_t state_column[4u];
        for (uint8_t matrix_row = 0u; matrix_row < 4u; matrix_row++)
        {
            uint8_t col_sum = 0u;
            for (uint8_t matrix_col = 0u; matrix_col < 4u; matrix_col++)
            {
                switch (column_mix_matrix[(matrix_row * COL_MAT_ROWS) + matrix_col])
                {
                    case 0x1:
                    {
                        col_sum ^= aes128_state[(matrix_col * STATE_ROWS) + state_col];
                        break;
                    }
                    case 0x2:
                    {
                        col_sum ^= aes128_mul_bytes (aes128_mul_by_2, aes128_state[(matrix_col * STATE_ROWS) + state_col]);
                        break;
                    }
                    case 0x3:
                    {
                        col_sum ^= aes128_mul_bytes (aes128_mul_by_3, aes128_state[(matrix_col * STATE_ROWS) + state_col]);
                        break;
                    }
                    case 0x9:
                    {
                        col_sum ^=  aes128_mul_bytes (aes128_mul_by_9, aes128_state[(matrix_col * STATE_ROWS) + state_col]);
                        break;
                    }
                    case 0xb:
                    {
                        col_sum ^= aes128_mul_bytes (aes128_mul_by_b, aes128_state[(matrix_col * STATE_ROWS) + state_col]);
                        break;
                    }
                    case 0xd:
                    {
                        col_sum ^= aes128_mul_bytes (aes128_mul_by_d, aes128_state[(matrix_col * STATE_ROWS) + state_col]);
                        break;
                    }
                    case 0xe:
                    {
                        col_sum ^= aes128_mul_bytes (aes128_mul_by_e, aes128_state[(matrix_col * STATE_ROWS) + state_col]);
                        break;
                    }
                    default:
                        break;
                }
            }
            state_column[matrix_row] = col_sum;
        }
        for (uint8_t state_row = 0; state_row < 4; state_row++)
        {
            aes128_state[(state_row * STATE_ROWS) + state_col] = state_column[state_row];
        }
    }
}

void aes128_key_schedule (void)
{
    memcpy ((void *)aes128_round_keys[0u], (void *)aes128_cipherKey, sizeof(aes128_cipherKey));
    for (uint8_t round = 0; round < 10; round++)
    {
        uint8_t rcon[4u] = {aes128_rcon[round], 0u, 0u, 0u};
        uint8_t round_key_col[4u];

        uint8_t row = 0u, col = 3u, temp = aes128_round_keys[round][(row * KEY_ROWS) + col];
        while (row < 3u)
        {
            round_key_col[row] = aes128_round_keys[round][((row + 1u) * KEY_ROWS) + col];
            row++;
        }
        round_key_col[row] = temp;

        for (row = 0u; row < 4u; row++)
        {
            round_key_col[row] = aes128_sBox[((((round_key_col[row]) & (0xF0u)) >> 4u) * SBOX_ROWS) + ((round_key_col[row]) & (0x0Fu))];
        }

        for (col = 0u; col < 4u; col++)
        {
            if (col == 0u)
            {
                for (row = 0u; row < 4u; row++)
                {
                    aes128_round_keys[round][(row * KEY_ROWS) + col] ^= (rcon[row] ^ round_key_col[row]);
                }
            }
            else
            {
                for (row = 0u; row < 4u; row++)
                {
                    aes128_round_keys[round][(row * KEY_ROWS) + col] ^= aes128_round_keys[round][(row * KEY_ROWS) + col - 1u];
                }
            }
        }
        memcpy ((void *)aes128_round_keys[round + 1], (void *)aes128_round_keys[round], sizeof(aes128_round_keys[round]));
    }
}

int main()
{
    uint8_t round = 0u;
    bool encrypt = true, decrypt = !encrypt;

    aes128_add_round_key (round, encrypt);
    aes128_key_schedule ();

    for (round = 1; round < 10; round++)
    {
        aes128_substitute_bytes (encrypt);
        aes128_shift_rows (encrypt);
        aes128_mix_columns (encrypt);
        aes128_add_round_key (round, encrypt);
    }
    
    aes128_substitute_bytes (encrypt);
    aes128_shift_rows (encrypt);
    aes128_add_round_key (round, encrypt);

    round = 0u;
    aes128_add_round_key (round, decrypt);

    for (round = 1; round < 10; round++)
    {
        aes128_shift_rows (decrypt);
        aes128_substitute_bytes (decrypt);
        aes128_add_round_key (round, decrypt);
        aes128_mix_columns (decrypt);
    }

    aes128_shift_rows (decrypt);
    aes128_substitute_bytes (decrypt);
    aes128_add_round_key (round, decrypt);

    printf("Hello World");
}