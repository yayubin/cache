// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Feb 22 10:00:25 2024
// Host        : ZhouMiao running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/yanyebin/risc/puf_risc/e203_hbirdv2-master/fpga/xc7a35/obj/e203_fpga_proj.srcs/sources_1/ip/ila_128_1024/ila_128_1024_stub.v
// Design      : ila_128_1024
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2018.3" *)
module ila_128_1024(clk, probe0)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[127:0]" */;
  input clk;
  input [127:0]probe0;
endmodule
