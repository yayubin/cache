#set top_v "aic_rv32"
set top_v "e203_soc_top"

##################################################################################
#如果是组合逻辑没有时钟 virtual_clk_en 要设为1
#set virtual_clk_en  1
set virtual_clk_en  0

set clk_port_name   "hfextclk"
#120M
set clk_period      8
##################################################################################

#file mkdir ./work     
file mkdir ../work  



define_design_lib WORK -path ../work


#sh rm -rf report
#file mkdir ./report

set report "report_"
set report_file $report$top_v

#sh rm -rf $report_file
#file mkdir ./$report_file

sh rm -rf ../$report_file
file mkdir ../$report_file


##################################################################################
#reset_design
remove_design -all
set_app_var link_library ../lib/Synopsys/smic18_ff.db
set_app_var target_library ../lib/Synopsys/smic18_ff.db

##################################################################################
cd ../../rtl/e203/soc
set_app_var search_path "$search_path [pwd]"
set vv "[glob *.v]"

cd ../core
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../debug
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../fab
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../general
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../mems
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../subsys
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../perips
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ./apb_adv_timer
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../apb_gpio
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../apb_i2c
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../apb_spi_master
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../apb_uart
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../sha256
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../sm3
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../sm2
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../smx_apb
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../../../../dc/dc_obj

#---------------------------

if 0 {



cd ../E203_RTL
cd top
set_app_var search_path "$search_path [pwd]"
set vv "[glob *.v]"


cd ../core
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../debug
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../fab
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../general
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../mems
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../soc
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../subsys
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../perips
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"


#-----------------------------
cd apb_adv_timer
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../apb_gpio
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../apb_i2c
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../apb_spi_master
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../apb_uart
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../sha256
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../sm3
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../sm2
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

cd ../sm4
set_app_var search_path "$search_path [pwd]"
set vv "$vv [glob *.v]"

##################################################################################
cd ../../../dc
##################################################################################
}

puts $vv
#read_file -format verilog $vv
analyze -format verilog $vv > ../$report_file/analyze.txt
#elaborate aic_rv32_compile > ./report/elaborate.txt
#current_design aic_rv32_compile
elaborate $top_v > ../$report_file/elaborate.txt
current_design $top_v


    
#link > ./report/report_link.txt
if {[link > ../$report_file/report_link.txt] == 0} {
    echo "Your Link has errors !";
    exit;
}

##################################################################################

#create_clock -name "clk" -period $clk_period [get_ports clk]

#set_clock_uncertainty -setup 0.15 [get_ports clk]

#set_clock_transition 0.12 [get_clocks clk]

#set_input_delay -max 3 -clock clk [all_inputs]
#set_output_delay -max 3 -clock clk [all_outputs]
if {$virtual_clk_en == 1} {
   create_clock -name "clk" -period $clk_period 
} else {
   create_clock -name "clk" -period $clk_period  [get_ports $clk_port_name] 
  #  create_clock -name "clk" -period $clk_period -waveform {4 8}  [get_ports $clk_port_name] 
}
set_clock_uncertainty -setup 0.15 clk

set_input_delay -max 0 -clock clk [all_inputs]
set_output_delay -max 0 -clock clk [all_outputs]
#set_output_delay -max -30 -clock clk [all_outputs]

#if 0 {

#set_false_path -from [get_pins u_e203_subsys_top/u_e203_subsys_main/u_e203_subsys_hclkgen/u_e203_subsys_pllclkdiv/u_pllclkdiv_clkgate/enb_reg/GN] -to [get_pins u_e203_subsys_top/io_pads_gpioA_o_oval[27]]
#set_false_path -from [get_nets u_e203_subsys_top/u_e203_subsys_main/u_e203_subsys_hclkgen/u_e203_subsys_pllclkdiv/u_pllclkdiv_clkgate/enb] -to [get_pins u_e203_subsys_top/io_pads_gpioA_o_oval[27]]

remove_input_delay [get_ports $clk_port_name]






create_clock -name "clk2" -period 10000  [get_ports lfextclk] 
remove_input_delay [get_ports lfextclk]


#set_false_path -from [get_pins u_e203_subsys_top/u_e203_subsys_main/u_e203_subsys_hclkgen/u_e203_subsys_pllclkdiv/u_pllclkdiv_clkgate/clk_out] -to [get_pins u_e203_subsys_top/io_pads_gpioA_o_oval[27]]

set_false_path -through [get_ports u_e203_subsys_top/u_e203_subsys_main/u_e203_cpu_top/inspect_core_clk]
##################################################################################


#check_design > ./report/check_design.txt
if {[check_design > ../$report_file/check_design.txt]==0} {
    echo "Your check_design has errors !";
    exit;
}

#compile > ./report/compile.txt
if {[compile > ../$report_file/compile.txt]==0} {
    echo "Your compile has errors !";
    exit;
}
#compile_ultra -incremental -timing_high_effort_script

report_timing > ../$report_file/report_timing.txt
report_are > ../$report_file/report_are.txt
report_clock > ../$report_file/report_clock.txt
#write_file -format verilog -output ./report/netlist.v
write -format verilog -hier -o ../$report_file/netlist.v
write_sdc ../$report_file/top.sdc
write_sdf ../$report_file/top.sdf
write -f ddc -hier -output ../$report_file/top_ddc.ddc
#write -format ddc -hier -o ./report/top_ddc.ddc
write -f verilog -hier -output ../$report_file/top_design.gv

list_designs > ../$report_file/list_designs.txt
report_qor > ../$report_file/report_qor.txt
check_design > ../$report_file/check_design.txt

echo "synthesis Successful";

##################################################################################
#}
