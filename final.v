module mux2(z,x,y,sel);  //32bit
output reg[31:0] z;
input [31:0] x,y;
input sel;
always @ ( x or y or sel)
begin
if(sel==0) z <=x;
else if(sel==1) z <=y;
else z<=1'bz;
end
endmodule

module mux215(z,x,y,sel);    //15bit
output reg[14:0] z;
input [14:0] x,y;
input sel;
always @ ( x or y or sel)
begin
if(sel==0) z <=x;
else if(sel==1) z <=y;
else z<=1'bz;
end
endmodule

module inctl(op,out);
input [5:0] op ;
output reg [11:0]  out;
always @(op)
begin
if     (op==6'b000000) out<= 12'b1001_0000_0001; //add
else if(op==6'b101011) out<= 12'b0110_0000_0000; //sw
else if(op==6'b100011) out<= 12'b1100_0011_0000; //lw
else if(op==6'b000000) out<= 12'b1001_0000_0001; //sll
else if(op==6'b000000) out<= 12'b1001_0000_0001; //and
else if(op==6'b000000) out<= 12'b1001_0000_0001; //or
else if(op==6'b000100) out<= 12'b0000_1000_1000; //beq
else if(op==6'b000010) out<= 12'b0000_0000_0100; //j
else if(op==6'b000011) out<= 12'b1000_0100_0110; //jal
else if(op==6'b000000) out<= 12'b1001_0000_0001; //jr
else if(op==6'b001000) out<= 12'b1100_0000_0000; //addi
else if(op==6'b001101) out<= 12'b1101_1000_0000; //ori    aluop=11
else if(op==6'b000000) out<= 12'b1001_0000_0001; //slt
else out<=12'b0101_1111_1111;  //impossible 
end
endmodule

module ctl(op,regdst,jump,branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite);
input [5:0] op ;
output reg jump,branch,memread,memwrite,alusrc,regwrite ;
output reg [1:0] aluop;
output reg [1:0] memtoreg;
output reg [1:0] regdst;
wire [11:0]out ;
inctl x (op,out);
always @(out)
begin
regdst     <= (out[1:0]) ;
jump       <= (out[2:2]) ;
branch     <= (out[3:3]) ;
memread    <= (out[4:4]) ;
memtoreg   <= (out[6:5]) ;
aluop      <= (out[8:7]) ;
memwrite   <= (out[9:9]) ;
alusrc     <= (out[10:10]) ;
regwrite   <= (out[11:11]) ;
end
endmodule 

module tb_ctl();
reg[5:0] op ;
wire [1:0] aluop;
wire [1:0] memtoreg;
wire [1:0] regdst;
ctl c2 (op,regdst,jump,branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite);
initial 
begin 
op<=6'b000011;
$monitor("%b %b %b %b %b %b %b  %b  %b %b" ,op,regdst,jump,branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite);
end
endmodule

module aluctrl(func,aluop,sel,jr);
output reg [2:0] sel ;
output reg jr;
input  [5:0] func ;
input  [1:0] aluop ;
always @ (func or aluop)
begin
if      (aluop==2'b00) begin sel<=3'b000; jr<=1'b0; end //add
else if (aluop==2'b01) begin sel<=3'b001; jr<=1'b0; end//sub
else if (aluop==2'b11) begin sel<=3'b010; jr<=1'b0; end//or 
else if (aluop==2'b10) 
begin
if      (func==6'b100000) begin sel<=3'b000; jr<=1'b0; end//add
else if (func==6'b100010) begin sel<=3'b001; jr<=1'b0; end//sub
else if (func==6'b100100) begin sel<=3'b011; jr<=1'b0; end//and
else if (func==6'b100101) begin sel<=3'b010; jr<=1'b0; end//or
else if (func==6'b101010) begin sel<=3'b100; jr<=1'b0; end//slt
else if (func==6'b000000) begin sel<=3'b111; jr<=1'b0; end//sl1
else if (func==6'b001000) begin jr<=1'b1; sel <= 3'b110; end //jr
else begin sel <= 3'b110; jr<=1'b0; end//impossible
end
else begin sel <= 3'b110; jr<=1'b0; end //impossible
end
endmodule

module tb_aluctrl();
reg  [5:0] func ;
reg  [1:0] aluop ;
wire [2:0] sel;
aluctrl c3 (func,aluop,sel,jr);
initial 
begin 
aluop<=2'b10;
func<=6'b000000;
$monitor("%b %b " ,jr,sel);
end
endmodule

module alu(shamt,a,b,sel,aluout,zero);
input [2:0] sel;
input [31:0] a,b;
input [4:0] shamt;
output reg [31:0] aluout;
output zero;
assign zero =(aluout==0);
always @(sel or a or b or shamt )
begin
case(sel)
3'b000 : aluout <= a+b ;
3'b001 : aluout <= a-b ;
3'b011 : aluout <= a&b;
3'b010 : aluout <= a|b;
3'b100 : aluout <= (a<b)?1:0;
3'b111 : aluout <= b << shamt ;
default :   aluout<=0;
endcase
end
endmodule

module tb_alu();
reg [4:0] shamt;
reg [3:0] sel;
reg [31:0] a,b;
wire [31:0] aluout;
alu a1 (shamt,a,b,sel,aluout,zero);
initial 
begin 
sel<=3'b000;
a<=32'd0;
b<=32'd0;
$monitor("%b " ,aluout);
end
endmodule 

module mux3(z,x,y,w,sel);
output reg [31:0] z;
input  [31:0] x,y,w;
input [1:0] sel ;
always @ ( x or y or w or sel)
begin
if(sel==2'b00) z <=x;
else if(sel==2'b01) z<=y;
else if(sel==2'b10) z <=w;
else z<=32'd0;
end
endmodule

module mux35(z,x,y,w,sel);  //5bit
output reg [4:0] z;
input  [4:0] x,y,w;
input [1:0] sel ;
always @ ( x or y or w or sel)
begin
if(sel==2'b00) z <=x;
else if(sel==2'b01) z<=y;
else if(sel==2'b10) z <=w;
else z<=5'd0;
end
endmodule

module signext(in,out);
input [15:0] in;
output reg [31:0] out ;
always @(in)
begin
if (in[15:15]==1)   out <={{16{1'b1}},in[15:0]};
else if (in[15:15]==0)   out <=in[15:0];
else out <=32'bz;
end
endmodule

module tb_signext();
reg [15:0] in;
wire[31:0] out ;
signext s1 (in,out);
initial 
begin 
in <= 16'b1101_1111_0000_1111 ;
$monitor("%b " ,out);
end
endmodule

module regfile(read1,read2,writereg,writedata,regwrite,data1,data2,clk);
input [4:0] read1,read2,writereg;
input [31:0] writedata ;
input regwrite , clk;
output[31:0] data1,data2;
reg [31:0] rf[0:31];
assign data1=rf[read1];
assign data2=rf[read2];
always @ (posedge clk)
begin
rf[0]<=32'd0;
if (regwrite) rf[writereg] <= writedata ;
end
endmodule

module dmem(adress,memwrite,memread,writedata,readdata,clk);
input [12:0] adress ; 
input [31:0] writedata ;
input memwrite,memread,clk ;
output reg [31:0] readdata ;
reg [31:0] d [0:8191];
always @ (posedge clk)
begin
if (memread)
begin
readdata   <= d[adress];
end
if (memwrite)
begin
d[adress]   <= writedata;
end
end
endmodule 

module mips (clk,ir,pc,w1,lw,enablerf);
output reg lw;
input clk , enablerf ;
input  [31:0] ir ;
input [14:0] w1 ;
output [14:0] pc;
wire [14:0] w2 ,w3,w4,w6,w7,w9,w10 ;
wire [15:0] w16,w12;
wire [31:0] w11, w5 , w13, data2, aluout,writedatarf,w15,readdata;
wire [5:0] op ,w14;
wire branch , zero  ;
wire [4:0] r1 , r2 , r3 , shamt,writereg ;
wire [1:0] regdst,memtoreg,aluop ;
wire [2:0] sel;
wire [12:0] adress;
assign w16=w1+4;
assign w2 ={w16[14:0]};
assign w4=ir[12:0] << 2;
mux215 m1 (w10,w3,w4,jump); //15bit
assign w7 = w2 +w6 ;
assign w8 = branch & zero;
assign w9 = {w11[14:0]};
mux215 m2 (w3,w2,w7,w8); //15bit
mux215 m3 (pc,w10,w9,jr); //15bit
assign op = {ir[31:26]};
ctl a1 (op,regdst,jump,branch,memread,memtoreg,aluop,memwrite,alusrc,regwrite);
assign r1 = {ir[25:21]};
assign r2 = {ir[20:16]};
assign r3 = {ir[15:11]};
mux35 m4 (writereg,r2,r3,5'd31,regdst); //5bit
assign njr=~jr;
assign regwriterf= njr &regwrite;
regfile a2 (r1,r2,writereg,writedatarf,regwriterf,w11,data2,enablerf);
assign w12= {ir[15:0]};
signext a3 (w12,w5);
assign w6 = w5[12:0] <<2;
mux2 m5 (w13,data2,w5,alusrc);//32bit
assign w14 = {ir[5:0]};
aluctrl a4 (w14,aluop,sel,jr);
assign shamt = {ir[10:6]};
alu a5(shamt,w11,w13,sel,aluout,zero);
assign adress = {aluout[14:2]};
dmem a6(adress,memwrite,memread,data2,readdata,clk);
assign w15 = {{16{1'b0}},{w16[15:0]}};
mux3 m6(writedatarf,aluout,readdata,w15,memtoreg); //32bit
always @(posedge clk) 
begin
if(op==6'b100011) lw<=1;
else lw<=0;
end
endmodule 

module tb_mips();
reg clk , enablerf;
reg[31:0] ir;
reg[31:0] imem [0:8191];
reg [14:0] w1 ;
wire [14:0] pc;
integer x, y;
mips cpu1 (clk,ir,pc,w1,lw,enablerf);
initial 
begin 
clk=0;
enablerf=0;
x=0;
y=0;
w1=15'd0;
$readmemb("G:\dmem.txt",imem);
ir= imem[0];
$monitor("%b %d %d",ir,pc,w1);
end
always 
begin
if(x==0) #31.25 clk<=~clk;
if(x==1) #31.25 clk<=0;
end
always @(posedge clk)
 begin
if(y==0)
begin
w1=15'd0;
end 
if(y==1) w1=pc;
if(imem[w1>>2]===32'hxxxxxxxx) x=1;
if(x==0)
begin
if(y==1)ir =imem[w1>>2]; 
end
y=1;
end
always @(clk)
begin 
if(lw)
begin
enablerf=1;
#10
enablerf=0;
#10
enablerf=1;
#10
enablerf=0;
end
else enablerf=clk;
end
endmodule 