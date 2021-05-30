/* 
 * --------------------
 * Company					: Shenzhen MileBot Robotics Tech Co., Ltd.
 * --------------------
 * Project Name			: SEA
 * Module Name				: PULSE
 * Description				:
 * --------------------
 * Tool Versions			: Quartus II 13.1
 * Target Device			: Cyclone IV E  EP4CE15F
 * --------------------
 * Engineer					: Jamut_wang
 * Revision					: V1.0
 * Created Date			: 2018-06-025
 * --------------------
 * Engineer					:
 * Revision					:
 * Modified Date			:
 * --------------------
 * Additional Comments	: PLUSE
 * 
 * --------------------
 */
 //-------------------------Timescale----------------------------//
`timescale 1 ns / 1 ps
`define CLK_100M (32'd100000000)
`define FREQ     (32'd10000)
//--------------------Module_PLUSE---------------------//
module PULSE
   (
	   input cs,
		input rst_n,
	
		input wr,
		input clk,
		input pul_enable,
		input [3:0]addr,
		input [15:0]indata,
	
		output en,
	   output pul,
		output dir,	
		output [15:0]outdata
	);


	wire rdn,wrn;

	reg pul_out;
//	reg dir_out;
//	reg en_out;
//	reg en_able;
	
   reg [15:0]rate;
	reg [31:0]tclk;
	reg [15:0]data_out;
	
	
//-------------------------PULSE_4-------------------------------//
  
 //  assign rdn = (cs | rd);
	assign wrn = (cs | wr);
 
	wire en_out = pul_enable;
	wire dir_out = pul_enable;
	wire en_able = pul_enable;
	
   always @(posedge clk or negedge rst_n or negedge wrn)
	begin
	 
	  if(!rst_n)
	  begin
	      pul_out <= 1'd0;
	  end
	  else
	  begin	
	     if(!wrn)
		  begin
		      case (addr)
				4'd1: 
				  begin
				     rate <= indata;
					  if(rate > 16'd9000)
					  begin
					     rate <= 16'd9000;
					  end
					  else if(rate < 16'd1000)
					  begin
					     rate <= 16'd1000;
					  end
				  end
				 default:;
				 endcase
		  end
		  else 
		  if(clk)
		  begin 
	        if(en_able == 1'd1)
	        begin
			     if (tclk >= (32'd10000)) //`CLK_100M/`FREQ
		         begin
		             tclk <= 32'd0;
		         end
		         else
		         begin
					    if(rate == 16'd0)
						 begin
						     pul_out <= 1'd0;
						 end
					    else
					    begin	 
		             //    if(tclk >= (`CLK_100M / `FREQ)/(100/rate))
							  if(tclk >= rate)
			              begin
			                  pul_out <= 1'd0;
			              end
			              else
			              begin
			                  pul_out <= 1'd1;
			              end
						 end
						 tclk <= tclk + 1'd1;
		         end
		      end
		   end
	  end	  
	
	end
	
	assign pul = pul_out;
	assign dir = dir_out;
	assign en = en_out;
	assign outdata = 16'hzzzz;
//------------------------enmodule ---------------------------//
endmodule
