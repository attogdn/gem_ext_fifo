# ip

source ../../adi/library/scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create ext_fifo_transceiver
adi_ip_files ext_fifo_transceiver [list \
  "src/ext_fifo_rx.v" \
  "src/ext_fifo_tx.v" \
  "src/to_axis_converter.v" \
  "src/ext_fifo_transceiver.v"]

adi_ip_properties_lite ext_fifo_transceiver

adi_ip_infer_streaming_interfaces ext_fifo_transceiver

ipx::infer_bus_interface {tx_r_data_rdy tx_r_rd tx_r_valid tx_r_data tx_r_sop tx_r_eop tx_r_err tx_r_underflow tx_r_flushed tx_r_control dma_tx_end_tog dma_tx_status_tog tx_r_status rx_w_wr rx_w_data rx_w_sop rx_w_eop rx_w_status rx_w_err rx_w_overflow rx_w_flush} xilinx.com:user:zynq_fifo_gem_rtl:1.0 [ipx::current_core]
set_property name FIFO_ENET [ipx::get_bus_interfaces zynq_fifo_gem_1 -of_objects [ipx::current_core]]

set_property display_name FIFO_ENET [ipx::get_bus_interfaces FIFO_ENET -of_objects [ipx::current_core]]

ipx::associate_bus_interfaces -busif m_axis -clock rx_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif s_axis -clock tx_clk [ipx::current_core]

ipx::save_core [ipx::current_core]
