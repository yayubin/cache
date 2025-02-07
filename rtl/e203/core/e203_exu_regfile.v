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
// Designer   : Bob Hu
//
// Description:
//  The Regfile module to implement the core's general purpose registers file
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_regfile(
  input  [`E203_RFIDX_WIDTH-1:0] read_src1_idx,// 从minidecode的指令源操作数rs1的索引  在读数据时候用
  input  [`E203_RFIDX_WIDTH-1:0] read_src2_idx,// 从minidecode的指令源操作数rs2的索引  在读数据时候用
  output [`E203_XLEN-1:0]        read_src1_dat,//通用寄存器有两个读口 // 取出的源操作数的值
  output [`E203_XLEN-1:0]        read_src2_dat,// 取出的源操作数的值

  input                          wbck_dest_wen, //写回操作的写使能，由wbck模块给出
  input  [`E203_RFIDX_WIDTH-1:0] wbck_dest_idx,// 写回操作的寄存器地址，由wbck模块给出
  input  [`E203_XLEN-1:0]        wbck_dest_dat,      // 写回操作的待写入数据，由wbck模块给出

  output [`E203_XLEN-1:0]        x1_r,// 由于x1常用于link寄存器用于函数的跳转返回，这里直接接出来的x1的值做加速，读x1不需要读端口，但是需要检查数据相关性

  input                          test_mode,
  input                          clk,
  input                          rst_n
  );
//===========================================================================
  wire [`E203_XLEN-1:0] rf_r [`E203_RFREG_NUM-1:0];//32个32位通用寄存器
  wire [`E203_RFREG_NUM-1:0] rf_wen;               //控制打开哪个寄存器进行写入数据
  
  `ifdef E203_REGFILE_LATCH_BASED //{
  // Use DFF to buffer the write-port
    //如果使用锁存器实现通用寄存器。则需要将写端口使用DFF专门寄存一拍,此举能够防止锁存器带来的写端口至读端口之间的锁存器穿通效应。
  wire [`E203_XLEN-1:0] wbck_dest_dat_r;
  sirv_gnrl_dffl #(`E203_XLEN) wbck_dat_dffl (wbck_dest_wen, wbck_dest_dat, wbck_dest_dat_r, clk);
  wire [`E203_RFREG_NUM-1:0] clk_rf_ltch;
  `endif//}

  
  genvar i;
  generate //{//通过使用参数化的 generate 语法生成 Regfile 的逻辑
  
      for (i=0; i<`E203_RFREG_NUM; i=i+1) begin:regfile//{
  
        if(i==0) begin: rf0
            // x0 cannot be wrote since it is constant-zeros//×0 是一个常数 0，因此无须产生写逻辑。
            assign rf_wen[i] = 1'b0;
            assign rf_r[i] = `E203_XLEN'b0;
          `ifdef E203_REGFILE_LATCH_BASED //{
            assign clk_rf_ltch[i] = 1'b0;
          `endif//}
        end
        else begin: rfno0
        //通过对写结果寄存器的索引号和寄存器号进行比较产生写使能。
            assign rf_wen[i] = wbck_dest_wen & (wbck_dest_idx == i) ;
          `ifdef E203_REGFILE_LATCH_BASED //{
            //如果是使用锁存器的配置,则人为的明确为每一个通用寄存器配置一个门控时钟以节省功耗
            e203_clkgate u_e203_clkgate(
              .clk_in  (clk  ),
              .test_mode(test_mode),
              .clock_en(rf_wen[i]),
              .clk_out (clk_rf_ltch[i])
            );
              //如果是使用锁存器的配置，则例化锁存器实现通用寄存器
                //from write-enable to clk_rf_ltch to rf_ltch
            sirv_gnrl_ltch #(`E203_XLEN) rf_ltch (clk_rf_ltch[i], wbck_dest_dat_r, rf_r[i]);
          `else//}{
            //如果是不使用锁存器的配置,则例化DFF实现通用寄存器
            // 由于此处有明确的 Load-enable 信号，综合工具会自动插入门控时钟(ICG)以节省功耗。有关综合工具自动插入门控时钟的更多信息,请参见第15.1.5节。
            sirv_gnrl_dffl #(`E203_XLEN) rf_dffl (rf_wen[i], wbck_dest_dat, rf_r[i], clk);
          `endif//}
        end
  
      end//}
  endgenerate//}
    //每个读端口都是一个纯粹的并行多路选择器
  //多路选择器的选择信号即读操作数的寄存器索引
  assign read_src1_dat = rf_r[read_src1_idx];
  assign read_src2_dat = rf_r[read_src2_idx];
  
 // wire  [`E203_XLEN-1:0] x0  = rf_r[0];
 // wire  [`E203_XLEN-1:0] x1  = rf_r[1];
 // wire  [`E203_XLEN-1:0] x2  = rf_r[2];
 // wire  [`E203_XLEN-1:0] x3  = rf_r[3];
 // wire  [`E203_XLEN-1:0] x4  = rf_r[4];
 // wire  [`E203_XLEN-1:0] x5  = rf_r[5];
 // wire  [`E203_XLEN-1:0] x6  = rf_r[6];
 // wire  [`E203_XLEN-1:0] x7  = rf_r[7];
 // wire  [`E203_XLEN-1:0] x8  = rf_r[8];
 // wire  [`E203_XLEN-1:0] x9  = rf_r[9];
 // wire  [`E203_XLEN-1:0] x10 = rf_r[10];
 // wire  [`E203_XLEN-1:0] x11 = rf_r[11];
 // wire  [`E203_XLEN-1:0] x12 = rf_r[12];
 // wire  [`E203_XLEN-1:0] x13 = rf_r[13];
 // wire  [`E203_XLEN-1:0] x14 = rf_r[14];
 // wire  [`E203_XLEN-1:0] x15 = rf_r[15];
 // `ifdef E203_RFREG_NUM_IS_32 //{ 
 // wire  [`E203_XLEN-1:0] x16 = rf_r[16];
 // wire  [`E203_XLEN-1:0] x17 = rf_r[17];
 // wire  [`E203_XLEN-1:0] x18 = rf_r[18];
 // wire  [`E203_XLEN-1:0] x19 = rf_r[19];
 // wire  [`E203_XLEN-1:0] x20 = rf_r[20];
 // wire  [`E203_XLEN-1:0] x21 = rf_r[21];
 // wire  [`E203_XLEN-1:0] x22 = rf_r[22];
 // wire  [`E203_XLEN-1:0] x23 = rf_r[23];
 // wire  [`E203_XLEN-1:0] x24 = rf_r[24];
 // wire  [`E203_XLEN-1:0] x25 = rf_r[25];
 // wire  [`E203_XLEN-1:0] x26 = rf_r[26];
 // wire  [`E203_XLEN-1:0] x27 = rf_r[27];
 // wire  [`E203_XLEN-1:0] x28 = rf_r[28];
 // wire  [`E203_XLEN-1:0] x29 = rf_r[29];
 // wire  [`E203_XLEN-1:0] x30 = rf_r[30];
 // wire  [`E203_XLEN-1:0] x31 = rf_r[31];
 // `endif//}

  assign x1_r = rf_r[1];
      
endmodule

