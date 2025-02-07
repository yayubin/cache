-makelib ies_lib/xil_defaultlib -sv \
  "D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../e203_fpga_proj.srcs/sources_1/ip/ila_128_1024/sim/ila_128_1024.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

