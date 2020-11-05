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
    input [7:0] pwdInit ,
    input [7:0] pwdInput ,
    output [6:0] a_to_g ,
    output [6:0] a_to_g2 ,
    output [3:0] led_bits ,
    output [3:0] led_bits2 ,
    
    input displayFSM,
    input changeKey,
    input resetKey
    );
    
    reg [15:0] infoBuf;
    reg [15:0] infoBuf2;
    
    wire [7:0] Pwd;
    assign Pwd = resetKey ? 8'h0 : pwdInit;
    
    always@(*) begin
        if(~displayFSM) begin
                infoBuf2[3:0] = pwdInput[0];
                infoBuf2[7:4] = pwdInput[1];
                infoBuf2[11:8] = pwdInput[2];
                infoBuf2[15:12] = pwdInput[3];
                infoBuf[3:0] = pwdInput[4];
                infoBuf[7:4] = pwdInput[5];
                infoBuf[11:8] = pwdInput[6];
                infoBuf[15:12] = pwdInput[7];
            end
        else begin
                if(pwdInput == Pwd) begin
                        infoBuf2[3:0] = 4'hD;
                        infoBuf2[7:4] = 4'h0;
                        infoBuf2[11:8] = 4'hA;
                        infoBuf2[15:12] = 4'hA;
                        infoBuf[3:0] = 4'hA;
                        infoBuf[7:4] = 4'hA;
                        infoBuf[11:8] = 4'hA;
                        infoBuf[15:12] = 4'hA;
                    end
                else begin
                        infoBuf2[3:0] = 4'hF;
                        infoBuf2[7:4] = 4'hF;
                        infoBuf2[11:8] = 4'h0;
                        infoBuf2[15:12] = 4'hA;
                        infoBuf[3:0] = 4'hA;
                        infoBuf[7:4] = 4'hA;
                        infoBuf[11:8] = 4'hA;
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
     DisplayTubes displayPwd2( //Show PassWord
          .clk(clk),
          .clr(clr),
          .dataBuf(infoBuf2),
          .a_to_g(a_to_g2),
          .led_bits(led_bits2)
      );

endmodule