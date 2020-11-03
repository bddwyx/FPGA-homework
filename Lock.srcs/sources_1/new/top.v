`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/03 23:32:34
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input clk,
    input clr,
    output [6:0] a_to_g ,
    output [3:0] led_bits,
    input a,
    input b,
    output o
    );
    
    AND myand(
        .a(a),
        .b(b),
        .o(o)
    );
    
    Count_FFFF(
        .clk(clk),
        .clr(clr),
        .a_to_g(a_to_g),
        .led_bits(led_bits)
    );
endmodule
