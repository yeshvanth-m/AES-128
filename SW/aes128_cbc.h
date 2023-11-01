#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

void aes128_key_schedule (uint8_t *cipherKey);
void aes128_encrypt (uint8_t *plainText, uint8_t *cipherText);
void aes128_decrypt (uint8_t *cipherText, uint8_t *plainText);