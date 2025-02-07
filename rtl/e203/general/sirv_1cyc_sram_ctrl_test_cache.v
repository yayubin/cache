 /*                                                                      
 Copyright 2018-2020 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
//
// Designer   : Bob Hu
//
// Description:
//  The 1cyc_sram_ctrl module control the 1 Cycle SRAM access requests 
//模块控制1周期SRAM访问请求,uop_cmd_usr数据也实现一周期缓存
// ====================================================================

/*
      .DW     (`E203_ITCM_DATA_WIDTH),//64
      .AW     (`E203_ITCM_ADDR_WIDTH),//16
      .MW     (`E203_ITCM_WMSK_WIDTH),//8
      .AW_LSB (3),// ITCM is 64bits wide, so the LSB is 3
      .USR_W  (2) 
*/
module sirv_1cyc_sram_ctrl_test_cache #(//实验把sram定义在本模块
    parameter DW = 32,
    parameter MW = 4,
    parameter AW = 32,
    parameter AW_LSB = 3,
    parameter USR_W = 3 
)(
  output sram_ctrl_active,//sram_ctrl_active=0时，上层如果也满足条件本模块clk也停止工作  //sram_ctrl_active=1时本模块clk一定会工作
  // The cgstop is coming from CSR (0xBFE mcgstop)'s filed 1
  // // This register is our self-defined CSR register to disable the 
      // ITCM SRAM clock gating for debugging purpose
  input  tcm_cgstop,
  
  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  //    * Cmd channel
  input  uop_cmd_valid, // Handshake valid
  output uop_cmd_ready, // Handshake ready
  input  uop_cmd_read,  // Read or write
  input  [AW-1:0] uop_cmd_addr, 
  input  [DW-1:0] uop_cmd_wdata, 
  input  [MW-1:0] uop_cmd_wmask, 
  input  [USR_W-1:0] uop_cmd_usr, 

  //    * RSP channel
  output uop_rsp_valid, // Response valid 
  input  uop_rsp_ready, // Response ready
  output [DW-1:0] uop_rsp_rdata, 
  output [USR_W-1:0] uop_rsp_usr, //指示此流水请求信号是哪个用户发起的
/*
  output                 ram_cs,  
  output                 ram_we,  
  output [AW-AW_LSB-1:0] ram_addr, 
  output [MW-1:0]        ram_wem,
  output [DW-1:0]        ram_din,          
  input  [DW-1:0]        ram_dout,
  output                 clk_ram,
  */
  output                 ram_cs2,  
  output                 ram_we2,  
  output [AW-AW_LSB-1:0] ram_addr2, 
  output [MW-1:0]        ram_wem2,
  output [DW-1:0]        ram_din2,          
  input  [DW-1:0]        ram_dout2,
  output                 clk_ram2,


  input  test_mode,
  input  clk,
  input  rst_n
  );


//--test-----------------------------------------
  wire                 ram_cs;  
  wire                 ram_we;  
  wire [AW-AW_LSB-1:0] ram_addr; 
  wire [MW-1:0]        ram_wem;
  wire [DW-1:0]        ram_din;          
  wire  [DW-1:0]       ram_dout;
  wire                 clk_ram;

assign  ram_cs2   = 0; 
assign  ram_we2   = 0; 
assign  ram_addr2 = 0; 
assign  ram_wem2  = 0; 
assign  ram_din2  = 0; 
assign  clk_ram2  = 0; 

sirv_gnrl_ram 
#(
  .DP           (1<<(AW-3)), //数据深度// DP=1<<AW
  .DW           (DW)   , //DW=MW*8
  .FORCE_X2ZERO (1'b1)        ,//FPGA时   FORCE_X2ZERO==0//FORCE_X2ZERO表示1'bx时转为0
  .MW           (MW)   , //数据有几个字节（8位)。 
  .AW           (AW)     //地址宽度
  )
lru_ram
  (
  .rst_n(rst_n),
  .clk  (clk),
  .cs   (ram_cs),
  .we   (ram_we),
  .addr (ram_addr),
  .din  (ram_din),
  .wem  (ram_wem),//对应位1表示操作的字节有效
  .dout (ram_dout)
);

//------------------------------------------
  sirv_gnrl_pipe_stage # (//这个模块缓存uop_cmd_usr一周期，顺便处理总线信号。
   .CUT_READY(0),//实现一个数据深度缓存，CUT_READY=0时，缓存满时还能接收实现数据流水不断
   .DP(1),
   .DW(USR_W)
  ) u_e1_stage (
    .i_vld(uop_cmd_valid), 
    .i_rdy(uop_cmd_ready), 
    .i_dat(uop_cmd_usr),
    .o_vld(uop_rsp_valid), 
    .o_rdy(uop_rsp_ready), 
    .o_dat(uop_rsp_usr),
  
    .clk  (clk  ),
    .rst_n(rst_n)  
   );

   assign ram_cs = uop_cmd_valid & uop_cmd_ready; //sirv_gnrl_pipe_stage模块没数据或没请求读数据就关sram
   assign ram_we = (~uop_cmd_read);  
   assign ram_addr= uop_cmd_addr [AW-1:AW_LSB];          
   assign ram_wem = uop_cmd_wmask[MW-1:0];          
   assign ram_din = uop_cmd_wdata[DW-1:0];          

   wire ram_clk_en = ram_cs | tcm_cgstop;//sram没工作就停止时钟

   e203_clkgate u_ram_clkgate(
     .clk_in   (clk        ),
     .test_mode(test_mode  ),
     .clock_en (ram_clk_en),
     .clk_out  (clk_ram)
   );

   assign uop_rsp_rdata = ram_dout;

 // assign sram_ctrl_active = uop_cmd_valid | uop_rsp_valid;
 assign sram_ctrl_active = 1'b1;//test
/*
  ila_1024_1024 sram_ctrl_ila (
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

             ram_cs,  
             ram_we, 

          
             ram_addr, 
             ram_wem,
             ram_din,          
             ram_dout,
             clk_ram,

             ram_clk_en,
             sram_ctrl_active
          }
         ) // input wire [15:0] probe0
);
*/
endmodule

