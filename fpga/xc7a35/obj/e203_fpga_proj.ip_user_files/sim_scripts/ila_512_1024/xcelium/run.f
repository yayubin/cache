-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../e203_fpga_proj.srcs/sources_1/ip/ila_512_1024/sim/ila_512_1024.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

