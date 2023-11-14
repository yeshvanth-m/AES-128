# AES-128
Open-source AES-128 (Advanced Encryption Standard 128-bit) implementation in Hardware (Verilog) and Software (C)

## Background
I had planned to benchmark an FPGA (AMD ZU+ MPSoC XCZU1CG), with an AES128 Core IP. I discovered that the IP is a licensed one and is not available for evaluation purposes without a company email. Then I ventured out to find an AES128 core from open-source repositories with little luck and incomplete implementations. Hence, decided to get my hands dirty and build my own AES128 core. Started with a SW implementation to kind of understand how exactly the algorithm works, and then implemented on hardware using Verilog.

# Hardware
## Existing Implementation vs. New Implementation
The existing implementation provided by Xilinx is discussed below:
1. There are dedicated buses for key in, data in, and cipher out
2. There are multiple lines to indicate output statuses 

The new implementation has the following changes
1. Multiplexed data input bus to load both Plain text and Cipher Key
2. Control lines to indicate whether input is plain text or cipher key
3. Key ready and cipher ready output statuses
4. One module can perform both encryption and decryption, indicated via control line

This design is made keeping in mind the FPGA implementation and use of AXI GPIO  for simplicity.

Link: https://www.xilinx.com/products/intellectual-property/1-1cqcpdv.html#productspecs

## Design

### Overview
![AES128 Overview](/Docs/images/AES128.jpg)

- The 128-bit input is split into four 32-bit lanes since the AXI GPIO supports a max. of 32-bit I/O port
- The load_key line is used to load the new cipher_key into the AES-128 module
- The load_data line is used to load the new plain_text or cipher_text for encryption or decryption
- The encrypt_or_decrypt line is used to specify whether to perform encryption or decryption
- The key_ready line indicates that the key generation schedule is complete
- The cipher_ready line indicates that the encryption / decryption operation is complete

### Encryption
![AES128 Design](/Docs/images/AES_Block_diagram.png)

1. They keys are generated within 10 clock cycles and are stored in the key memory
2. The plain text is loaded into the SM by making the load_data line high
3. It takes 10 clock cycles to perform enccryption after which the cipher ready line goes high
4. Encrypt / decrypt function can be specified through the control line

## Simulation Results
![AES128 Sim Results](/Docs/images/Sim_Result.png) <br>
Vivado was used for the simulation

1. The reset_key_i line is held high for one clock cycle to start the key schedule, which is completed in 10 clock cycles
2. Once the key_ready_o line goes high, the plain_text_i is loaded into the AES-128 module
3. The cipher_text is available in the next 10 clock cycles as the cipher_ready line goes high

## FPGA Implementation
- AXI GPIO is used to control the AES module, load the cipher key, plain text and get back the cipher text
- The Zynq U+ MPSoC can interact with the AXI GPIO and time the crypto operations by reading the status signals 

# Software
![AES128 Software](/Docs/images/AES128_SW.jpg)

- The software AES-128 is implemented in C, and can be run on any target
- No math specific libraries are used in this implementation
- This might not be the most optimized implementation
- The CBC: Cipher Block Chaining mode of AES is used as an example for demonstration

# Usage
## Hardware
The Verilog modules are FPGA compatible, meaning they will not give any DRC errors. Its tested on Zynq U+ MPSoC PL, and is expected to work on any other Xilinx FPGA as well, probably the logic usage may vary depending on the type of CLB. Instantiate the  ```aes128``` module in your design the connect the signals as required.

## Software
```gcc``` was used to compile the software and run it on the host and on the target with the appropriate compiler flags set.
To run in on your host, make sure GCC is installed,
Then run <br>```gcc aes128_cbc.c aes128.c -o aes128_cbc.exe``` <br>```./aes128_cbc.exe``` 

Output:
```
Plain Text: Hi there, this is a text to be encrypted.

Number of Blocks: 3

Cipher Text: ░☻[
º♣╥F♣ùJQ▌&╨╟[T!,┤╜δ/Y▲▒%─n◄e╥/≥8UN╧τ±╛

Decrypted Plain Text: Hi there, this is a text to be encrypted.
```

# References
1. Wikipedia: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
2. AES Animation: https://www.cryptool.org/en/cto/aes-animation
3. AES Decryption: https://braincoke.fr/blog/2020/08/the-aes-decryption-algorithm-explained/#invsubbytes