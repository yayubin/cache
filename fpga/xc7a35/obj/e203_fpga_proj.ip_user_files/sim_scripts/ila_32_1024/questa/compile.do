vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm

vlog -work xil_defaultlib -64 -sv "+incdir+../../../../e203_fpga_proj.srcs/sources_1/ip/ila_32_1024/hdl/verilog" \
"D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../../e203_fpga_proj.srcs/sources_1/ip/ila_32_1024/hdl/verilog" \
"../../../../e203_fpga_proj.srcs/sources_1/ip/ila_32_1024/sim/ila_32_1024.v" \

vlog -work xil_defaultlib \
"glbl.v"

