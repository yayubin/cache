# This file is automatically generated.
# It contains project source information necessary for synthesis and implementation.

# XDC: D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/constrs/nuclei-config.xdc

# XDC: D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/constrs/nuclei-master.xdc

# IP: D:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/mmcm/mmcm.xci
set_property DONT_TOUCH TRUE [get_cells -hier -filter {REF_NAME==mmcm || ORIG_REF_NAME==mmcm} -quiet] -quiet

# XDC: d:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/mmcm/mmcm_board.xdc
set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==mmcm || ORIG_REF_NAME==mmcm} -quiet] {/inst } ]/inst ] -quiet] -quiet

# XDC: d:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/mmcm/mmcm.xdc
#dup# set_property DONT_TOUCH TRUE [get_cells [split [join [get_cells -hier -filter {REF_NAME==mmcm || ORIG_REF_NAME==mmcm} -quiet] {/inst } ]/inst ] -quiet] -quiet

# XDC: d:/puf/risc/puf_risc_flash_cache_mem_test/e203_hbirdv2-master/fpga/xc7a35/mmcm/mmcm_ooc.xdc
