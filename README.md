# AES-128
Advanced Encryption Standard 128-bit implementation in Hardware and Software

## Background
I had planned to benchmark an FPGA (AMD ZU+ MPSoC XCZU1CG), with an AES128 Core IP. I discovered that the IP is a licensed one and is not available for evaluation purposes without a company email. Then I ventured out to find an AES128 core from open-source repositories with little luck and incomplete implementations. Hence, decided to get my hands dirty and build my own AES128 core. Started with a SW implementation to kind of understand how exactly the algorithm works, and then implemented on hardware using Verilog.

## Existing Implementation
Link: https://www.xilinx.com/products/intellectual-property/1-1cqcpdv.html#productspecs
