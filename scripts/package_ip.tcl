####################################################################################
## Copyright 2023(c) Transbit Sp. z o.o.
## Created by Michał Bojke
####################################################################################

#
# STEP #0: define input and output directories, create project
# 
set proj_name $env(VIVADO_PROJ_NAME)
set rev None

# Sources 
set hdlRoot [file normalize [pwd]/hdl]
set xdcRoot [file normalize [pwd]/xdc]
set ipRoot [file normalize [pwd]/ip]
set bdRoot [file normalize [pwd]/bd]
set scriptsRoot [file normalize [pwd]/scripts]

# Outputs
set proj_dir [file normalize [pwd]/project]
set outputDir [file normalize [pwd]/run]
set productsDir [file normalize [pwd]/products] 

# Project parameters
set_param general.maxThreads 8
set jobs [get_param general.maxThreads]

set hdl_list {./src/gem_ext_fifo_rx.v \
    ./src/gem_ext_fifo_tx.v \
    ./src/ext_fifo_transceiver.v \
    ./src/to_axis_converter.v
}

create_project -force $proj_name -dir $outputDir 

set_property TARGET_LANGUAGE VERILOG [current_project]

import_files -fileset sources_1 $hdl_list

ipx::package_project -root_dir $productsDir -vendor $env(VIVADO_VENDOR) -library $env(VIVADO_LIBRARY) -taxonomy /UserIP -import_files -set_current false -force

ipx::unload_core $productsDir/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $productsDir $productsDir/component.xml
update_compile_order -fileset sources_1
set_property core_revision 1 [ipx::current_core]

ipx::infer_bus_interface {tx_r_data_rdy tx_r_rd tx_r_valid tx_r_data tx_r_sop tx_r_eop tx_r_err tx_r_underflow tx_r_flushed tx_r_control dma_tx_end_tog dma_tx_status_tog tx_r_status rx_w_wr rx_w_data rx_w_sop rx_w_eop rx_w_status rx_w_err rx_w_overflow rx_w_flush} xilinx.com:user:zynq_fifo_gem_rtl:1.0 [ipx::current_core]
set_property name FIFO_ENET [ipx::get_bus_interfaces zynq_fifo_gem_1 -of_objects [ipx::current_core]]

set_property display_name FIFO_ENET [ipx::get_bus_interfaces FIFO_ENET -of_objects [ipx::current_core]]


ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
