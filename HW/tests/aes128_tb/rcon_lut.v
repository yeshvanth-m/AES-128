module rcon (in, out);
    input [7:0] in;
    output reg [7:0] out;

    always @ (in)
    case (in)
        8'h01: out = 8'h1;
        8'h02: out = 8'h2;
        8'h03: out = 8'h4;
        8'h04: out = 8'h8;
        8'h05: out = 8'h10;
        8'h06: out = 8'h20;
        8'h07: out = 8'h40;
        8'h08: out = 8'h80;
        8'h09: out = 8'h1b;
        8'h0A: out = 8'h36;
    endcase
endmodule