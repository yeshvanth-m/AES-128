/********************************************************************************
* @file     aes128_cbc.c                                                        *
* @brief    AES128 CBC Mode C implementation File                               *
* @author   Yeshvanth M  <yeshvanthmuniraj@gmail.com>                           *
* @date     1-Nov-2023                                                          *
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

#include "aes128_cbc.h"

uint8_t aes128_cbc_cipherKey[16u] = 
{
    0x2B, 0x28, 0xAB, 0x09,
    0x7E, 0xAE, 0xF7, 0xCF,
    0x15, 0xD2, 0x15, 0x4F,
    0x16, 0xA6, 0x88, 0x3C
};

uint8_t aes128_cbc_iv[16u] =
{
    0xAB, 0xF1, 0x14, 0x56,
    0x90, 0x12, 0x57, 0x40,
    0x75, 0x36, 0x09, 0x73,
    0x64, 0x95, 0xCB, 0xDF
};

char plainText[256u] = "Hi There, this is a sample text to encrypt.\0";
char cipherText[256u];

uint8_t aes128_cbc_plainText[16u];
uint8_t aes128_cbc_cipherText[16u];
uint8_t num_blocks, num_padding;

int main()
{
    puts(plainText);

    int byte = 0;
    do
    {
        //printf("%x ", plainText[byte]);
    } while(plainText[byte++] != '\0');

    num_blocks = (byte / 16u) + ((byte % 16u) > 0u);
    num_padding = byte % 16u;

    printf("Size: %d\n", num_blocks);

    /* Generate the keys through key schedule */
    aes128_key_schedule (aes128_cbc_cipherKey);

    /* Add the IV to the plain text */

    for (int i = 0; i < num_blocks; i++)
    {
        /* Copy the plain text for encryption */
        memcpy ((void *) aes128_cbc_plainText, (void *) &plainText[16 * i], sizeof(aes128_cbc_plainText));

        if (i == 0)
        {
            for (int j = 0; j < 16u; j++)
            {
                /* Add the IV in the first block */
                aes128_cbc_plainText[j] ^= aes128_cbc_iv[j];
            }
        }
        else
        {
            for (int j = 0; j < 16u; j++)
            {
                /* Add the cipher text for previously obtained block */
                aes128_cbc_plainText[j] ^= aes128_cbc_cipherText[j];
            }
        }

        /* Encrypt the data */
        aes128_encrypt (aes128_cbc_plainText, aes128_cbc_cipherText);

        memcpy ((void *) &cipherText[16 * i], (void *) aes128_cbc_cipherText, sizeof(aes128_cbc_cipherText));
    }

    puts(cipherText);

    for (int i = 0; i < num_blocks; i++)
    {
        /* Copy over the cipher text */
        memcpy ((void *) aes128_cbc_cipherText, (void *) &cipherText[16 * i], sizeof(aes128_cbc_cipherText));

        /* Decrypt the data */
        aes128_decrypt (aes128_cbc_cipherText, aes128_cbc_plainText);

        if (i == 0)
        {
            for (int j = 0; j < 16u; j++)
            {
                /* Add the IV in the first block */
                aes128_cbc_plainText[j] ^= aes128_cbc_iv[j];
            }
        }
        else
        {
            for (int j = 0; j < 16u; j++)
            {
                /* Copy over the cipher text */
                memcpy ((void *) aes128_cbc_cipherText, (void *) &cipherText[16 * (i - 1u)], sizeof(aes128_cbc_cipherText));
                /* Add the cipher text for previously obtained block */
                aes128_cbc_plainText[j] ^= aes128_cbc_cipherText[j];
            }
        }

        memcpy ((void *) &plainText[16 * i], (void *) aes128_cbc_plainText, sizeof(aes128_cbc_plainText));
    }

    puts(plainText);
}