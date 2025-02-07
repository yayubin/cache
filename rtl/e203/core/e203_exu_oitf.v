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
//  The OITF (Oustanding Instructions Track FIFO) to hold all the non-ALU long
//  pipeline instruction's status and information
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_oitf (
  output dis_ready,

  input  dis_ena,//派遣一个长指令的使能信号,该信号将用于分配一个01TF表项
  input  ret_ena,//写回一个长指令的使能信号,该信号将用于移除一个OITF表项

  output [`E203_ITAG_WIDTH-1:0] dis_ptr,
  output [`E203_ITAG_WIDTH-1:0] ret_ptr,

  output [`E203_RFIDX_WIDTH-1:0] ret_rdidx,
  output ret_rdwen,
  output ret_rdfpu,
  output [`E203_PC_SIZE-1:0] ret_pc,
//以下为派遣的长指令相关信息,有的会被存储于OITF的表项中,有的会用于进行RAW和WAW判断
  input  disp_i_rs1en,//当前派遣指令是否需要读取第一个源操作数寄存器
  input  disp_i_rs2en,//当前派遣指令是否需要读取第二个源操作数寄存器
  input  disp_i_rs3en,//当前派遣指令是否需要读取第三个源操作数寄存器,// 注意：只有浮点指令才会使用第三个源操作数
  input  disp_i_rdwen,//当前派遣指令是否需要写回结果寄存器
  input  disp_i_rs1fpu,//当前派遣指令第一个源操作数是否是要读取浮点通用寄存器组
  input  disp_i_rs2fpu,//当前派遣指令第二个源操作数是否是要读取浮点通用寄存器组
  input  disp_i_rs3fpu,//当前派遣指令第三个源操作数是否是要读取浮点通用寄存器组
  input  disp_i_rdfpu,//当前派遣指令结果寄存器是否是要写回浮点通用寄存器组
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs1idx,//当前派遣指令第一个源操作数寄存器的索引
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs2idx,//当前派遣指令第二个源操作数寄存器的索引
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rs3idx,//当前派遣指令第三个源操作数寄存器的索引
  input  [`E203_RFIDX_WIDTH-1:0] disp_i_rdidx,// 当前派遣指令的结果寄存器的索引
  input  [`E203_PC_SIZE    -1:0] disp_i_pc,//当前派遣指令的 PC

  output oitfrd_match_disprs1,//派遣指令源操作数一和 OITF任一表项中的结果寄存器相同
  output oitfrd_match_disprs2,//派遣指令源操作数二和 OITF任一表项中的结果寄存器相同
  output oitfrd_match_disprs3,//派遣指令源操作数三和 OITF 任一表项中的结果寄存器相同
  output oitfrd_match_disprd,//派遣指令结果寄存器和OITF任一表项中的结果寄存器相同

  output oitf_empty,
  input  clk,
  input  rst_n
);

  wire [`E203_OITF_DEPTH-1:0] vld_set;
  wire [`E203_OITF_DEPTH-1:0] vld_clr;
  wire [`E203_OITF_DEPTH-1:0] vld_ena;
  wire [`E203_OITF_DEPTH-1:0] vld_nxt;
  wire [`E203_OITF_DEPTH-1:0] vld_r; //各表项中是否存放了有效指令的指示信号
  wire [`E203_OITF_DEPTH-1:0] rdwen_r;//各表项中指令是否写回结果寄存器
  wire [`E203_OITF_DEPTH-1:0] rdfpu_r;//各表项中指令写回的结果寄存器是否属于浮点
  wire [`E203_RFIDX_WIDTH-1:0] rdidx_r[`E203_OITF_DEPTH-1:0];//各表项中指令的结果寄存器索引
  // The PC here is to be used at wback stage to track out the
  //  PC of exception of long-pipe instruction
  wire [`E203_PC_SIZE-1:0] pc_r[`E203_OITF_DEPTH-1:0];//各表项中指令的 PC
// 由于 TF 本质上是一个 FIFO ，因此需要生成 FO 的写指针
  wire alc_ptr_ena = dis_ena;//派遣 个长指令的使能信号 作为写指针的便能信号
  wire ret_ptr_ena = ret_ena;//写回 个长指令的便能信号，作为 卖指针的使能信号

  wire oitf_full ;
  
  wire [`E203_ITAG_WIDTH-1:0] alc_ptr_r;
  wire [`E203_ITAG_WIDTH-1:0] ret_ptr_r;

  generate
  if(`E203_OITF_DEPTH > 1) begin: depth_gt1//{
     //与常规的 FIFO设计一样，为了方便维护空满标志，为写指针增加额外的一个标志位
      wire alc_ptr_flg_r;
      wire alc_ptr_flg_nxt = ~alc_ptr_flg_r;
      wire alc_ptr_flg_ena = (alc_ptr_r == ($unsigned(`E203_OITF_DEPTH-1))) & alc_ptr_ena;
      
      sirv_gnrl_dfflr #(1) alc_ptr_flg_dfflrs(alc_ptr_flg_ena, alc_ptr_flg_nxt, alc_ptr_flg_r, clk, rst_n);
      
      wire [`E203_ITAG_WIDTH-1:0] alc_ptr_nxt; 
       //每次分配一个表项，写指针自增 1，如果达到了 FIFO 的深度值，写指针归零
      assign alc_ptr_nxt = alc_ptr_flg_ena ? `E203_ITAG_WIDTH'b0 : (alc_ptr_r + 1'b1);
      
      sirv_gnrl_dfflr #(`E203_ITAG_WIDTH) alc_ptr_dfflrs(alc_ptr_ena, alc_ptr_nxt, alc_ptr_r, clk, rst_n);
      
      //与常规的 FIFO 设计一样，为了方便维护空满标志，为读指针增加额外的一个标志位
      wire ret_ptr_flg_r;
      wire ret_ptr_flg_nxt = ~ret_ptr_flg_r;
      wire ret_ptr_flg_ena = (ret_ptr_r == ($unsigned(`E203_OITF_DEPTH-1))) & ret_ptr_ena;
      
      sirv_gnrl_dfflr #(1) ret_ptr_flg_dfflrs(ret_ptr_flg_ena, ret_ptr_flg_nxt, ret_ptr_flg_r, clk, rst_n);
      
      wire [`E203_ITAG_WIDTH-1:0] ret_ptr_nxt; 
      //每次移除一个表项，读指针自增 1，如果达到了 FIFO 的深度值，读指针归零
      assign ret_ptr_nxt = ret_ptr_flg_ena ? `E203_ITAG_WIDTH'b0 : (ret_ptr_r + 1'b1);

      sirv_gnrl_dfflr #(`E203_ITAG_WIDTH) ret_ptr_dfflrs(ret_ptr_ena, ret_ptr_nxt, ret_ptr_r, clk, rst_n);
     //／／生成 fifo 的空满标志
      assign oitf_empty = (ret_ptr_r == alc_ptr_r) &   (ret_ptr_flg_r == alc_ptr_flg_r);
      assign oitf_full  = (ret_ptr_r == alc_ptr_r) & (~(ret_ptr_flg_r == alc_ptr_flg_r));
  end//}
  else begin: depth_eq1//}{
      assign alc_ptr_r =1'b0;
      assign ret_ptr_r =1'b0;
      assign oitf_empty = ~vld_r[0];
      assign oitf_full  = vld_r[0];
  end//}
  endgenerate//}

  assign ret_ptr = ret_ptr_r;
  assign dis_ptr = alc_ptr_r;

 //// 
 //// // If the OITF is not full, or it is under retiring, then it is ready to accept new dispatch
 //// assign dis_ready = (~oitf_full) | ret_ena;
 // To cut down the loop between ALU write-back valid --> oitf_ret_ena --> oitf_ready ---> dispatch_ready --- > alu_i_valid
 //   we exclude the ret_ena from the ready signal
 assign dis_ready = (~oitf_full);
  
  wire [`E203_OITF_DEPTH-1:0] rd_match_rs1idx;
  wire [`E203_OITF_DEPTH-1:0] rd_match_rs2idx;
  wire [`E203_OITF_DEPTH-1:0] rd_match_rs3idx;
  wire [`E203_OITF_DEPTH-1:0] rd_match_rdidx;

  genvar i;
  generate //{//使用参数化的 generate 语法实现 FIFO的主体部分
      for (i=0; i<`E203_OITF_DEPTH; i=i+1) begin:oitf_entries//{
       //生成各表项中是否存放了有效指令的指示信号
       //每次分配一个表项时,且写指针与当前表项编号一样,则将该表项的有效信号设置为高
        assign vld_set[i] = alc_ptr_ena & (alc_ptr_r == i);
         //每次移除一个表项时，且读指针与当前表项编号一样，则将该表项的有效信号清除为低
        assign vld_clr[i] = ret_ptr_ena & (ret_ptr_r == i);
        assign vld_ena[i] = vld_set[i] |   vld_clr[i];
        assign vld_nxt[i] = vld_set[i] | (~vld_clr[i]);
  
        sirv_gnrl_dfflr #(1) vld_dfflrs(vld_ena[i], vld_nxt[i], vld_r[i], clk, rst_n);
        //Payload only set, no need to clear
        //其他的表项信息，均可视为该表项的载荷（Payload），只需要在表项分配时写入，在
        //表项移除时无需清除（为了节省动态功耗，请参见第 15 章了解更多低功耗设计的诀窍）
        sirv_gnrl_dffl #(`E203_RFIDX_WIDTH) rdidx_dfflrs(vld_set[i], disp_i_rdidx, rdidx_r[i], clk);//各表项中指令的结果寄存器索引
        sirv_gnrl_dffl #(`E203_PC_SIZE    ) pc_dfflrs   (vld_set[i], disp_i_pc   , pc_r[i]   , clk);//各表项中指令的 PC
        sirv_gnrl_dffl #(1)                 rdwen_dfflrs(vld_set[i], disp_i_rdwen, rdwen_r[i], clk);//各表项中指令是否需要写回结果寄存器
        sirv_gnrl_dffl #(1)                 rdfpu_dfflrs(vld_set[i], disp_i_rdfpu, rdfpu_r[i], clk);//各表项中指令写回的结果寄存器是否属于浮点
       //将正在派遣的指令的源操作数寄存器索引和各表项中的结果寄存器索引进行比较
        assign rd_match_rs1idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs1en & (rdfpu_r[i] == disp_i_rs1fpu) & (rdidx_r[i] == disp_i_rs1idx);
        assign rd_match_rs2idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs2en & (rdfpu_r[i] == disp_i_rs2fpu) & (rdidx_r[i] == disp_i_rs2idx);
        assign rd_match_rs3idx[i] = vld_r[i] & rdwen_r[i] & disp_i_rs3en & (rdfpu_r[i] == disp_i_rs3fpu) & (rdidx_r[i] == disp_i_rs3idx);
        assign rd_match_rdidx [i] = vld_r[i] & rdwen_r[i] & disp_i_rdwen & (rdfpu_r[i] == disp_i_rdfpu ) & (rdidx_r[i] == disp_i_rdidx );
       //将正在派遣的指令的结果寄存器索引和各表项中的结果寄存器索引进行比较
      end//}
  endgenerate//}

  assign oitfrd_match_disprs1 = |rd_match_rs1idx;//派遣指令源操作数一和OITF任一表项中的结果寄存器相同,表示存在着RAw相关性
  assign oitfrd_match_disprs2 = |rd_match_rs2idx;//派遣指令源操作数二和OITF任一表项中的结果寄存器相同,表示存在着RAw相关性
  assign oitfrd_match_disprs3 = |rd_match_rs3idx;//派遣指令源操作数三和OITF任一表项中的结果寄存器相同,表示存在着RAw相关性
  assign oitfrd_match_disprd  = |rd_match_rdidx ;//派遣指令结果寄存器和OITF任一表项中的结果寄存器相同,表示存在着wAw相关性

  assign ret_rdidx = rdidx_r[ret_ptr];
  assign ret_pc    = pc_r [ret_ptr];
  assign ret_rdwen = rdwen_r[ret_ptr];
  assign ret_rdfpu = rdfpu_r[ret_ptr];

endmodule


