# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param tcl.collectionResultDisplayLimit 0
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a200tfbg484-2L

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/obj/e203_fpga_proj.cache/wt [current_project]
set_property parent.project_path D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/obj/e203_fpga_proj.xpr [current_project]
set_property XPM_LIBRARIES XPM_CDC [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_repo_paths d:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/obj/ip [current_project]
update_ip_catalog
set_property ip_output_repo d:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/obj/e203_fpga_proj.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
set_property include_dirs D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/install/rtl/core [current_fileset]
read_verilog {
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/src/fpga_config.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_i2c/i2c_master_defines.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_defines.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/config.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/cache_config.v
}
set_property file_type "Verilog Header" [get_files D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/src/fpga_config.v]
set_property is_global_include true [get_files D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/src/fpga_config.v]
set_property file_type "Verilog Header" [get_files D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_i2c/i2c_master_defines.v]
set_property file_type "Verilog Header" [get_files D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_defines.v]
set_property file_type "Verilog Header" [get_files D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/config.v]
set_property file_type "Verilog Header" [get_files D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/cache_config.v]
read_verilog -library xil_defaultlib {
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_adv_timer/adv_timer_apb_if.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_adv_timer/apb_adv_timer.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_gpio/apb_gpio.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_i2c/apb_i2c.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_spi_master/apb_spi_master.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_uart/apb_uart.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/cache.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/cache_memory.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/src/clkdivider.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_adv_timer/comparator.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_biu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_clk_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_clkgate.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_core.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_cpu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_cpu_top.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_dtcm_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_dtcm_ram.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_alu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_alu_bjp.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_alu_csrctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_alu_dpath.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_alu_lsuagu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_alu_muldiv.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_alu_rglr.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_branchslv.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_commit.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_csr.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_decode.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_disp.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_excp.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_longpwbck.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_nice.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_oitf.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_regfile.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_exu_wbck.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_ifu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_ifu_ifetch.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_ifu_ift2icb.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_ifu_litebpu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_ifu_minidec.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_irq_sync.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_itcm_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_itcm_ram.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_lsu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_lsu_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_reset_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/soc/e203_soc_top.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/core/e203_srams.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_clint.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_gfcm.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_hclkgen.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_hclkgen_rstsync.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_main.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_mems.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_nice_core.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_perips.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_plic.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_pll.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_pllclkdiv.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/subsys/e203_subsys_top.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_i2c/i2c_master_bit_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_i2c/i2c_master_byte_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_adv_timer/input_stage.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_uart/io_generic_fifo.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/main_memory_flash.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_adv_timer/prescaler.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/sirv_1cyc_sram_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_AsyncResetReg.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_AsyncResetRegVec.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_AsyncResetRegVec_1.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_AsyncResetRegVec_129.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_AsyncResetRegVec_36.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_DeglitchShiftRegister.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_LevelGateway.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_ResetCatchAndSync.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_ResetCatchAndSync_2.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_aon.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_aon_lclkgen_regs.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_aon_porrst.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_aon_top.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_aon_wrapper.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_clint.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_clint_top.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/debug/sirv_debug_csr.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/debug/sirv_debug_module.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/debug/sirv_debug_ram.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/debug/sirv_debug_rom.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_expl_axi_slv.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_flash_qspi.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_flash_qspi_top.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/sirv_gnrl_bufs.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/sirv_gnrl_dffs.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/sirv_gnrl_icbs.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/sirv_gnrl_ram.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_hclkgen_regs.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/fab/sirv_icb1to16_bus.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/fab/sirv_icb1to2_bus.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/fab/sirv_icb1to8_bus.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/debug/sirv_jtag_dtm.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_jtaggpioport.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/mems/sirv_mrom.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/mems/sirv_mrom_top.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_plic_man.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_plic_top.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_pmu.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_pmu_core.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_qspi_arbiter.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_qspi_fifo.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_qspi_media.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_qspi_physical.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_queue.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_queue_1.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_repeater_6.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_rtc.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/sirv_sim_ram.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_spi_flashmap.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/general/sirv_sram_icb_ctrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_tl_repeater_5.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_tlfragmenter_qspi_1.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_tlwidthwidget_qspi.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/sirv_wdog.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_spi_master/spi_master_apb_if.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_spi_master/spi_master_clkgen.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_spi_master/spi_master_controller.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_spi_master/spi_master_fifo.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_spi_master/spi_master_rx.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_spi_master/spi_master_tx.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_adv_timer/timer_cntrl.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_adv_timer/timer_module.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_uart/uart_interrupt.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_uart/uart_rx.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_uart/uart_tx.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/rtl/e203/perips/apb_adv_timer/up_down_counter.v
  D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/src/system.v
}
read_ip -quiet D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/mmcm/mmcm.xci
set_property used_in_implementation false [get_files -all d:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/mmcm/mmcm_board.xdc]
set_property used_in_implementation false [get_files -all d:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/mmcm/mmcm.xdc]
set_property used_in_implementation false [get_files -all d:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/mmcm/mmcm_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/constrs/nuclei-config.xdc
set_property used_in_implementation false [get_files D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/constrs/nuclei-config.xdc]

read_xdc D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/constrs/nuclei-master.xdc
set_property used_in_implementation false [get_files D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/constrs/nuclei-master.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top system -part xc7a200tfbg484-2L


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef system.dcp
create_report "synth_2_synth_report_utilization_0" "report_utilization -file system_utilization_synth.rpt -pb system_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
