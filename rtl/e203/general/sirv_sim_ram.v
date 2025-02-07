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
//  The simulation model of SRAM
//
// ====================================================================
module sirv_sim_ram //在选通信号后下一周期输出
#(parameter DP = 512,//数据深度// DP=1<<AW
  parameter FORCE_X2ZERO = 0,//FPGA时,FORCE_X2ZERO=0。芯片时,FORCE_X2ZERO=1//FORCE_X2ZERO=1时表示1'bx时转为0
  parameter DW = 32,//DW=MW*8
  parameter MW = 4,//数据有几个字节（8位)。 
  parameter AW = 32 //地址宽度
)
(
  input             clk, 
  input  [DW-1  :0] din, 
  input  [AW-1  :0] addr,
  input             cs,//1表示使能该芯片
  input             we,//0为读，1为写
  input  [MW-1:0]   wem,//写操作时，对应的位1表示使能写入对应的字节（8位）
  output [DW-1:0]   dout
);

    reg [DW-1:0] mem_r [0:DP-1];
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;
    wire ren;

    assign ren = cs & (~we);
    assign wen = ({MW{cs & we}} & wem);



    genvar i;

    always @(posedge clk)
    begin
        if (ren) begin
            addr_r <= addr;//模拟sram在选通信号后下一周期输出
        end
    end

    generate
      for (i = 0; i < MW; i = i+1) begin :mem
        if((8*i+8) > DW ) begin: last//数据超过时
          always @(posedge clk) begin
            if (wen[i]) begin
               mem_r[addr][DW-1:8*i] <= din[DW-1:8*i];
            end
          end
        end
        else begin: non_last//数据正常没超过时
          always @(posedge clk) begin
            if (wen[i]) begin
               mem_r[addr][8*i+7:8*i] <= din[8*i+7:8*i];
            end
          end
        end
      end
    endgenerate

  wire [DW-1:0] dout_pre;
  assign dout_pre = mem_r[addr_r];

  generate
   if(FORCE_X2ZERO == 1) begin: force_x_to_zero//芯片时
      for (i = 0; i < DW; i = i+1) begin:force_x_gen 
          `ifndef SYNTHESIS//{
         assign dout[i] = (dout_pre[i] === 1'bx) ? 1'b0 : dout_pre[i];//芯片时要一位一位的判断读取
          `else//}{
         assign dout[i] = dout_pre[i];
          `endif//}
      end
   end
   else begin:no_force_x_to_zero//FPGA时   FORCE_X2ZERO==0
     assign dout = dout_pre;//FPGA时一次性全部读
   end
  endgenerate

 
//----------------------------------------
`ifdef FPGA_SOURCE
integer ii;

    initial begin
        for(ii = 0; ii < DP; ii=ii+1) begin
	          mem_r[ii] =5;///!!!!!!!!!!!!!!!
         //    mem_r[ii] =0;
        end
    end

`endif
//------------------------------------------------
endmodule
