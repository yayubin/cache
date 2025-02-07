
`include "cache_config.v"
//===============================================================================

//`define SIM
//替换 module sirv_1cyc_sram_ctrl
module sirv_1cyc_sram_ctrl_cache
#(
  /*
    parameter DW = 32,//64
    parameter MW = 4,//8
    parameter AW = 32,//16
    parameter AW_LSB = 3,//3
    parameter USR_W = 3  //2
    */
     parameter DW = 32,//64
    parameter MW = 4,//8
   //parameter AW = 32,//16
    parameter AW = 8,//16
    parameter AW_LSB = 3,//3
    parameter USR_W = 3  //2

)
(
  output sram_ctrl_active,//sram_ctrl_active=0时，上层如果也满足条件本模块clk也停止工作  //sram_ctrl_active=1时本模块clk一定会工作
  // The cgstop is coming from CSR (0xBFE mcgstop)'s filed 1
  // // This register is our self-defined CSR register to disable the 
      // ITCM SRAM clock gating for debugging purpose
  input  tcm_cgstop,
  
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  //    * Cmd channel
  input                  uop_cmd_valid, // Handshake valid
  output                 uop_cmd_ready, // Handshake ready
  input                  uop_cmd_read ,  // Read or write
  input  [AW-1:0]        uop_cmd_addr , 
  input  [DW-1:0]        uop_cmd_wdata, 
  input  [MW-1:0]        uop_cmd_wmask, 
  input  [USR_W-1:0]     uop_cmd_usr  , 

  //    * RSP channel
  output                 uop_rsp_valid, // Response valid 
  input                  uop_rsp_ready, // Response ready
  output [DW-1:0]        uop_rsp_rdata, 
  output [USR_W-1:0]     uop_rsp_usr  , //指示此流水请求信号是哪个用户发起的

  output                 ram_cs   ,  
  output                 ram_we   ,  
  output [AW-AW_LSB-1:0] ram_addr , 
  output [MW-1:0]        ram_wem  ,
  output [DW-1:0]        ram_din  ,          
  input  [DW-1:0]        ram_dout ,
  output                 clk_ram  , 

  input                  test_mode,
  input   wire           clk      ,
  input                  rst_n
  );
  //-----------------------------------------------------------
  /*
    parameter CPU_DW = DW;//64 //DW=MW*8 //cpu一次从cache读取多少位宽数据
    parameter CPU_MW = MW;//8

    parameter MEMORY_DW = 256;//64//DW=MW*8//cahce一次从主存读取多少位宽数据
    parameter MEMORY_MW = 32;//8

   
    parameter ADDR_LEN  = AW - AW_LSB;   //地址总线宽度
    parameter INDEX_LEN = 2;//块，2^INDEX_LEN个块
    parameter OFFSET_LEN  = 2;// 2^OFFSET_LEN = MEMORY_DW / CPU_DW;//块内有多少个单位数据，cpu一次只读一个单位数据，cache从主存一次读一个单位块。
    parameter TAG_LEN     = ADDR_LEN - INDEX_LEN - OFFSET_LEN;

    parameter TAG_DW     =16;//(TAG_LEN+2(dirty,valid))//位，按8的倍数
    parameter TAG_MW     =2;//TAG需要多少个字节存(TAG_LEN+2(dirty,valid))

    parameter WAY_NUM    =4;
    parameter LRU_DW     =8;//WAY_NUM=4//LRU_DW=LRU_WAY_DW*WAY_NUM//表示组个数需要多少位*8
    parameter LRU_MW     =1;//LRU_MW=(LRU_DW * WAY_NUM)/8 //存组活跃数据需要多少字节

	parameter    MEMORY_DELAY =1;
  */
//-----------------------------------------------------------
/*
    parameter CPU_DW = DW;//64 //DW=MW*8 //cpu一次从cache读取多少位宽数据
    parameter CPU_MW = MW;//8

    parameter MEMORY_DW = 256;//64//DW=MW*8//cahce一次从主存读取多少位宽数据
    parameter MEMORY_MW = 32;//8

   
    parameter ADDR_LEN  = AW - AW_LSB;   //地址总线宽度
    parameter INDEX_LEN = 8;//块，2^INDEX_LEN个块
    parameter OFFSET_LEN  = 2;// 2^OFFSET_LEN = MEMORY_DW / CPU_DW;//块内有多少个单位数据，cpu一次只读一个单位数据，cache从主存一次读一个单位块。
    parameter TAG_LEN     = ADDR_LEN - INDEX_LEN - OFFSET_LEN;

    parameter TAG_DW     =8;//(TAG_LEN+2(dirty,valid))//位，按8的倍数
    parameter TAG_MW     =1;//TAG需要多少个字节存(TAG_LEN+2(dirty,valid))

    parameter WAY_NUM    =4;
    parameter LRU_DW     =8;//WAY_NUM=4//LRU_DW=LRU_WAY_DW*WAY_NUM//表示组个数需要多少位*8
    parameter LRU_MW     =1;//LRU_MW=(LRU_DW * WAY_NUM)/8 //存组活跃数据需要多少字节

	parameter DELAY =1;
  */
  
  //.........测试..............................
/*
    parameter CPU_DW = 64;//64 //DW=MW*8 //cpu一次从cache读取多少位宽数据
    parameter CPU_MW = 8;//8

    parameter MEMORY_DW = 256;//64//DW=MW*8//cahce一次从主存读取多少位宽数据
    parameter MEMORY_MW = 32;//8

   
    parameter ADDR_LEN  = 8;   //地址总线宽度
    parameter INDEX_LEN = 2;//块，2^INDEX_LEN个块
    parameter OFFSET_LEN  = 2;// 2^OFFSET_LEN = MEMORY_DW / CPU_DW;//块内有多少个单位数据，cpu一次只读一个单位数据，cache从主存一次读一个单位块。
    parameter TAG_LEN     = ADDR_LEN - INDEX_LEN - OFFSET_LEN;

    parameter TAG_DW     =8;//(TAG_LEN+2(dirty,valid))//位，按8的倍数
    parameter TAG_MW     =1;//TAG需要多少个字节存(TAG_LEN+2(dirty,valid))

    parameter WAY_NUM   =4;
    parameter LRU_DW     =8;//WAY_NUM=4//LRU_DW=LRU_WAY_DW*WAY_NUM//表示组个数需要多少位*8
    parameter LRU_MW     =1;//LRU_MW=(LRU_DW * WAY_NUM)/8 //存组活跃数据需要多少字节

	  parameter DELAY =1;
  */
//-----------------------------------------------------------
/*
  reg                 cpu_cmd_valid; // Handshake valid
  wire                cpu_cmd_ready; // Handshake ready
  reg                 cpu_cmd_read ;  // Read or write//1为读
  wire [ADDR_LEN-1:0] cpu_cmd_addr ; 
  reg [CPU_DW-1:0]    cpu_cmd_wdata; 
  reg [CPU_MW-1:0]    cpu_cmd_wmask; 
  wire                 cpu_rsp_valid; // Response valid 
  reg                  cpu_rsp_ready; // Response ready
  wire [CPU_DW-1:0]    cpu_rsp_rdata; 
*/
/*
  wire                   memory_cs        ;
  wire                   memory_cmd_valid ; // Handshake valid
  wire                   memory_cmd_ready ; // Handshake ready
  wire                   memory_cmd_read  ;  // Read or write
  wire  [ADDR_LEN-1:0]   memory_cmd_addr  ;  
  wire  [MEMORY_DW-1:0]  memory_cmd_wdata ; 
  wire  [MEMORY_MW-1:0]  memory_cmd_wmask ; 
  
  wire                    memory_rsp_valid; // Response valid 
  wire                    memory_rsp_ready; // Response ready
  wire   [MEMORY_DW-1:0]  memory_rsp_rdata;
  */

  wire                   memory_cs        ;
  wire                   memory_cmd_valid ; // Handshake valid
  wire                   memory_cmd_ready ; // Handshake ready
  wire                   memory_cmd_read  ;  // Read or write
  wire  [`ADDR_LEN-1:0]   memory_cmd_addr  ;  
  wire  [`MEMORY_DW-1:0]  memory_cmd_wdata ; 
  wire  [`MEMORY_MW-1:0]  memory_cmd_wmask ; 
  
  wire                    memory_rsp_valid; // Response valid 
  wire                    memory_rsp_ready; // Response ready
  wire   [`MEMORY_DW-1:0]  memory_rsp_rdata;
//.........................................................
assign  ram_cs   = 0; 
assign  ram_we   = 0; 
assign  ram_addr = 0; 
assign  ram_wem  = 0; 
assign  ram_din  = 0; 
assign  clk_ram  = 0; 

//assign memory_cs =1'b0;
assign memory_cs =1'b1;
//assign sram_ctrl_active = uop_cmd_valid | uop_rsp_valid;
assign sram_ctrl_active = 1'b1;
//......................................................
reg  [USR_W-1:0]     uop_cmd_usr_d1;
reg  [USR_W-1:0]     uop_cmd_usr_d1_test;

always @(posedge clk)begin
     if(rst_n==0)begin
          uop_cmd_usr_d1 <=0;
          uop_cmd_usr_d1_test <=0;
     end
     else begin
         if(uop_cmd_valid==1 && uop_cmd_ready==1)begin
             uop_cmd_usr_d1 <= uop_cmd_usr;
             uop_cmd_usr_d1_test <= uop_cmd_usr_d1;
         end
     end
end
//assign uop_rsp_usr = uop_cmd_usr_d1;
assign uop_rsp_usr = (uop_rsp_valid ==1)? uop_cmd_usr_d1 : uop_cmd_usr_d1_test;
//.........................................................

//.........................................................

cache 
 #(
    .CPU_DW    (`CPU_DW   ),//64 //DW=MW*8 //cpu一次从cache读取多少位宽数据
    .CPU_MW    (`CPU_MW   ),//8
    .MEMORY_DW (`MEMORY_DW),//64//DW=MW*8//cahce一次从主存读取多少位宽数据
    .MEMORY_MW (`MEMORY_MW),//8
    //.WAY_NUM   (WAY_NUM  ),
    .ADDR_LEN  (`ADDR_LEN ),   //地址总线宽度
    .INDEX_LEN (`INDEX_LEN),//块，2^INDEX_LEN个块
    .OFFSET_LEN  (`OFFSET_LEN),// 2^OFFSET_LEN = MEMORY_DW / CPU_DW;//块内有多少个单位数据，cpu一次只读一个单位数据，cache从主存一次读一个单位块。

    .WAY_NUM  (`WAY_NUM),
    .TAG_DW   (`TAG_DW ),//(TAG_LEN+2(dirty,valid))//位，按8的倍数
    .TAG_MW   (`TAG_MW ),//TAG需要多少个字节存(TAG_LEN+2(dirty,valid))
    .LRU_DW   (`LRU_DW ),//WAY_NUM=4//LRU_DW=LRU_WAY_DW*WAY_NUM//表示组个数需要多少位*8
    .LRU_MW   (`LRU_MW ),//LRU_MW=(LRU_DW * WAY_NUM)/8 //存组活跃数据需要多少字节

    .CACHE_DP (`CACHE_DP)

)
 u0_cache
(
  .clk      (clk),
  .rst_n    (rst_n),

  .cache_en (),
//................................
  .cpu_cmd_valid(uop_cmd_valid), // Handshake valid
  .cpu_cmd_ready(uop_cmd_ready), // Handshake ready
  .cpu_cmd_read (uop_cmd_read ),  // Read or write//1为读
 .cpu_cmd_addr (uop_cmd_addr[AW-1:AW_LSB] ), 
   //.cpu_cmd_addr (uop_cmd_addr), 
  .cpu_cmd_wdata(uop_cmd_wdata), 
  .cpu_cmd_wmask(uop_cmd_wmask), 
  
  .cpu_rsp_valid(uop_rsp_valid), // Response valid 
  .cpu_rsp_ready(uop_rsp_ready), // Response ready
  .cpu_rsp_rdata(uop_rsp_rdata), 
//..................................
  .memory_cmd_valid(memory_cmd_valid), // Handshake valid
  .memory_cmd_ready(memory_cmd_ready), // Handshake ready
  .memory_cmd_read (memory_cmd_read ),  // Read or write
  .memory_cmd_addr (memory_cmd_addr), 
  .memory_cmd_wdata(memory_cmd_wdata), 
  .memory_cmd_wmask(memory_cmd_wmask), 
  
  .memory_rsp_valid(memory_rsp_valid), // Response valid 
  .memory_rsp_ready(memory_rsp_ready), // Response ready
  .memory_rsp_rdata(memory_rsp_rdata)
//..................................  
);

main_memory 
#(
   .ADDR_LEN    (`ADDR_LEN  ),   //地址总线宽度
   .MEMORY_DW   (`MEMORY_DW ),//64//DW=MW*8//cahce一次从主存读取多少位宽数据
   .MEMORY_MW   (`MEMORY_MW ),//8
   .OFFSET_LEN  (`OFFSET_LEN),
  // .DELAY       (1)
   .DELAY       (`MEMORY_DELAY),
   .MEMORY_DP   (`MEMORY_DP)
)
u0_main_memory
(
  .clk              (clk),
  .rst_n            (rst_n),

  .memory_cs        (memory_cs),

  .memory_cmd_valid (memory_cmd_valid), // Handshake valid
  .memory_cmd_ready (memory_cmd_ready), // Handshake ready
 .memory_cmd_read  (memory_cmd_read ),  // Read or write
  .memory_cmd_addr  (memory_cmd_addr ), 
   //.memory_cmd_addr  (memory_cmd_addr[ADDR_LEN-1:OFFSET_LEN] ), 
  .memory_cmd_wdata (memory_cmd_wdata), 
  .memory_cmd_wmask (memory_cmd_wmask), 
  
  .memory_rsp_valid (memory_rsp_valid), // Response valid 
  .memory_rsp_ready (memory_rsp_ready), // Response ready
  .memory_rsp_rdata (memory_rsp_rdata)
);

//--------------------------------------------------------

`ifdef sirv_1cyc_sram_ctrl_cache_ila_en
 // ila_512_1024 sram_ctrl_cache_ila (
  ila_2048_1024 sram_ctrl_cache_ila (
	.clk(clk), // input wire clk

	.probe0(
          {
             uop_cmd_valid, // Handshake valid
             uop_cmd_ready, // Handshake ready
             uop_cmd_read,  // Read or write
             uop_cmd_addr, 
             uop_cmd_wdata, 
             uop_cmd_wmask, 
             uop_cmd_usr,

             uop_rsp_valid, // Response valid 
             uop_rsp_ready, // Response ready
             uop_rsp_rdata, 
             uop_rsp_usr, //指示此流水请求信号是哪个用户发起的

             memory_cmd_valid,
             memory_cmd_ready,
             memory_cmd_read ,
             memory_cmd_addr ,
             memory_cmd_wdata,
             memory_cmd_wmask,
             memory_rsp_valid,
             memory_rsp_ready,
             memory_rsp_rdata,

            // ram_cs,  
            // ram_we, 
           //  ram_clk_en,
             sram_ctrl_active
          }
         ) // input wire [15:0] probe0
);
`endif 

//---------------------------------------------
endmodule
//===============================================================================

