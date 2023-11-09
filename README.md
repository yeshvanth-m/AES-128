# AES-128
Advanced Encryption Standard 128-bit implementation in Hardware and Software

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

Given below is the diagram that depicts difference between the existing implementation and the new implemenetation
![AES128 Comparison](/Docs/images/AES128_Comparison.png)

This design is made keeping in mind the FPGA implementation and use of AXI GPIO  for simplicity.

Link: https://www.xilinx.com/products/intellectual-property/1-1cqcpdv.html#productspecs

## Design

### Overview
![AES128 Overview](/Docs/images/AES128.jpg)

### Encryption
![AES128 Design](/Docs/images/AES_Block_diagram.png)

1. They keys are generated within 10 clock cycles and are stored in the key memory
2. The plain text is loaded into the SM by making the load_data line high
3. It takes 10 clock cycles to perform enccryption after which the cipher ready line goes high
4. Encrypt / decrypt function can be specified through the control line

## Simulation Results
Vivado was used for the simulation
![AES128 Sim Results](/Docs/images/Sim_Result.png)

## FPGA Implementation
![AES128 Vivado](/Docs/images/AES128_Vivado.png)