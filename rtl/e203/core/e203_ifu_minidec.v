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
//  The mini-decode module to decode the instruction in IFU 
//
// ====================================================================
`include "e203_defines.v"
//译码功能//dec : miniDecoder缩写（小型译码器）
module e203_ifu_minidec(

  //////////////////////////////////////////////////////////////
  // The IR stage to Decoder
  input  [`E203_INSTR_SIZE-1:0]  instr,// Response instruction //响应指令//对这个指令进行译码
  
  //////////////////////////////////////////////////////////////
  // The Decoded Info-Bus


  output                         dec_rs1en,//需要读取原操作数1
  output                         dec_rs2en,//需要读取原操作数2
  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx,//该指令原操作数1的寄存器索引//这里的index就是原操作数寄存器在cpu内部总线上的地址
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx,//该指令原操作数2的寄存器索引

  output                         dec_mulhsu,//指令是mulshu指令// mul-high-signed-unsigned rs1有符号，rs2无符号，相乘结果(64bit)的高32bit放入rd
  output                         dec_mul   ,//指令是乘法指令// mul rs1无符号，rs2无符号，(有符号无符号其实是一样的)相乘结果(64bit)的低32bit放入rd
  output                         dec_div   ,//指令是除法指令// div rs1有符号，rs2有符号
  output                         dec_rem   ,//指令是取余指令// 取  rs1有符号与rs2有符号数，取余数送到rd；
  output                         dec_divu  ,//指令是无符号除法指令// 无符号取商送rd
  output                         dec_remu  ,//指令是无符号取余指令// 无符号取余送d

  output                         dec_rv32,//指示当前指令为16位还是32位
  output                         dec_bjp, //指示当前指令属于普通指令不是分支跳转指令
  output                         dec_jal, //属于jal指令
  output                         dec_jalr,//属于jalr指令
  output                         dec_bxx, //属于bxx指令(beq、bne等条件分支指令)
  output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,//无条件间接跳转指令rs1的索引 5bit //针对jalr指令，其首先要取出rs1操作数，然后与立即数相加才能得到值+4作为新的pc，为了取rs1，指令里带了rs1的地址(cpu内部index)
  output [`E203_XLEN-1:0]        dec_bjp_imm //分支指令中的立即数 32bit //针对bxx指令，如果条件满足的话，会把12bit立即数(有符号)×2然后与pc相加，作为新的pc；这里是译码出的指令的立即数 

  );
//================================================================================
  e203_exu_decode u_e203_exu_decode(

  .i_instr(instr),
  .i_pc(`E203_PC_SIZE'b0),
  .i_prdt_taken(1'b0), 
  .i_muldiv_b2b(1'b0), 

  .i_misalgn (1'b0),
  .i_buserr  (1'b0),

  .dbg_mode  (1'b0),

  .dec_misalgn(),
  .dec_buserr(),
  .dec_ilegl(),

  .dec_rs1x0(),
  .dec_rs2x0(),
  .dec_rs1en(dec_rs1en),
  .dec_rs2en(dec_rs2en),
  .dec_rdwen(),
  .dec_rs1idx(dec_rs1idx),
  .dec_rs2idx(dec_rs2idx),
  .dec_rdidx(),
  .dec_info(),  
  .dec_imm(),
  .dec_pc(),

`ifdef E203_HAS_NICE//{
  .dec_nice   (),
  .nice_xs_off(1'b0),  
  .nice_cmt_off_ilgl_o(),
`endif//}

  .dec_mulhsu(dec_mulhsu),
  .dec_mul   (dec_mul   ),
  .dec_div   (dec_div   ),
  .dec_rem   (dec_rem   ),
  .dec_divu  (dec_divu  ),
  .dec_remu  (dec_remu  ),

  .dec_rv32(dec_rv32),
  .dec_bjp (dec_bjp ),
  .dec_jal (dec_jal ),
  .dec_jalr(dec_jalr),
  .dec_bxx (dec_bxx ),

  .dec_jalr_rs1idx(dec_jalr_rs1idx),
  .dec_bjp_imm    (dec_bjp_imm    )  
  );


endmodule
