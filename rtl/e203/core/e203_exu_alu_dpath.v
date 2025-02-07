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
//  This module to implement the datapath of ALU
//
// ====================================================================
`include "e203_defines.v"
//此模块作为ALU的共享数据通路,其中主要包含了一个加法器。ALU所处理的所有指令的实际运算均由此模块的数据通路执行。
module e203_exu_alu_dpath(

  //////////////////////////////////////////////////////
  // ALU request the datapath//RV32I的指令集
  input  alu_req_alu,

  input  alu_req_alu_add ,
  input  alu_req_alu_sub ,
  input  alu_req_alu_xor ,
  input  alu_req_alu_sll ,
  input  alu_req_alu_srl ,
  input  alu_req_alu_sra ,
  input  alu_req_alu_or  ,
  input  alu_req_alu_and ,
  input  alu_req_alu_slt ,
  input  alu_req_alu_sltu,
  input  alu_req_alu_lui ,
  input  [`E203_XLEN-1:0] alu_req_alu_op1,
  input  [`E203_XLEN-1:0] alu_req_alu_op2,

  output [`E203_XLEN-1:0] alu_req_alu_res,

  //////////////////////////////////////////////////////
  // BJP request the datapath//RV32I的指令集
  input  bjp_req_alu,

  input  [`E203_XLEN-1:0] bjp_req_alu_op1,
  input  [`E203_XLEN-1:0] bjp_req_alu_op2,
  input  bjp_req_alu_cmp_eq ,
  input  bjp_req_alu_cmp_ne ,
  input  bjp_req_alu_cmp_lt ,
  input  bjp_req_alu_cmp_gt ,
  input  bjp_req_alu_cmp_ltu,
  input  bjp_req_alu_cmp_gtu,
  input  bjp_req_alu_add,

  output bjp_req_alu_cmp_res,
  output [`E203_XLEN-1:0] bjp_req_alu_add_res,

  //////////////////////////////////////////////////////
  // AGU request the datapath//RV32A的指令集
  input  agu_req_alu,

  input  [`E203_XLEN-1:0] agu_req_alu_op1,
  input  [`E203_XLEN-1:0] agu_req_alu_op2,
  input  agu_req_alu_swap,
  input  agu_req_alu_add ,
  input  agu_req_alu_and ,
  input  agu_req_alu_or  ,
  input  agu_req_alu_xor ,
  input  agu_req_alu_max ,
  input  agu_req_alu_min ,
  input  agu_req_alu_maxu,
  input  agu_req_alu_minu,

  output [`E203_XLEN-1:0] agu_req_alu_res,

  input  agu_sbf_0_ena,
  input  [`E203_XLEN-1:0] agu_sbf_0_nxt,
  output [`E203_XLEN-1:0] agu_sbf_0_r,

  input  agu_sbf_1_ena,
  input  [`E203_XLEN-1:0] agu_sbf_1_nxt,
  output [`E203_XLEN-1:0] agu_sbf_1_r,

`ifdef E203_SUPPORT_SHARE_MULDIV //{
  //////////////////////////////////////////////////////
  // MULDIV request the datapath//RV32M的指令集
  input  muldiv_req_alu,

  input  [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op1,
  input  [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_op2,
  input                              muldiv_req_alu_add,
  input                              muldiv_req_alu_sub,
  output [`E203_ALU_ADDER_WIDTH-1:0] muldiv_req_alu_res,

  input           muldiv_sbf_0_ena,
  input  [33-1:0] muldiv_sbf_0_nxt,
  output [33-1:0] muldiv_sbf_0_r,

  input           muldiv_sbf_1_ena,
  input  [33-1:0] muldiv_sbf_1_nxt,
  output [33-1:0] muldiv_sbf_1_r,
`endif//E203_SUPPORT_SHARE_MULDIV}

  input  clk,
  input  rst_n
  );

  `ifdef E203_XLEN_IS_32
      // This is the correct config since E200 is 32bits core
  `else
      !!! ERROR: There must be something wrong, our core must be 32bits wide !!!
  `endif

  wire [`E203_XLEN-1:0] mux_op1;
  wire [`E203_XLEN-1:0] mux_op2;
////将Mux选择后的操作数送入加法器通路
  wire [`E203_XLEN-1:0] misc_op1 = mux_op1[`E203_XLEN-1:0];
  wire [`E203_XLEN-1:0] misc_op2 = mux_op2[`E203_XLEN-1:0];

  // Only the regular ALU use shifter
  wire [`E203_XLEN-1:0] shifter_op1 = alu_req_alu_op1[`E203_XLEN-1:0];
  wire [`E203_XLEN-1:0] shifter_op2 = alu_req_alu_op2[`E203_XLEN-1:0];

  wire op_max;  
  wire op_min ; 
  wire op_maxu;
  wire op_minu;

  wire op_add;
  wire op_sub;
  wire op_addsub = op_add | op_sub; 

  wire op_or;
  wire op_xor;
  wire op_and;

  wire op_sll;
  wire op_srl;
  wire op_sra;

  wire op_slt;
  wire op_sltu;

  wire op_mvop2;


  wire op_cmp_eq ;
  wire op_cmp_ne ;
  wire op_cmp_lt ;
  wire op_cmp_gt ;
  wire op_cmp_ltu;
  wire op_cmp_gtu;

  wire cmp_res;

  wire sbf_0_ena;
  wire [33-1:0] sbf_0_nxt;
  wire [33-1:0] sbf_0_r;

  wire sbf_1_ena;
  wire [33-1:0] sbf_1_nxt;
  wire [33-1:0] sbf_1_r;


  //////////////////////////////////////////////////////////////
  // Impelment the Left-Shifter
  //
  // The Left-Shifter will be used to handle the shift op
  wire [`E203_XLEN-1:0] shifter_in1;
  wire [5-1:0] shifter_in2;
  wire [`E203_XLEN-1:0] shifter_res;


  wire op_shift = op_sra | op_sll | op_srl; 
  
     // Make sure to use logic-gating to gateoff the 
      //为了节省面积开销，将右移统一转化为左移操作
  assign shifter_in1 = {`E203_XLEN{op_shift}} &
          //   In order to save area and just use one left-shifter, we
          //   convert the right-shift op into left-shift operation
           (
               (op_sra | op_srl) ? 
                 {
    shifter_op1[00],shifter_op1[01],shifter_op1[02],shifter_op1[03],
    shifter_op1[04],shifter_op1[05],shifter_op1[06],shifter_op1[07],
    shifter_op1[08],shifter_op1[09],shifter_op1[10],shifter_op1[11],
    shifter_op1[12],shifter_op1[13],shifter_op1[14],shifter_op1[15],
    shifter_op1[16],shifter_op1[17],shifter_op1[18],shifter_op1[19],
    shifter_op1[20],shifter_op1[21],shifter_op1[22],shifter_op1[23],
    shifter_op1[24],shifter_op1[25],shifter_op1[26],shifter_op1[27],
    shifter_op1[28],shifter_op1[29],shifter_op1[30],shifter_op1[31]
                 } : shifter_op1
           );
  assign shifter_in2 = {5{op_shift}} & shifter_op2[4:0];

  assign shifter_res = (shifter_in1 << shifter_in2);

  wire [`E203_XLEN-1:0] sll_res = shifter_res;
  wire [`E203_XLEN-1:0] srl_res =  
                 {
    shifter_res[00],shifter_res[01],shifter_res[02],shifter_res[03],
    shifter_res[04],shifter_res[05],shifter_res[06],shifter_res[07],
    shifter_res[08],shifter_res[09],shifter_res[10],shifter_res[11],
    shifter_res[12],shifter_res[13],shifter_res[14],shifter_res[15],
    shifter_res[16],shifter_res[17],shifter_res[18],shifter_res[19],
    shifter_res[20],shifter_res[21],shifter_res[22],shifter_res[23],
    shifter_res[24],shifter_res[25],shifter_res[26],shifter_res[27],
    shifter_res[28],shifter_res[29],shifter_res[30],shifter_res[31]
                 };
  
  wire [`E203_XLEN-1:0] eff_mask = (~(`E203_XLEN'b0)) >> shifter_in2;
  wire [`E203_XLEN-1:0] sra_res =
               (srl_res & eff_mask) | ({32{shifter_op1[31]}} & (~eff_mask));



  //////////////////////////////////////////////////////////////
  // Impelment the Adder
  //
  // The Adder will be reused to handle the add/sub/compare op

     // Only the MULDIV request ALU-adder with 35bits operand with sign extended 
     // already, all other unit request ALU-adder with 32bits opereand without sign extended
     //   For non-MULDIV operands
  wire op_unsigned = op_sltu | op_cmp_ltu | op_cmp_gtu | op_maxu | op_minu;
  //生成加法器的操作数
  wire [`E203_ALU_ADDER_WIDTH-1:0] misc_adder_op1 =
      {{`E203_ALU_ADDER_WIDTH-`E203_XLEN{(~op_unsigned) & misc_op1[`E203_XLEN-1]}},misc_op1};
  wire [`E203_ALU_ADDER_WIDTH-1:0] misc_adder_op2 =
      {{`E203_ALU_ADDER_WIDTH-`E203_XLEN{(~op_unsigned) & misc_op2[`E203_XLEN-1]}},misc_op2};


  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_op1 = 
`ifdef E203_SUPPORT_SHARE_MULDIV //{
      muldiv_req_alu ? muldiv_req_alu_op1 :
`endif//E203_SUPPORT_SHARE_MULDIV}
      misc_adder_op1;
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_op2 = 
`ifdef E203_SUPPORT_SHARE_MULDIV //{
      muldiv_req_alu ? muldiv_req_alu_op2 :
`endif//E203_SUPPORT_SHARE_MULDIV}
      misc_adder_op2;

  wire adder_cin;
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_in1;
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_in2;
  wire [`E203_ALU_ADDER_WIDTH-1:0] adder_res;

//判断所需的是加法还是减法操作
  wire adder_add;
  wire adder_sub;

  assign adder_add =
`ifdef E203_SUPPORT_SHARE_MULDIV //{
      muldiv_req_alu ? muldiv_req_alu_add :
`endif//E203_SUPPORT_SHARE_MULDIV}
      op_add; 
  assign adder_sub =
`ifdef E203_SUPPORT_SHARE_MULDIV //{
      muldiv_req_alu ? muldiv_req_alu_sub :
`endif//E203_SUPPORT_SHARE_MULDIV}
               (
                   // The original sub instruction
               (op_sub) 
                   // The compare lt or gt instruction
             | (op_cmp_lt | op_cmp_gt | 
                op_cmp_ltu | op_cmp_gtu |
                op_max | op_maxu |
                op_min | op_minu |
                op_slt | op_sltu 
               ));

  wire adder_addsub = adder_add | adder_sub; 
  
//复用“加法器” //复用“加法器”进行比大小运算
//假设当前的操作不是加法或者减法操作,则将加法器的输入门控(Gate)住以节省动态功耗
     // Make sure to use logic-gating to gateoff the 
  assign adder_in1 = {`E203_ALU_ADDER_WIDTH{adder_addsub}} & (adder_op1);
  assign adder_in2 = {`E203_ALU_ADDER_WIDTH{adder_addsub}} & (adder_sub ? (~adder_op2) : adder_op2);
  assign adder_cin = adder_addsub & adder_sub;

  assign adder_res = adder_in1 + adder_in2 + adder_cin;//加法器，//+adder_cin是补码取反加一//使用取反加一的方式将补码减法转换成加法操作



  //////////////////////////////////////////////////////////////
  // Impelment the XOR-er
  //
  // The XOR-er will be reused to handle the XOR and compare op

  wire [`E203_XLEN-1:0] xorer_in1;
  wire [`E203_XLEN-1:0] xorer_in2;

  wire xorer_op = 
               op_xor
                   // The compare eq or ne instruction
             | (op_cmp_eq | op_cmp_ne); 

     // Make sure to use logic-gating to gateoff the 
    //复用“异或逻辑门”进行相等比较运算
  assign xorer_in1 = {`E203_XLEN{xorer_op}} & misc_op1;
  assign xorer_in2 = {`E203_XLEN{xorer_op}} & misc_op2;

  wire [`E203_XLEN-1:0] xorer_res = xorer_in1 ^ xorer_in2;
     // The OR and AND is too light-weight, so no need to gate off
  wire [`E203_XLEN-1:0] orer_res  = misc_op1 | misc_op2; 
  wire [`E203_XLEN-1:0] ander_res = misc_op1 & misc_op2; 


  //////////////////////////////////////////////////////////////
  // Generate the CMP operation result
       // It is Non-Equal if the XOR result have any bit non-zero
  wire neq  = (|xorer_res); 
  wire cmp_res_ne  = (op_cmp_ne  & neq);
       // It is Equal if it is not Non-Equal
  wire cmp_res_eq  = op_cmp_eq  & (~neq);
       // It is Less-Than if the adder result is negative
  wire cmp_res_lt  = op_cmp_lt  & adder_res[`E203_XLEN];
  wire cmp_res_ltu = op_cmp_ltu & adder_res[`E203_XLEN];
       // It is Greater-Than if the adder result is postive
  wire op1_gt_op2  = (~adder_res[`E203_XLEN]);
  wire cmp_res_gt  = op_cmp_gt  & op1_gt_op2;
  wire cmp_res_gtu = op_cmp_gtu & op1_gt_op2;

  assign cmp_res = cmp_res_eq 
                 | cmp_res_ne 
                 | cmp_res_lt 
                 | cmp_res_gt  
                 | cmp_res_ltu 
                 | cmp_res_gtu; 

  //////////////////////////////////////////////////////////////
  // Generate the mvop2 result
  //   Just directly use op2 since the op2 will be the immediate
  wire [`E203_XLEN-1:0] mvop2_res = misc_op2;

  //////////////////////////////////////////////////////////////
  // Generate the SLT and SLTU result
  //   Just directly use op2 since the op2 will be the immediate
  wire op_slttu = (op_slt | op_sltu);
  //   The SLT and SLTU is reusing the adder to do the comparasion
       // It is Less-Than if the adder result is negative
  wire slttu_cmp_lt = op_slttu & adder_res[`E203_XLEN];
  wire [`E203_XLEN-1:0] slttu_res = 
               slttu_cmp_lt ?
               `E203_XLEN'b1 : `E203_XLEN'b0;

  //////////////////////////////////////////////////////////////
  // Generate the Max/Min result
  wire maxmin_sel_op1 =  ((op_max | op_maxu) &   op1_gt_op2) 
                      |  ((op_min | op_minu) & (~op1_gt_op2));

  wire [`E203_XLEN-1:0] maxmin_res  = maxmin_sel_op1 ? misc_op1 : misc_op2;  

  //////////////////////////////////////////////////////////////
  // Generate the final result
    //生成最终的运算数据通路结果,使用and-or的编码方式生成多路选择器
  wire [`E203_XLEN-1:0] alu_dpath_res = 
        ({`E203_XLEN{op_or       }} & orer_res )
      | ({`E203_XLEN{op_and      }} & ander_res)
      | ({`E203_XLEN{op_xor      }} & xorer_res)
      | ({`E203_XLEN{op_addsub   }} & adder_res[`E203_XLEN-1:0])
      | ({`E203_XLEN{op_srl      }} & srl_res)
      | ({`E203_XLEN{op_sll      }} & sll_res)
      | ({`E203_XLEN{op_sra      }} & sra_res)
      | ({`E203_XLEN{op_mvop2    }} & mvop2_res)
      | ({`E203_XLEN{op_slttu    }} & slttu_res)
      | ({`E203_XLEN{op_max | op_maxu | op_min | op_minu}} & maxmin_res)
        ;

  //////////////////////////////////////////////////////////////
   //实现AGU 和 MDV 模块共享的两份33位宽的寄存器
  // Implement the SBF: Shared Buffers
  sirv_gnrl_dffl #(33) sbf_0_dffl (sbf_0_ena, sbf_0_nxt, sbf_0_r, clk);
  sirv_gnrl_dffl #(33) sbf_1_dffl (sbf_1_ena, sbf_1_nxt, sbf_1_r, clk);

  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////
  //  The ALU-Datapath Mux for the requestors 

  localparam DPATH_MUX_WIDTH = ((`E203_XLEN*2)+21);
//不同的模块公用 ALU 的运算数据通路
  assign  {
     mux_op1
    ,mux_op2
    ,op_max  
    ,op_min  
    ,op_maxu 
    ,op_minu 
    ,op_add
    ,op_sub
    ,op_or
    ,op_xor
    ,op_and
    ,op_sll
    ,op_srl
    ,op_sra
    ,op_slt
    ,op_sltu
    ,op_mvop2
    ,op_cmp_eq 
    ,op_cmp_ne 
    ,op_cmp_lt 
    ,op_cmp_gt 
    ,op_cmp_ltu
    ,op_cmp_gtu
    }
    = 
        ({DPATH_MUX_WIDTH{alu_req_alu}} & {//来自 Regular-ALU 子单元的运算请求
             alu_req_alu_op1
            ,alu_req_alu_op2
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,alu_req_alu_add
            ,alu_req_alu_sub
            ,alu_req_alu_or
            ,alu_req_alu_xor
            ,alu_req_alu_and
            ,alu_req_alu_sll
            ,alu_req_alu_srl
            ,alu_req_alu_sra
            ,alu_req_alu_slt
            ,alu_req_alu_sltu
            ,alu_req_alu_lui// LUI just move-Op2 operation
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
        })
      | ({DPATH_MUX_WIDTH{bjp_req_alu}} & {// 来自 BJP 子单元的运算请求
             bjp_req_alu_op1
            ,bjp_req_alu_op2
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,bjp_req_alu_add
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,bjp_req_alu_cmp_eq 
            ,bjp_req_alu_cmp_ne 
            ,bjp_req_alu_cmp_lt 
            ,bjp_req_alu_cmp_gt 
            ,bjp_req_alu_cmp_ltu
            ,bjp_req_alu_cmp_gtu

        })
      | ({DPATH_MUX_WIDTH{agu_req_alu}} & {//来自 AGU 模块的运算请求
             agu_req_alu_op1
            ,agu_req_alu_op2
            ,agu_req_alu_max  
            ,agu_req_alu_min  
            ,agu_req_alu_maxu 
            ,agu_req_alu_minu 
            ,agu_req_alu_add
            ,1'b0
            ,agu_req_alu_or
            ,agu_req_alu_xor
            ,agu_req_alu_and
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,agu_req_alu_swap// SWAP just move-Op2 operation
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
            ,1'b0
        })
        ;
  
  assign alu_req_alu_res     = alu_dpath_res[`E203_XLEN-1:0];
  assign agu_req_alu_res     = alu_dpath_res[`E203_XLEN-1:0];//将ALU的加法器计算结果返回给AGU
  assign bjp_req_alu_add_res = alu_dpath_res[`E203_XLEN-1:0];
  assign bjp_req_alu_cmp_res = cmp_res;//将比较器的计算结果返回给 e203_exu_alu_bjp 模块
`ifdef E203_SUPPORT_SHARE_MULDIV //{
  assign muldiv_req_alu_res  = adder_res;
`endif//E203_SUPPORT_SHARE_MULDIV}
//寄存器的使能信号选择来自 MDV 还是 AGU 模块
  assign sbf_0_ena = 
`ifdef E203_SUPPORT_SHARE_MULDIV //{
      muldiv_req_alu ? muldiv_sbf_0_ena : 
`endif//E203_SUPPORT_SHARE_MULDIV}
                 agu_sbf_0_ena;
  assign sbf_1_ena = 
`ifdef E203_SUPPORT_SHARE_MULDIV //{
      muldiv_req_alu ? muldiv_sbf_1_ena : 
`endif//E203_SUPPORT_SHARE_MULDIV}
                 agu_sbf_1_ena;
//寄存器的写入数据选择来自 MDV 还是 AGU 模块
  assign sbf_0_nxt = 
`ifdef E203_SUPPORT_SHARE_MULDIV //{
      muldiv_req_alu ? muldiv_sbf_0_nxt : 
`endif//E203_SUPPORT_SHARE_MULDIV}
                 {1'b0,agu_sbf_0_nxt};
  assign sbf_1_nxt = 
`ifdef E203_SUPPORT_SHARE_MULDIV //{
      muldiv_req_alu ? muldiv_sbf_1_nxt : 
`endif//E203_SUPPORT_SHARE_MULDIV}
                 {1'b0,agu_sbf_1_nxt};
//将共享寄存器的值送给 AGU 模块
  assign agu_sbf_0_r = sbf_0_r[`E203_XLEN-1:0];
  assign agu_sbf_1_r = sbf_1_r[`E203_XLEN-1:0];
//将共享寄存器的值送给MDV 模块
`ifdef E203_SUPPORT_SHARE_MULDIV //{
  assign muldiv_sbf_0_r = sbf_0_r;
  assign muldiv_sbf_1_r = sbf_1_r;
`endif//E203_SUPPORT_SHARE_MULDIV}

endmodule                                      
                                               
                                               
                                               
