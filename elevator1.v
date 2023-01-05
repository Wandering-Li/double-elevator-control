
module elevator(
input switch,//内呼显示切换输入
input [6:1]insideinput,//电梯内呼输入
input  [5:1]outsideinup,//外呼上行
input  [6:2]outsideindown,//外呼下行
input clk,
output reg [6:1]insideoutput,//电梯内呼寄存器输出
output reg [5:1]outsideoutup,//外呼上行寄存器输出总
output reg [6:2]outsideoutdown,//外呼下行寄存器输出总


output reg[8:0] seg_led_1,//在小脚丫上控制一个数码管需要9个信号 MSB~LSB=DIG、DP、G、F、E、D、C、B、A
output reg[8:0] seg_led_2,

output reg aup,
output reg adown,
output reg bup,
output reg bdown
);
reg [6:1]insidea;//内呼寄存器
reg [6:1]insideb;


reg aupdown=0;//a电梯上行=1，下行=0
reg bupdown=0;//b电梯上行=1，下行=0
 reg aoutsideup[5:1];//外呼上行寄存器输出a
 reg aoutsidedown[6:2];//外呼下行寄存器输出b
 reg boutsideup[5:1];//外呼上行寄存器输出b
 reg boutsidedown[6:2];//外呼下行寄存器输出b
reg nowa=1 ;//a电梯当前楼层
reg nowb=1 ;//b电梯当前楼层

reg [2:0]ahigh;//a内呼最高层
reg [2:0]alow;
reg [2:0]bhigh;
reg [2:0]blow;
reg [2:0]aahigh;//a内呼最高层
reg [2:0]aalow;
reg [2:0]bbhigh;
reg [2:0]bblow;
reg tempupdown;
reg [2:0]temp;
reg [3:0]adis;//a电梯距离终点距离
reg [3:0]bdis;
reg atempupdown;//上=1，下=0
reg btempupdown;//上=1，下=0
reg [3:0]atemphigh;
reg [3:0]atemplow;//三八码楼层外呼
reg [3:0]btemphigh;
reg [3:0]btemplow;//三八码楼层外呼
reg [3:0]aatemphigh;
reg [3:0]aatemplow;//三八码楼层外呼
reg [3:0]bbtemphigh;
reg [3:0]bbtemplow;//三八码楼层外呼
reg  [2:0]adest=3'b000;//a目的地
reg  [2:0]bdest=3'b000;//b目的地
reg afreebusy=0;//闲=0、忙=1
reg bfreebusy=0;//闲=0、忙=1
reg abin=0;//内呼切换a=0;b=1
reg aorb=0;//外呼指配a=0;b=1
reg ha=0;
integer i ;
//按键按下变0，LED变1变亮



//内呼输入输出模块（默认同一时刻只有一个按键按下）
always@( outsideinup or  outsideindown )//aorb判断
begin

//先找出外呼的楼层和方向
for(i=6;i>=2;i=i-1)//下行
begin
if(outsideindown[i]==0)
begin
tempupdown=0;
temp=i;

end

else 
begin
ha=0;
end
end
for(i=1;i<=5;i=i+1)//上行
begin
if(outsideinup[i]==0)
begin
temp=i;
tempupdown=1;

end
else
begin
ha=0;
end


end

//距离判断 a 
//1 4
if(((aupdown==1'b0) &&( tempupdown==1'b0) && (nowa>=temp))||((aupdown==1'b0) &&( temp<adest)))//先判断是否在同方向路径射线上
begin
adis=nowa-temp;
end
else if(((aupdown==1'b1) && (tempupdown==1'b1) &&( nowa<=temp) )||((aupdown==1'b1) && (temp>adest)))
begin
adis=temp-nowa;
end
//23
else if(((aupdown==1'b0) && (temp>nowa))|| ((aupdown==1'b0 )&& (tempupdown==1'b1 )&& (temp>=adest)))
begin
adis=nowa-adest+temp-adest;
end
else if(((aupdown==1'b1) && (temp<nowa))|| ((aupdown==1'b1) && (tempupdown==1'b0) && (temp<=adest)))
begin
adis=adest-nowa+adest-temp;
end
else 
begin
temp=1'b0;

end

//距离判断 b
//1 4
if(((bupdown==1'b0) &&( tempupdown==1'b0) && (nowb>=temp))||((bupdown==1'b0) &&( temp<bdest)))//先判断是否在同方向路径射线上
begin
bdis=nowb-temp;
end
else if(((bupdown==1'b1) && (tempupdown==1'b1) &&( nowb<=temp) )||((bupdown==1'b1) && (temp>bdest)))
begin
bdis=temp-nowb;
end
//23
else if(((bupdown==1'b0) && (temp>nowb))|| ((bupdown==1'b0 )&& (tempupdown==1'b1 )&& (temp>=bdest)))
begin
bdis=nowb-bdest+temp-bdest;
end
else if(((bupdown==1'b1) && (temp<nowb))|| ((bupdown==1'b1) && (tempupdown==1'b0) && (temp<=bdest)))
begin
bdis=bdest-nowb+bdest-temp;
end
else
temp=1'b0;

if(adis<=bdis)
aorb=1'b0;
else
aorb=1'b1;



end





always@(insidea or insideb or switch)
begin
if(abin==0)
insideoutput=insidea;
if(abin==1)
insideoutput=insideb;
end
always@(posedge switch)//内呼显示输出分配
begin
abin=~abin;
end











//aaaaaaaaaaaaaaaaaaaaaaaaaaaa


always@( outsideinup  or  outsideindown or insideinput or nowa )//a外内呼后终点判断(指令分流之后)（假设按键按下过程中已经完成分配）
begin
afreebusy=1;

if((~(&insideinput))&&abin==0)//电梯内呼输入分配a
begin
case(insideinput)
6'b111110:insidea[1]=1;
6'b111101:insidea[2]=1;
6'b111011:insidea[3]=1;
6'b110111:insidea[4]=1;
6'b101111:insidea[5]=1;
6'b011111:insidea[5]=1;
default:
begin
insidea[1]=0;
insidea[2]=0;
insidea[3]=0;
insidea[4]=0;
insidea[5]=0;
insidea[6]=0;

end

endcase
end
else
ha=0;

if((~(&insideinput))&&abin==1)//电梯内呼输入分配b
begin
case(insideinput)
6'b111110:insideb[1]=1;
6'b111101:insideb[2]=1;
6'b111011:insideb[3]=1;
6'b110111:insideb[4]=1;
6'b101111:insideb[5]=1;
6'b011111:insideb[5]=1;
default:
begin
insideb[1]=0;
insideb[2]=0;
insideb[3]=0;
insideb[4]=0;
insideb[5]=0;
insideb[6]=0;

end

endcase
end
else
ha=0;




if( ~(&outsideinup))
begin
#30
if(aorb==0)
begin
case(outsideinup)
5'b11110:aoutsideup[1]=1;
5'b11101:aoutsideup[2]=1;
5'b11011:aoutsideup[3]=1;
5'b10111:aoutsideup[4]=1;
5'b01111:aoutsideup[5]=1;
default:
begin
aoutsideup[1]=0;
aoutsideup[2]=0;
aoutsideup[3]=0;
aoutsideup[4]=0;
aoutsideup[5]=0;
end
endcase
end

end


if(~( &outsideindown))
begin
#30
if(aorb==0)
begin
case(outsideindown)
5'b11110:aoutsidedown[2]=1;
5'b11101:aoutsidedown[3]=1;
5'b11011:aoutsidedown[4]=1;
5'b10111:aoutsidedown[5]=1;
5'b01111:aoutsidedown[6]=1;

default:
begin
aoutsidedown[2]=0;
aoutsidedown[3]=0;
aoutsidedown[4]=0;
aoutsidedown[5]=0;
aoutsidedown[6]=0;


end
endcase
end
end











if(&insideinput==1 )//内呼终点判断
begin
#20 afreebusy=1;
for(i=1;i<=6;i=i+1)
begin
if(insidea[i]==1)
begin
ahigh=i;
end
end
for(i=6;i>=1;i=i-1)
begin
if(insidea[i]==1)
begin
alow=i;
end
end
if((adest>=alow && aupdown==0))//下行延伸
begin
adest=alow;
end
else
begin
ha=0;
end
if((adest<=ahigh && aupdown==1))//上行延伸
begin
adest=ahigh;
end
else
begin
ha=0;
end
end
else
begin
for(i=6;i>=2;i=i-1)//下行
begin
if(aoutsidedown[i]==1)
begin//取外呼下行最低
atemplow=i;
end
end
for(i=5;i>=1;i=i-1)//上行
begin
if(aoutsideup[i]==1 && i<atemplow)//取外呼上行最低
begin
atemplow=i;
end

end


for(i=2;i<=6;i=i+1)//下行
begin
if(aoutsidedown[i]==1)
begin//取外呼下行最搞
atemphigh=i;
end
end
for(i=1;i<=5;i=i+1)//上行
begin
if(aoutsideup[i]==1 && i>atemphigh)//取外呼上行最低
begin
atemphigh=i;
end
end


if(adest>=atemplow && aupdown==0)//下行延伸
adest=atemplow;
else
ha=0;

if(adest<=atemphigh && aupdown==1)//上行延伸
adest=atemphigh;
else
ha=0;
end
if(adest==nowa)//反折a
begin
#2000 aupdown=~aupdown;

insidea[nowa]=0;
if(nowa>=1 && nowa<=5)
aoutsideup[nowa]=0;
else ha=0;
if(nowa>=2 && nowa<=6)
aoutsidedown[nowa]=0;
else ha=0;

for(i=6;i>=2;i=i-1)//下行
begin
if(aoutsidedown[i]==1)
begin//取外呼下行最低
aatemplow=i;
end
else
ha=0;
end
for(i=5;i>=1;i=i-1)//上行
begin
if(aoutsideup[i]==1 && i<aatemplow)//取外呼上行最低
begin
aatemplow=i;
end

else
ha=0;

end


for(i=2;i<=6;i=i+1)//下行
begin
if(aoutsidedown[i]==1)
begin//取外呼下行最低
aatemphigh=i;
end
else
ha=0;
end
for(i=1;i<=5;i=i+1)//上行
begin
if(aoutsideup[i]==1 && i>aatemphigh)//取外呼上行最低
begin
aatemphigh=i;
end
else
ha=0;
end


if(adest>=aatemplow && aupdown==0)//下行延伸
adest=aatemplow;
else
ha=0;

if(adest<=aatemphigh && aupdown==1)//上行延伸
adest=aatemphigh;
else
ha=0;



#20
for(i=1;i<=6;i=i+1)
if(insidea[i]==1)
begin
aahigh=i;
end
for(i=6;i>=1;i=i-1)
if(insidea[i]==1)
begin
aalow=i;
end

if((adest>=aalow && aupdown==0))//下行延伸
adest=aalow;
else
ha=0;
if((adest<=aahigh && aupdown==1))//上行延伸
adest=aahigh;
else
ha=0;

if (adest==nowa)
afreebusy=0;
else
ha=0;
end


if(afreebusy)//电梯运行a （在关门时才判断是否转向！！！
begin
if(aupdown==0 && nowa!=adest)//A下行
begin
if(nowa>=2 && nowa<=6)
begin
if (insidea[nowa]==1 || aoutsidedown[nowa]==1)
begin
insidea[nowa]=0;
aoutsidedown[nowa]=0;
#2000 nowa=nowa-1;
end
end
else if(nowa==1 && insidea[nowa]==1)
begin
insidea[nowa]=0;
#2000 nowa=nowa-1;
end
else
ha=0;

end
else if(nowa==adest)
ha=0;

else
begin
#500 nowa=nowa-1;
end

if(aupdown==1  && nowa!=adest)//A上行
begin
if(nowa<=5 && nowa>=1)
begin
if (insidea[nowa]==1 || aoutsideup[nowa]==1)
begin
insidea[nowa]=0;
aoutsideup[nowa]=0;
#2000 nowa=nowa+1;
end
end
else if(nowa==6 && insidea[nowa]==1)
begin
insidea[nowa]=0;
#2000 nowa=nowa+1;
end
else
ha=0;
end
else
begin
#500 nowa=nowa+1;
end
end


end


//bbbbbbbbbbbbbbbbbbbbbbbbbbbbb

always@( outsideinup  or  outsideindown or insideinput or nowb)//b外内呼后终点判断(指令分流之后)（假设按键按下过程中已经完成分配）
begin
bfreebusy=1;



if( outsideinup)
begin
if(aorb==1)
begin
case(outsideinup)

5'b00001:boutsideup[1]=1;
5'b00010:boutsideup[2]=1;
5'b00100:boutsideup[3]=1;
5'b01000:boutsideup[4]=1;
5'b10000:boutsideup[5]=1;
default:
begin


boutsideup[1]=0;
boutsideup[2]=0;
boutsideup[3]=0;
boutsideup[4]=0;
boutsideup[5]=0;




end

endcase

end
outsideoutup[1]<=((aoutsideup[1] )|| (boutsideup[1]));
outsideoutup[2]<=((aoutsideup[2]) || (boutsideup[2]));
outsideoutup[3]<=((aoutsideup[3]) || (boutsideup[3]));
outsideoutup[4]<=((aoutsideup[4] )|| (boutsideup[4]));
outsideoutup[5]<=((aoutsideup[5] )|| (boutsideup[5]));
end





if( outsideindown)
begin
if(aorb==1)
begin
case(outsideindown)

5'b00001:boutsidedown[2]=1;
5'b00010:boutsidedown[3]=1;
5'b00100:boutsidedown[4]=1;
5'b01000:boutsidedown[5]=1;
5'b10000:boutsidedown[6]=1;

default:
begin
boutsidedown[2]=0;
boutsidedown[3]=0;
boutsidedown[4]=0;
boutsidedown[5]=0;
boutsidedown[6]=0;



end




endcase
end
outsideoutdown[2]=(aoutsidedown[2] || boutsidedown[2]);
outsideoutdown[3]=(aoutsidedown[3] || boutsidedown[3]);
outsideoutdown[4]=(aoutsidedown[4] || boutsidedown[4]);
outsideoutdown[5]=(aoutsidedown[5] || boutsidedown[5]);
outsideoutdown[6]=(aoutsidedown[6] || boutsidedown[6]);

end








if(&insideinput==1 )//内呼终点判断
begin
#20
bfreebusy=1;
for(i=1;i<=6;i=i+1)
if(insideb[i]==1)
begin
bhigh=i;
end
for(i=6;i>=1;i=i-1)
if(insideb[i]==1)
begin
blow=i;
end

if((bdest>=blow && bupdown==0))//下行延伸
bdest=blow;
else
ha=0;
if((bdest<=bhigh && bupdown==1))//上行延伸
bdest=bhigh;
else
ha=0;
end

else
begin
for(i=6;i>=2;i=i-1)//下行
begin
if(boutsidedown[i]==1)
begin//取外呼下行最低
btemplow=i;
end
end
for(i=5;i>=1;i=i-1)//上行
begin
if(boutsideup[i]==1 && i<btemplow)//取外呼上行最低
begin
btemplow=i;
end

end


for(i=2;i<=6;i=i+1)//下行
begin
if(boutsidedown[i]==1)
begin//取外呼下行最低
btemphigh=i;
end
end
for(i=1;i<=5;i=i+1)//上行
begin
if(boutsideup[i]==1 && i>btemphigh)//取外呼上行最低
begin
btemphigh=i;
end
end


if(bdest>=btemplow && bupdown==0)//下行延伸
bdest=btemplow;
else
ha=0;

if(bdest<=btemphigh && bupdown==1)//上行延伸
bdest=btemphigh;
else
ha=0;
end


if(bdest==nowb)//反折b
begin
#2000 bupdown=~bupdown;

insideb[nowb]=0;
if(nowb>=1 && nowb<=5)
boutsideup[nowb]=0;
else ha=0;
if(nowb>=2 && nowb<=6)
boutsidedown[nowb]=0;
else ha=0;

for(i=6;i>=2;i=i-1)//下行
begin
if(boutsidedown[i]==1)
begin//取外呼下行最低
bbtemplow=i;
end
end
for(i=5;i>=1;i=i-1)//上行
begin
if(boutsideup[i]==1 && i<bbtemplow)//取外呼上行最低
begin
bbtemplow=i;
end

end


for(i=2;i<=6;i=i+1)//下行
begin
if(boutsidedown[i]==1)
begin//取外呼下行最低
bbtemphigh=i;
end
end
for(i=1;i<=5;i=i+1)//上行
begin
if(boutsideup[i]==1 && i>bbtemphigh)//取外呼上行最低
begin
bbtemphigh=i;
end
end


if(bdest>=bbtemplow && bupdown==0)//下行延伸
bdest=bbtemplow;
else
ha=0;

if(bdest<=bbtemphigh && bupdown==1)//上行延伸
bdest=bbtemphigh;
else
ha=0;



#20
for(i=1;i<=6;i=i+1)
if(insideb[i]==1)
begin
bbhigh=i;
end
for(i=6;i>=1;i=i-1)
if(insideb[i]==1)
begin
bblow=i;
end

if((bdest>=bblow && bupdown==0))//下行延伸
bdest=bblow;
else
ha=0;
if((bdest<=bbhigh && bupdown==1))//上行延伸
bdest=bbhigh;
else
ha=0;

if (bdest==nowb)
bfreebusy=0;
else
ha=0;
end


if(bfreebusy)//电梯运行b （在关门时才判断是否转向！！！
begin
if(bupdown==0 && nowb!=bdest)//b下行
begin
if(nowb>=2 && nowb<=6)
begin
if (insideb[nowb]==1 || boutsidedown[nowb]==1)
begin
insideb[nowb]=0;
boutsidedown[nowb]=0;
#2000 nowb=nowb-1;
end
end
else if(nowb==1 && insideb[nowb]==1)
begin
insideb[nowb]=0;
#2000 nowb=nowb-1;
end
else
ha=0;


end
else if(nowb==bdest)
ha=0;

else
begin
#500 nowb=nowb-1;
end

if(bupdown==1  && nowb!=bdest)//b上行
begin
if(nowb<=5 && nowb>=1)
begin
if (insideb[nowb]==1 || boutsideup[nowb]==1)
begin
insideb[nowb]=0;
boutsideup[nowb]=0;
#2000 nowb=nowb+1;
end
end
else if(nowb==6 && insideb[nowb]==1)
begin
insideb[nowb]=0;
#2000 nowb=nowb+1;
end
else
ha=0;
end
else
begin
#500 nowb=nowb+1;
end
end

end





always@(posedge clk)//数码管显示模块
begin
case(nowa)


3'd1:seg_led_1=9'h06; 
3'd2:seg_led_1=9'h5b; 
3'd3:seg_led_1=9'h4f;  
3'd4:seg_led_1=9'h66; 
3'd5:seg_led_1=9'h6d; 
3'd6:seg_led_1=9'h7d; 


default:
seg_led_1=9'h3f; 


endcase
end



always@(posedge clk)//数码管显示模块
begin
case(nowb)


3'd1:seg_led_2=9'h06; 
3'd2:seg_led_2=9'h5b; 
3'd3:seg_led_2=9'h4f;  
3'd4:seg_led_2=9'h66; 
3'd5:seg_led_2=9'h6d; 
3'd6:seg_led_2=9'h7d; 


default:
seg_led_2=9'h5b; 


endcase
end

always@(posedge clk)//上行下行显示模块
begin
case({afreebusy,aupdown})
2'b00:
begin
aup=0;adown=0;
end

2'b01:
begin
aup=0;adown=0;
end

2'b10:
begin
aup=0;adown=1;
end

2'b11:
begin
aup=1;adown=0;
end

endcase


case({bfreebusy,bupdown})
2'b00:
begin
bup=0;bdown=0;
end

2'b01:
begin
bup=0;bdown=0;
end

2'b10:
begin
bup=0;bdown=1;
end

2'b11:
begin
bup=1;bdown=0;
end

endcase

end

endmodule