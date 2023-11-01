/********************************************************************************
* @file     aes128.c                                                            *
* @brief    AES128 C implementation File                                        *
* @author   Yeshvanth M  <yeshvanthmuniraj@gmail.com>                           *
* @date     15-Sep-2023                                                         *
*********************************************************************************
*                                                                               *
* This program is free software: you can redistribute it and/or modify it       *
* under the terms of the GNU General Public License as published by the Free    *
* Software Foundation, either version 3 of the License, or (at your option)     *
* any later version.                                                            *
*                                                                               *
* This program is distributed in the hope that it will be useful, but           *
* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY    *
* or FITNESS FOR A PARTICULAR PURPOSE.                                          *
* See the GNU General Public License for more details.                          *
*                                                                               *
* You should have received a copy of the GNU General Public License             *
* along with this program. If not, see <https://www.gnu.org/licenses/>.         *
*                                                                               *
********************************************************************************/

#include "aes128.h"

/* The AES128 state matrix - will undergo operations */
uint8_t aes128_state[16u];

/* The input cipher key for encryption/decryption */
uint8_t aes128_cipherKey[16u];

/* Function to add round key to the state */
void aes128_add_round_key (uint8_t round, bool aes128_is_encrypt)
{
    uint8_t *round_key;

    if (aes128_is_encrypt)
    {
        /* Encryption process */
        if (round == 0)
        {
            /* The input cipher key is used in round 0 */
            round_key = aes128_cipherKey;
        }
        else
        {
            /* Use the generated keys for consecutive rounds */
            round--;
            round_key = aes128_round_keys[round];
        }
    }
    else
    {
        /* Decryption process */
        round = 10 - round;
        if (round == 0)
        {
            /* Input cipher key used in final round */
            round_key = aes128_cipherKey;
        }
        else
        {
            /* Use the generated keys in other rounds */
            round--;
            round_key = aes128_round_keys[round];
        }
    }
    
    for (uint8_t idx = 0; idx < 16u; idx++)
    {
        /* Add the round key byte by byte */
        aes128_state[idx] ^= round_key[idx];
    }
    
}

/* Function to substitute bytes */
void aes128_substitute_bytes (bool aes128_is_encrypt)
{
    const uint8_t *sBoxMat;
    if (aes128_is_encrypt)
    {
        /* Use SBox matrix in encryption */
        sBoxMat = aes128_sBox;
    }
    else
    {
        /* Use inverse SBox in decryption */
        sBoxMat = aes128_sBox_Inv;
    }
    for (uint8_t idx = 0u; idx < 16u; idx++)
    {
        /* Subsitutue byte by byte */
        aes128_state[idx] = sBoxMat[aes128_state[idx]];
    }
}

/* Function to shift rows */
void aes128_shift_rows (bool aes128_is_encrypt)
{
    if (aes128_is_encrypt)
    {
        /* Row 0 is not shifted, other rows undergo circular left shift in encryption */
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
        /* Row 0 is not shifted, other rows undergo circular right shift in decryption */
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

/* Function to mix columns */
void aes128_mix_columns (bool aes128_is_encrypt)
{
    uint8_t *column_mix_matrix;

    if (aes128_is_encrypt)
    {
        /* Use mix column matrix for multiplication in encryption */
        column_mix_matrix = aes128_column_mix_matrix;
    }
    else
    {
        /* Use inverse mix column matrix for multiplication in decryption */
        column_mix_matrix = aes128_column_mix_matrix_inv;
    }

    /* Multiplication by X is done with the help of LUTs */
    for (uint8_t state_col = 0u; state_col < 4u; state_col++)
    {
        /* Perform matrix multiplication */
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
                        col_sum ^= aes128_mul_by_2[aes128_state[(matrix_col * STATE_ROWS) + state_col]];
                        break;
                    }
                    case 0x3:
                    {
                        col_sum ^= aes128_mul_by_3[aes128_state[(matrix_col * STATE_ROWS) + state_col]];
                        break;
                    }
                    case 0x9:
                    {
                        col_sum ^= aes128_mul_by_9[aes128_state[(matrix_col * STATE_ROWS) + state_col]];
                        break;
                    }
                    case 0xb:
                    {
                        col_sum ^= aes128_mul_by_b[aes128_state[(matrix_col * STATE_ROWS) + state_col]];
                        break;
                    }
                    case 0xd:
                    {
                        col_sum ^= aes128_mul_by_d[aes128_state[(matrix_col * STATE_ROWS) + state_col]];
                        break;
                    }
                    case 0xe:
                    {
                        col_sum ^= aes128_mul_by_e[aes128_state[(matrix_col * STATE_ROWS) + state_col]];
                        break;
                    }
                    default:
                        break;
                }
            }
            state_column[matrix_row] = col_sum;
        }
        /* Save the computed column in state */
        for (uint8_t state_row = 0; state_row < 4; state_row++)
        {
            aes128_state[(state_row * STATE_ROWS) + state_col] = state_column[state_row];
        }
    }
}

/* Function to generate keys using the key schedule */
void aes128_key_schedule (uint8_t *cipherKey)
{
    /* Copy the cipher key */
    memcpy((void *) aes128_cipherKey, (void *) cipherKey, sizeof(aes128_cipherKey));
    /* Use the initial cipher key for rounds */
    memcpy ((void *)aes128_round_keys[0u], (void *)aes128_cipherKey, sizeof(aes128_cipherKey));
    for (uint8_t round = 0; round < 10; round++)
    {
        /* Form the Rcon matrix */
        uint8_t rcon[4u] = {aes128_rcon[round], 0u, 0u, 0u};
        uint8_t round_key_col[4u];

        uint8_t row = 0u, col = 3u, temp = aes128_round_keys[round][(row * KEY_ROWS) + col];
        /* Obtain the round key column 3 and shift it by 1 */
        while (row < 3u)
        {
            round_key_col[row] = aes128_round_keys[round][((row + 1u) * KEY_ROWS) + col];
            row++;
        }
        round_key_col[row] = temp;

        /* Substitute bytes for the obtained column */
        for (row = 0u; row < 4u; row++)
        {
            round_key_col[row] = aes128_sBox[round_key_col[row]];
        }

        for (col = 0u; col < 4u; col++)
        {
            if (col == 0u)
            {
                for (row = 0u; row < 4u; row++)
                {
                    /* First column of generated key is XORed with Rcon matrix and 3rd column of previous key */
                    aes128_round_keys[round][(row * KEY_ROWS) + col] ^= (rcon[row] ^ round_key_col[row]);
                }
            }
            else
            {
                for (row = 0u; row < 4u; row++)
                {
                    /* Other columns are obtained by XORing previous column of current key with column of previous key */
                    aes128_round_keys[round][(row * KEY_ROWS) + col] ^= aes128_round_keys[round][(row * KEY_ROWS) + col - 1u];
                }
            }
        }
        /* Save the generated key */
        memcpy ((void *)aes128_round_keys[round + 1], (void *)aes128_round_keys[round], sizeof(aes128_round_keys[round]));
    }
}

void aes128_encrypt (uint8_t *plainText, uint8_t *cipherText)
{
    bool encrypt = true;
    uint8_t round = 0u;

    memcpy ((void *)aes128_state, (void *)plainText, sizeof(aes128_state));

    /* Start encryption by adding round key to input plain text */
    aes128_add_round_key (round, encrypt);

    /* Sequence for initial 10 rounds */
    for (round = 1; round < 10; round++)
    {
        aes128_substitute_bytes (encrypt);
        aes128_shift_rows (encrypt);
        aes128_mix_columns (encrypt);
        aes128_add_round_key (round, encrypt);
    }
    /* Final round does not mix columns */
    aes128_substitute_bytes (encrypt);
    aes128_shift_rows (encrypt);
    aes128_add_round_key (round, encrypt);

    memcpy ((void *)cipherText, (void *)aes128_state, sizeof(aes128_state));
}

void aes128_decrypt (uint8_t *cipherText, uint8_t *plainText)
{
    bool decrypt = false;
    uint8_t round = 0u;

    memcpy ((void *)aes128_state, (void *)cipherText, sizeof(aes128_state));

    /* Add the 10th round key for decryption */
    aes128_add_round_key (round, decrypt);

    /* Consecutive rounds of decryption follows this sequence */
    for (round = 1; round < 10; round++)
    {
        aes128_shift_rows (decrypt);
        aes128_substitute_bytes (decrypt);
        aes128_add_round_key (round, decrypt);
        aes128_mix_columns (decrypt);
    }

    /* Last round of decryption follows this sequence */
    aes128_shift_rows (decrypt);
    aes128_substitute_bytes (decrypt);
    aes128_add_round_key (round, decrypt);

    memcpy ((void *)plainText, (void *)aes128_state, sizeof(aes128_state));
}