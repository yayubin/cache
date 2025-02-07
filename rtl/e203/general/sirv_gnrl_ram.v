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
//  The top level RAM module
//
// ====================================================================
`define FPGA_SOURCE

module sirv_gnrl_ram
#(parameter DP = 32,//数据深度// DP=1<<AW
  parameter DW = 32,//DW=MW*8
  parameter FORCE_X2ZERO = 1,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
  parameter MW = 4,//数据有几个字节（8位)。 
  parameter AW = 15 //地址宽度
  ) (
  input            sd,
  input            ds,
  input            ls,

  input            rst_n,
  input            clk,
  input            cs,//1表示使能该芯片
  input            we,//0为读，1为写
  input [AW-1:0]   addr,
  input [DW-1:0]   din,
  input [MW-1:0]   wem,//对应位1表示操作的字节有效
  output[DW-1:0]   dout
);

//To add the ASIC or FPGA or Sim-model control here
// This is the Sim-model
//
`ifdef FPGA_SOURCE
sirv_sim_ram #(
    .FORCE_X2ZERO (1'b0),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW) 
)u_sirv_sim_ram (
    .clk   (clk),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);
`else

sirv_sim_ram #(
    .FORCE_X2ZERO (FORCE_X2ZERO),
    .DP (DP),
    .AW (AW),
    .MW (MW),
    .DW (DW) 
)u_sirv_sim_ram (
    .clk   (clk),
    .din   (din),
    .addr  (addr),
    .cs    (cs),
    .we    (we),
    .wem   (wem),
    .dout  (dout)
);
`endif




endmodule
