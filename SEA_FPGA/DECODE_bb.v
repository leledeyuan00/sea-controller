// megafunction wizard: %LPM_DECODE%VBB%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_DECODE 

// ============================================================
// File Name: DECODE.v
// Megafunction Name(s):
// 			LPM_DECODE
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 18.0.0 Build 614 04/24/2018 SJ Standard Edition
// ************************************************************

//Copyright (C) 2018  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details.

module DECODE (
	data,
	enable,
	eq0,
	eq1,
	eq2,
	eq3,
	eq4,
	eq5,
	eq6,
	eq7);

	input	[2:0]  data;
	input	  enable;
	output	  eq0;
	output	  eq1;
	output	  eq2;
	output	  eq3;
	output	  eq4;
	output	  eq5;
	output	  eq6;
	output	  eq7;

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: BaseDec NUMERIC "1"
// Retrieval info: PRIVATE: EnableInput NUMERIC "1"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
// Retrieval info: PRIVATE: LPM_PIPELINE NUMERIC "0"
// Retrieval info: PRIVATE: Latency NUMERIC "0"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: aclr NUMERIC "0"
// Retrieval info: PRIVATE: clken NUMERIC "0"
// Retrieval info: PRIVATE: eq0 NUMERIC "1"
// Retrieval info: PRIVATE: eq1 NUMERIC "1"
// Retrieval info: PRIVATE: eq2 NUMERIC "1"
// Retrieval info: PRIVATE: eq3 NUMERIC "1"
// Retrieval info: PRIVATE: eq4 NUMERIC "1"
// Retrieval info: PRIVATE: eq5 NUMERIC "1"
// Retrieval info: PRIVATE: eq6 NUMERIC "1"
// Retrieval info: PRIVATE: eq7 NUMERIC "1"
// Retrieval info: PRIVATE: nBit NUMERIC "3"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_DECODES NUMERIC "8"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_DECODE"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "3"
// Retrieval info: USED_PORT: @eq 0 0 8 0 OUTPUT NODEFVAL "@eq[7..0]"
// Retrieval info: USED_PORT: data 0 0 3 0 INPUT NODEFVAL "data[2..0]"
// Retrieval info: USED_PORT: enable 0 0 0 0 INPUT NODEFVAL "enable"
// Retrieval info: USED_PORT: eq0 0 0 0 0 OUTPUT NODEFVAL "eq0"
// Retrieval info: USED_PORT: eq1 0 0 0 0 OUTPUT NODEFVAL "eq1"
// Retrieval info: USED_PORT: eq2 0 0 0 0 OUTPUT NODEFVAL "eq2"
// Retrieval info: USED_PORT: eq3 0 0 0 0 OUTPUT NODEFVAL "eq3"
// Retrieval info: USED_PORT: eq4 0 0 0 0 OUTPUT NODEFVAL "eq4"
// Retrieval info: USED_PORT: eq5 0 0 0 0 OUTPUT NODEFVAL "eq5"
// Retrieval info: USED_PORT: eq6 0 0 0 0 OUTPUT NODEFVAL "eq6"
// Retrieval info: USED_PORT: eq7 0 0 0 0 OUTPUT NODEFVAL "eq7"
// Retrieval info: CONNECT: @data 0 0 3 0 data 0 0 3 0
// Retrieval info: CONNECT: @enable 0 0 0 0 enable 0 0 0 0
// Retrieval info: CONNECT: eq0 0 0 0 0 @eq 0 0 1 0
// Retrieval info: CONNECT: eq1 0 0 0 0 @eq 0 0 1 1
// Retrieval info: CONNECT: eq2 0 0 0 0 @eq 0 0 1 2
// Retrieval info: CONNECT: eq3 0 0 0 0 @eq 0 0 1 3
// Retrieval info: CONNECT: eq4 0 0 0 0 @eq 0 0 1 4
// Retrieval info: CONNECT: eq5 0 0 0 0 @eq 0 0 1 5
// Retrieval info: CONNECT: eq6 0 0 0 0 @eq 0 0 1 6
// Retrieval info: CONNECT: eq7 0 0 0 0 @eq 0 0 1 7
// Retrieval info: GEN_FILE: TYPE_NORMAL DECODE.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL DECODE.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL DECODE.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL DECODE.bsf TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL DECODE_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL DECODE_bb.v TRUE
// Retrieval info: LIB_FILE: lpm
