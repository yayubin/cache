


module main_memory
#(
   parameter ADDR_LEN    = 16 ,   //地址总线宽度
   parameter MEMORY_DW   = 256,//64//DW=MW*8//cahce一次从主存读取多少位宽数据
   parameter MEMORY_MW   = 32 ,//8
   parameter OFFSET_LEN  = 2  ,
   parameter DELAY       = 2 ,   //读写延迟时钟
   parameter MEMORY_DP  = ( 1<< (ADDR_LEN -OFFSET_LEN ))
)
(
  input wire              clk              ,
  input wire              rst_n            ,

  input wire             memory_cs        ,

  input                   memory_cmd_valid , // Handshake valid
  output                  memory_cmd_ready , // Handshake ready
  input                   memory_cmd_read  ,  // Read or write

  input wire  [ADDR_LEN-1:0]               memory_cmd_addr, 
  //  input wire  [ADDR_LEN -OFFSET_LEN-1:0]   memory_cmd_addr  ,  


  input  [MEMORY_DW-1:0]  memory_cmd_wdata , 
  input  [MEMORY_MW-1:0]  memory_cmd_wmask , 
  
  output                   memory_rsp_valid, // Response valid 
  input                    memory_rsp_ready, // Response ready
  output   [MEMORY_DW-1:0] memory_rsp_rdata
);
//------------------------------------------------------
 wire       memory_rsp_valid2;


  wire                               cs;  //1表示使能该芯片
  reg                                we;  //0为读，1为写
  reg [ADDR_LEN -OFFSET_LEN -1:0]    addr;
  reg [MEMORY_DW-1:0]                din;
  reg [MEMORY_MW-1:0]                wem; //对应位1表示操作的字节有效
  wire [MEMORY_DW-1:0]               dout;

  reg da_flag;//有数据标致
  reg read_flag;//读标致
  wire en;

 assign cs = memory_cs;
 assign memory_cmd_ready = (da_flag==0);
 assign en= (memory_cmd_valid==1) & (memory_cmd_ready==1);
 reg [7:0]cont;
 always @(posedge clk)begin
    if(rst_n==0)begin
            cont <=0;
             da_flag <=0;
             we   <= 0;
             addr <= 0;
             din  <= 0;
             wem  <= 0;
             read_flag <=0;
    end
    else begin
         wem <=0;
         we <=0;
        if(memory_cs ==1 && en==1)begin
             //addr <= memory_cmd_addr;
             addr <= memory_cmd_addr[ADDR_LEN -1:OFFSET_LEN]; 
             din  <= memory_cmd_wdata;
             if(memory_cmd_read==0)begin//写
                 wem  <= memory_cmd_wmask;
                 we <=1;
             end
        end
       
        if(en==1)begin
            cont    <=0;
             da_flag <=1;
             read_flag <= memory_cmd_read;
        end
        if(da_flag==1)begin
           if(cont < 8'hff )begin
                cont <=  cont+1;
           end
          // else begin
           if(memory_rsp_valid2 ==1 && (memory_rsp_ready==1 || read_flag==0))begin
                  da_flag <=0;
                  read_flag <=0;
           end
         //  end
        end
    end
 end

assign memory_rsp_valid2 = (cont >=DELAY && da_flag==1);//延迟几次时钟输出
assign memory_rsp_valid = memory_rsp_valid2 & read_flag;

assign memory_rsp_rdata = dout;
//------------------------------------------------------
`ifdef FPGA_SOURCE
sirv_gnrl_ram 
#(
 // .DP           ( 1<< (ADDR_LEN -OFFSET_LEN )), //数据深度// DP=1<<AW
  .DP           ( MEMORY_DP), //数据深度// DP=1<<AW
  .DW           (MEMORY_DW)   , //DW=MW*8
  .FORCE_X2ZERO (1'b0)        ,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
  .MW           (MEMORY_MW)   , //数据有几个字节（8位)。 
  .AW           (ADDR_LEN -OFFSET_LEN )     //地址宽度
  )
u0_main_ram
  (
  .rst_n(rst_n),
  .clk  (clk),
  //.cs   (lru_cs),
  //.cs   (1'd1),
  .cs   (cs   ),
  .we   (we   ),
  .addr (addr ),
  .din  (din  ),
  .wem  (wem  ),//对应位1表示操作的字节有效
  .dout (dout )
);
`else
sirv_gnrl_ram 
#(
 // .DP           ( 1<< (ADDR_LEN -OFFSET_LEN )), //数据深度// DP=1<<AW
  .DP           ( MEMORY_DP), //数据深度// DP=1<<AW
  .DW           (MEMORY_DW)   , //DW=MW*8
  .FORCE_X2ZERO (1'b1)        ,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
  .MW           (MEMORY_MW)   , //数据有几个字节（8位)。 
  .AW           (ADDR_LEN -OFFSET_LEN )     //地址宽度
  )
u0_main_ram
  (
  .rst_n(rst_n),
  .clk  (clk),
  //.cs   (lru_cs),
  //.cs   (1'd1),
  .cs   (cs   ),
  .we   (we   ),
  .addr (addr ),
  .din  (din  ),
  .wem  (wem  ),//对应位1表示操作的字节有效
  .dout (dout )
);
`endif 
//----------------------------------------------------------------------
`ifdef main_memory_ila_en
ila_1024_1024 main_memory_ila (
    //  ila_1024_1024 cache_momory_ila (
	.clk(clk), // input wire clk

	.probe0(
          {
           cs   ,
           we   ,
           addr ,
           din  ,
           wem  ,
           dout  ,

           memory_cmd_addr
          }
  )
);

`endif 


//-----------------------------------------------------------------------


endmodule
//===============================================================================
