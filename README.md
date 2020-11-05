

# 开源信息

## 链接

​	[github项目主页](https://github.com/bddwyx/FPGA-homework)

## 内容

​	main分支为最终提交作业时的Verilog代码的分支，其余分支按照时间顺序，记录了FPGA项目的整体进展。

## License

​	本项目采用WTFPL开源协议。

# 理论基础

## 状态机

### 有限自动状态机

​	有限自动状态机（FSM）是用于在满足相应触发条件时从一种用户定义的状态切换到另一种状态的计算机程序或时序逻辑电路。在任意时间，FSM只能处于一种状态；当满足特定条件时，它可以从一种状态切换到另一种状态，称为状态机的迁移。

### FSM的设计

​	由于关系不大，此处省略有限状态机的数学模型。从数学模型可以看出，一个完整的有限自动状态机应当包含

* 状态寄存器
* 状态转移逻辑
* 输出逻辑

​	有限自动状态机有两种基本的类型，分别是米勒状态机和摩尔状态机。在米勒状态机中，输出取决于当前状态和当前输入，而在摩尔状态机中，输出仅取决于当前状态。本项目的输出状态与用户是否按下解锁键有关，故应当采用米勒状态机。

​	有限自动状态机也有单进程，双进程与三进程三种设计模式。由于三进程状态机将状态转移逻辑，状态寄存器与输出逻辑分散在了三个always语句块，逻辑清晰且便于后期的修改，故本次设计优先采用三进程的描述方式。

# 顶层设计

## top模块

​	top模块为最终生成比特流所用模块。该模块由两部分组成，分别为输入状态机切换与状态机执行，对应米勒状态机的状态转移逻辑和输出逻辑。状态寄存器写在了FSM模块中，以reg形式存在。状态机共设计了两种状态，分别对应输入显示与解锁。top模块的代码如下。

``` verilog
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
    
    wire displayFSM;	//State transition logic and state register
    DisplayFSM FSM1(
        .unlock(unlockKey)
    );
    assign displayFSM = FSM1.FSM;
    
    Lock lock(	//Output logic
        .clk(clk),
        .clr(clr),
        .pwdInit(pwdReg),
        .pwdInput(pwdInput),
        .a_to_g(a_to_g),
        .a_to_g2(a_to_g2),
        .led_bits(led_bits),
        .led_bits2(led_bits2),
        
        .displayFSM(displayFSM),
        .changeKey(changeKey),
        .resetKey(resetKey)
    );
    
    assign led[0] = changeKey; //Key state display
    assign led[1] = resetKey;  
endmodule
```

## 流程框图

<div style="align: center">
<img src="https://github.com/bddwyx/FPGA-homework/blob/main/images/FPGA.png" width = 30% height = 30% />
</div>

# 模块分析

## 硬件布局

​	本项目采用两组四位共阴极片选数码管，用于显示当前输入与密码是否正确。数码管相关引脚均按照开发板原理图连接至FPGA相应管脚。设置的密码从一个8位拨码开关读取，同时开放8路开关与1路按键作为用户接口，用于密码输入与解锁操作。1路按键实现题目中的复位功能，按下将密码置为0；1路按键实现密码设置，目前功能暂未实现，只有提示灯会做出相应反应。

## 数码管驱动模块

​	首先是单位数码管驱动模块。根据输入情况，模块使能相应片选，并对相应数码管的位选进行使能。具体代码如下。

```verilog
module D0_display( //One bit display
    input [3:0] D0_bits ,
    input [3:0] D0_NUM ,
    output reg [6:0] D0_a_to_g ,
    output [3:0] D0_led_bits ,
    input switchFlag
);
    assign D0_led_bits = D0_bits ; 

    always @(*) begin 
        if(~switchFlag)
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
                 'hA: D0_a_to_g=7'b0000000; //Turn off
                 'hB: D0_a_to_g=7'b0011111;
                 'hC: D0_a_to_g=7'b1001110;
                 'hD: D0_a_to_g=7'b1110110; //'N'
                 'hE: D0_a_to_g=7'b1001111;
                 'hF: D0_a_to_g=7'b1000111;
                 default: D0_a_to_g=7'b1111110;
             endcase
         else D0_a_to_g = 7'b000_0000;
     end
endmodule
```

​	同时构造一个4位数码管驱动，用于自动以16进制显示输入的16位寄存器中的数值。输入中的clk为开发板板载100MHz时钟。

``` verilog
module D0_display( //One bit display
    input [3:0] D0_bits ,
    input [3:0] D0_NUM ,
    output reg [6:0] D0_a_to_g ,
    output [3:0] D0_led_bits ,
    input switchFlag
);
    assign D0_led_bits = D0_bits ; 

    always @(*) begin 
        if(~switchFlag)
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
                 'hA: D0_a_to_g=7'b0000000; //Turn off
                 'hB: D0_a_to_g=7'b0011111;
                 'hC: D0_a_to_g=7'b1001110;
                 'hD: D0_a_to_g=7'b1110110; //'N'
                 'hE: D0_a_to_g=7'b1001111;
                 'hF: D0_a_to_g=7'b1000111;
                 default: D0_a_to_g=7'b1111110;
             endcase
         else D0_a_to_g = 7'b000_0000;
     end
endmodule

module DisplayTubes( //Four bit display
     input clk,
     input clr,
     input [15:0] dataBuf,
     output [6:0] a_to_g,
     output [3:0] led_bits
);
     reg [35:0] ckl_cnt ;
     reg [3:0] t_led_bits ; //bit control
     reg [3:0] dataToShow ;

 always@(posedge clk or posedge clr) begin
     if(~clr)
        ckl_cnt <= 0 ;
     else
        ckl_cnt <= ckl_cnt + 1 ;
     end
     
     reg switchFlag;
 
 always@(*) //取计数变量的高 16 位组成要显示的 1 个 4 位十六进制数
     case(ckl_cnt[15:14]) //取计数变量的较低 2 位(频率高)数值，作为 4 位数码管扫描复位切换频率
         0:begin  switchFlag = 1; t_led_bits = 4'b0001; 
             dataToShow = dataBuf[3:0]; switchFlag = 0; end 
         //数码管 1 有效，且显示数值为最低 4 位
         1:begin  switchFlag = 1; t_led_bits = 4'b0010; 
             dataToShow = dataBuf[7:4]; switchFlag = 0; end 
         //数码管 2 有效，且显示数值为次低 4 位
         2:begin  switchFlag = 1; t_led_bits = 4'b0100; 
             dataToShow = dataBuf[11:8]; switchFlag = 0; end 
         //数码管 3 有效，且显示数值为次高 4 位
         3:begin  switchFlag = 1; t_led_bits = 4'b1000; 
             dataToShow = dataBuf[15:12]; switchFlag = 0; end 
         //数码管 4 有效，且显示数值为最高 4 位
     endcase
 
D0_display myD0_display(
    .D0_bits(t_led_bits),
    .D0_NUM(dataToShow),
    .D0_a_to_g(a_to_g),
    .D0_led_bits(led_bits),
    .switchFlag(switchFlag)
) ; 
 
endmodule
```

## 状态机转移逻辑

​	米勒状态机转移逻辑以unlockKey作为输入，根据unlockKey的不同取值决定当前输出状态。~~这也能写个模块？~~

``` verilog
module DisplayFSM(
        input unlock
    );
    wire FSM;
    //wire pwdState;
    assign FSM = unlock;
endmodule
```

## 解锁模块

​	解锁功能是项目的主要功能，故解锁模块包括了输出状态的绝大部分。输入板载的100MHz时钟信号clk，用于2组4位数码管的扫描刷新。若解锁按键未被按下，则输出用户输入开关的状态；若被按下，则判断输入密码是否与设定密码相同，相同则输出ON，不相同输出OFF。同时按照题目要求，增加了清零的功能，resetKey按下时密码清零。

``` verilog
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
```

# 感想

* ​	FPGA处理并行任务的能力要远远高于对串行任务的处理。项目花费了~~一天时间~~一半时间实现了顶层设计中规划的能够用状态机实现的部分，然而在补充附加功能的时候，所有涉及到跨层传递数据或是时序控制的部分均以失败告终。所以初期的顶层设计非常重要。

* ​	尝试修复数码管的“鬼影”问题，观察到位选与段选的并行性，吸取操作系统中的处理方法，采用互斥锁的思想，通过外层位选控制以wire形式向内层段选传递reg变量构成互斥结构，~~但是修复了个寂寞~~。

  ​	外层部分代码如下：

``` verilog
/**
	FILE NAME : TubeDisplay.v
	LINE : 76
	MODULE : DisplayTubes	*/

reg switchFlag;
always@(*) 
    case(ckl_cnt[15:14]) 
        0:begin  switchFlag = 1; t_led_bits = 4'b0001; 
            dataToShow = dataBuf[3:0]; switchFlag = 0; end 
        1:begin  switchFlag = 1; t_led_bits = 4'b0010; 
            dataToShow = dataBuf[7:4]; switchFlag = 0; end 
        2:begin  switchFlag = 1; t_led_bits = 4'b0100; 
            dataToShow = dataBuf[11:8]; switchFlag = 0; end 
        3:begin  switchFlag = 1; t_led_bits = 4'b1000; 
            dataToShow = dataBuf[15:12]; switchFlag = 0; end 
    endcase
```

​			内层部分代码如下：

``` verilog
/**
	FILE NAME : TubeDisplay.v
	LINE : 31
	MODULE : D0_display	*/

always @(*) begin 
    if(~switchFlag)
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
            'hA: D0_a_to_g=7'b0000000; //Turn off
            'hB: D0_a_to_g=7'b0011111;
            'hC: D0_a_to_g=7'b1001110;
            'hD: D0_a_to_g=7'b1110110; //'N'
            'hE: D0_a_to_g=7'b1001111;
            'hF: D0_a_to_g=7'b1000111;
            default: D0_a_to_g=7'b1111110;
        endcase
    else D0_a_to_g = 7'b000_0000;
end
```
* ​	调试过程中，曾经多次出现密码传递失灵的情况。排查的时候偶然打开了原理图，发现[7:0]只有[0]连接到了后级电路，排查出了某一级传递时寄存器定义reg后面没有写[7:0]。
<img src="https://github.com/bddwyx/FPGA-homework/blob/main/images/FPGA2.png" width = 80% height = 80% align=center />

~~赶作业的体验极为不爽，下次一定要记得提前做大作业。~~