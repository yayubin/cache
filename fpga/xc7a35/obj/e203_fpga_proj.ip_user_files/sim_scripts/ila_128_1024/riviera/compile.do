vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../e203_fpga_proj.srcs/sources_1/ip/ila_128_1024/hdl/verilog" \
"D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/Program/xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../e203_fpga_proj.srcs/sources_1/ip/ila_128_1024/hdl/verilog" \
"../../../../e203_fpga_proj.srcs/sources_1/ip/ila_128_1024/sim/ila_128_1024.v" \

vlog -work xil_defaultlib \
"glbl.v"

