`ifndef CONTROLLER_DEFINES_V
`define CONTROLLER_DEFINES_V

`timescale 1 ns / 1 ns
`define CLK_100M (32'd100000000)
`define FREQ     (16'd10000)


//`define NOMINAL
//`define SMC_2_2
//`define SMC_1
`define OBSERVE

`ifdef NOMINAL
	`include "SMC_3_1/SMC_3_1_DEF.v"
	`elsif SMC_2_2
	`include "SMC_2_2/SMC_2_2.v"
	`elsif SMC_1
	`include "SMC_1/SMC_simple.v"
	`elsif OBSERVE
	`include "SMC_Observe/SMC_obv_def.v"
`endif

`endif

