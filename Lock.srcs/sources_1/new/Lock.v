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


module D0_display( //ע�Ͳο�ʵ��һ
 input [3:0] D0_bits ,
 input [3:0] D0_NUM ,
 output reg [6:0] D0_a_to_g ,
 output [3:0] D0_led_bits
 );
 assign D0_led_bits = D0_bits ; 
 always @(*) 
 begin 
 case(D0_NUM)
 0:D0_a_to_g=7'b1111110;
 1:D0_a_to_g=7'b0110000;
 2:D0_a_to_g=7'b1101101;
 3:D0_a_to_g=7'b1111001;
 4:D0_a_to_g=7'b0110011;
 5:D0_a_to_g=7'b1011011;
 6:D0_a_to_g=7'b1011111;
 7:D0_a_to_g=7'b1110000;
 8:D0_a_to_g=7'b1111111;
 9:D0_a_to_g=7'b1111011;
 'hA: D0_a_to_g=7'b1110111;
 'hB: D0_a_to_g=7'b0011111;
 'hC: D0_a_to_g=7'b1001110;
 'hD: D0_a_to_g=7'b0111101;
 'hE: D0_a_to_g=7'b1001111;
 'hF: D0_a_to_g=7'b1000111;
 default: D0_a_to_g=7'b1111110;
 endcase
 end
endmodule


module Count_FFFF( //ע�Ͳο�ʵ���
 input clk,
 input clr,
 output [6:0] a_to_g ,
 output [3:0] led_bits
 );
 reg [3:0] num ;
 reg [35:0] ckl_cnt ;
 reg [3:0] t_led_bits ; //�м�������洢����ܸ����л�λ����Ϣ

 always@(posedge clk or posedge clr)
 begin
 if(~clr)
 ckl_cnt <= 0 ;
 else
 ckl_cnt <= ckl_cnt + 1 ;
 end
 
 always@(*) //ȡ���������ĸ� 16 λ���Ҫ��ʾ�� 1 �� 4 λʮ��������
 case(ckl_cnt[15:14]) //ȡ���������Ľϵ� 2 λ(Ƶ�ʸ�)��ֵ����Ϊ 4 λ�����ɨ�踴λ�л�Ƶ��
 0:begin num = ckl_cnt[23:20];t_led_bits = 4'b0001;end //����� 1 ��Ч������ʾ��ֵΪ��� 4 λ
 1:begin num = ckl_cnt[27:24];t_led_bits = 4'b0010;end //����� 2 ��Ч������ʾ��ֵΪ�ε� 4 λ
 2:begin num = ckl_cnt[31:28];t_led_bits = 4'b0100;end //����� 3 ��Ч������ʾ��ֵΪ�θ� 4 λ
 3:begin num = ckl_cnt[35:32];t_led_bits = 4'b1000;end //����� 4 ��Ч������ʾ��ֵΪ��� 4 λ
 endcase
 
 D0_display myD0_display(.D0_bits(t_led_bits),.D0_NUM(num),.D0_a_to_g(a_to_g),.D0_led_bits(led_bits)) ; 
 
endmodule