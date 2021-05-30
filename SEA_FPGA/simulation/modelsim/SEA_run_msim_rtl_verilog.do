transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA/controller {E:/FPGA/SEA/SEA_FPGA/controller/control_timer.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA/controller {E:/FPGA/SEA/SEA_FPGA/controller/smc_controller.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA/controller {E:/FPGA/SEA/SEA_FPGA/controller/nominal_model_controller.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA/controller {E:/FPGA/SEA/SEA_FPGA/controller/controller_defines.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/PLL_M.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/DECODE.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/Rst_n.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/fifo_data.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/rs485.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA/db {E:/FPGA/SEA/SEA_FPGA/db/pll_m_altpll.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/fifo_control.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/baudrate_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/spi_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/ab_8.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA/controller {E:/FPGA/SEA/SEA_FPGA/controller/nominal_top.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA/controller {E:/FPGA/SEA/SEA_FPGA/controller/nominal_model.v}
vlog -vlog01compat -work work +incdir+E:/FPGA/SEA/SEA_FPGA {E:/FPGA/SEA/SEA_FPGA/PULSE.v}

