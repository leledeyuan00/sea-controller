/* 
 * --------------------
 * Company					: CHANGCHUN YANCHUANG INTELLIGENT TECHNOLOGY CO.,LTD.
 * --------------------
 * Project Name			: motion controller
 * Module Name				: IO
 * Description				: The codes of "DA"
 * --------------------
 * Tool Versions			: Quartus II 13.1
 * Target Device			: Cyclone IV E  EP4CE10F17C8
 * --------------------
 * Engineer					: jamut
 * Revision					: V1.0
 * Created Date			: 2018-01-05
 * --------------------
 * Engineer					:
 * Revision					:
 * Modified Date			:
 * --------------------
 * Additional Comments	: AB_8
 * 
 * --------------------
 */
`include "arithmatic/arithmatic.v"
//-------------------------Timescale----------------------------//
`timescale 1 ns / 1 ps
//------------------------Macro Declaration---------------------//
`define CLK_25M             (25000000)
//Gear Ratio 6/5
`define GEAR_RATIO 
//--------------------Module_AB_Servo---------------------//
module AB_8
  (
	input cs,
	input cs_m,
	input rst_n,
	input rd,
	input rd_m,
	input wr,
	input clk,
	input inA,
	input inB,
	input inZ,

	input [3:0]addr,
	input [3:0]addr_m,
	inout [15:0]indata,
	output [15:0]db
);


	wire rdn,wrn,rdn_m;

	reg [15:0]out_db;
	reg [15:0] AB_out;
	wire [15:0]countAB;
	reg [15:0]countZ;
	reg [1:0]prestateAB,curstateAB;
	wire [5:0] cons_AB;
	wire [1:0] count_sub,count_add;

	reg  prestateZ;
	reg  dirAB;

	reg [31:0] n_d;

	reg [31:0] count_raw;
	wire [47:0] count_temp;
	reg [15:0] zero_low;
	`ifdef GEAR_RATIO
	localparam [15:0]gear_ratio = 16'b1000101000010101; // 0.001000101000010101
	reg[3:0] count_ratio; // 
	`endif

	assign rdn = (rd | cs);
	assign rdn_m = (rd_m | cs_m);
	assign wrn = (wr | cs_m);
	/* ---------------RD ------------ */
	always@(negedge rdn_m)begin
		if(!rdn_m)begin
			case(addr_m)
				4'd1:begin
					AB_out <= countAB;
				end
				default:;
			endcase
		end
	end
	assign indata = (!rdn_m)?AB_out:16'hzzzz;

	always @(negedge rdn)
	if(!rdn)
		begin

			case (addr)

				4'h1:   out_db <= countAB;
				4'h2:  	out_db <= countAB;
				4'h3:   out_db <= 16'd300; //{countZ[15:0]};
				default:  out_db <= 16'hzzzz;
			endcase
		end
		/* ----------------Quadrature code ---------- */
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			curstateAB <= 2'b0;
			prestateAB <= 2'b0;
		end
		else begin
			curstateAB <= {inA,inB};
			prestateAB <= curstateAB;
		end
	end
	/* ----------------- Encoder ----------------- */
	always@(posedge clk or negedge rst_n
	`ifdef GEAR_RATIO
	or negedge wrn
	`endif
	)begin
		if(!rst_n) begin
			`ifdef GEAR_RATIO
			count_ratio <= 0;
			`else
			`endif
			count_raw <=32'd0;
		end
		`ifdef GEAR_RATIO
		else if(!wrn)begin
			case(addr_m)
					4'd1:zero_low = indata;
					4'd2:count_raw = {indata,zero_low}; 
				default:;
			endcase
		end
		`endif
		else begin
			case (curstateAB)
				count_sub:begin
					if(count_raw != 32'd0)
						count_raw <= count_raw - 1'd1;
					else
						count_raw <= 32'd485999;
				end
				count_add:begin
					if(count_raw != 32'd485999)
						count_raw <= count_raw + 1'd1;
					else
						count_raw <= 32'd0;
				end
			endcase
		end
	end
	assign count_temp = count_raw * gear_ratio;
	assign countAB = count_temp >>18;

	assign cons_AB ={~prestateAB,prestateAB,~prestateAB};
	assign count_sub = cons_AB[2:1];
	assign count_add = cons_AB[4:3];

	assign db = !rdn ? out_db : 16'hzzzz;
	//------------------------enmodule ---------------------------//

endmodule
