`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/03 22:42:29
// Design Name: 
// Module Name: Lock
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
module Lock(
    input clk,
    input clr,
    input [3:0] pwdReg ,
    input [3:0] pwdInput ,
    output [6:0] a_to_g ,
    output [3:0] led_bits ,
    
    input displayFSM
    );
    
    reg [15:0] infoBuf;
    
    always@(*) begin
        if(~displayFSM) begin
                infoBuf[3:0] = pwdInput[0];
                infoBuf[7:4] = pwdInput[1];
                infoBuf[11:8] = pwdInput[2];
                infoBuf[15:12] = pwdInput[3];
            end
        else begin
                if(pwdInput == pwdReg) begin
                        infoBuf[3:0] = 4'hD;
                        infoBuf[7:4] = 4'h0;
                        infoBuf[11:8] = 4'hA;
                        infoBuf[15:12] = 4'hA;
                    end
                else begin
                        infoBuf[3:0] = 4'hF;
                        infoBuf[7:4] = 4'hF;
                        infoBuf[11:8] = 4'h0;
                        infoBuf[15:12] = 4'hA;
                    end
            end    
    end
    
    DisplayTubes displayPwd( //Show PassWord
             .clk(clk),
             .clr(clr),
             .dataBuf(infoBuf),
             .a_to_g(a_to_g),
             .led_bits(led_bits)
     );
endmodule