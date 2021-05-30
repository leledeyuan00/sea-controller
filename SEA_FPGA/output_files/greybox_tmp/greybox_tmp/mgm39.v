//lpm_decode CBX_SINGLE_OUTPUT_FILE="ON" LPM_DECODES=4 LPM_TYPE="LPM_DECODE" LPM_WIDTH=2 data enable
//VERSION_BEGIN 18.0 cbx_mgl 2018:04:24:18:08:49:SJ cbx_stratixii 2018:04:24:18:04:18:SJ cbx_util_mgl 2018:04:24:18:04:18:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2018  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel FPGA IP License Agreement, or other applicable license
//  agreement, including, without limitation, that your use is for
//  the sole purpose of programming logic devices manufactured by
//  Intel and sold by Intel or its authorized distributors.  Please
//  refer to the applicable agreement for further details.



//synthesis_resources = lpm_decode 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mgm39
	( 
	data,
	enable) /* synthesis synthesis_clearbox=1 */;
	input   [1:0]  data;
	input   enable;


	lpm_decode   mgl_prim1
	( 
	.data(data),
	.enable(enable));
	defparam
		mgl_prim1.lpm_decodes = 4,
		mgl_prim1.lpm_type = "LPM_DECODE",
		mgl_prim1.lpm_width = 2;
endmodule //mgm39
//VALID FILE
