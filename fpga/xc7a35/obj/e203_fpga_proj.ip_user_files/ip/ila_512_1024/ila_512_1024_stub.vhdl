-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Thu Feb 22 10:08:54 2024
-- Host        : ZhouMiao running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/yanyebin/risc/puf_risc/e203_hbirdv2-master/fpga/xc7a35/obj/e203_fpga_proj.srcs/sources_1/ip/ila_512_1024/ila_512_1024_stub.vhdl
-- Design      : ila_512_1024
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tfbg484-2L
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_512_1024 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 511 downto 0 )
  );

end ila_512_1024;

architecture stub of ila_512_1024 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[511:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "ila,Vivado 2018.3";
begin
end;
