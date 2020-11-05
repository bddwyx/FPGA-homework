`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/04 08:27:38
// Design Name: 
// Module Name: Top
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


module Top(
    input clk,
    input clr,
    input [7:0] pwdReg,
    input [7:0] pwdInput,
    output [6:0] a_to_g ,
    output [6:0] a_to_g2 ,
    output [3:0] led_bits ,
    output [3:0] led_bits2 ,
    
    input unlockKey,
    input changeKey,
    input resetKey,
    output [1:0] led
    );
    
    wire displayFSM;
    DisplayFSM FSM1(
        .unlock(unlockKey)
    );
    assign displayFSM = FSM1.FSM;
    
    Lock lock(
        .clk(clk),
        .clr(clr),
        .pwdReg(pwdReg),
        .pwdInput(pwdInput),
        .a_to_g(a_to_g),
        .a_to_g2(a_to_g2),
        .led_bits(led_bits),
        .led_bits2(led_bits2),
        
        .displayFSM(displayFSM),
        .changeKey(changeKey),
        .resetKey(resetKey)
    );
    
    assign led[0] = changeKey;
    assign led[1] = resetKey;  
endmodule
