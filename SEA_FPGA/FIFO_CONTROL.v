/* 
 * --------------------
 * Company					: LUOYANG GINGKO TECHNOLOGY CO.,LTD.
 * BBS						: http://www.eeschool.org
 * --------------------
 * Project Name			: fifo
 * Module Name				: fifo
 * Description				: ---
 * --------------------
 * Tool Versions			: Quartus II 13.1
 * Target Device			: Cyclone IV E  EP4CE15F23C8
 * --------------------
 * Engineer					: xiaorenwu
 * Revision					: V0.0
 * Created Date			: 2017-08-22
 * --------------------
 * Engineer					:
 * Revision					:
 * Modified Date			:
 * --------------------
 * Additional Comments	: ---
 * 
 * --------------------
 */
//-------------------------Timescale----------------------------//
`timescale 1 ns / 1 ps 
//-----------------------Module fifo_wr_rd----------------------//
module FIFO_CONTROL(
	input cs,
	input rst_n,
	input wr,
	input rd,
	input clk,

	input wrfull,
	
	
	input [3:0]addr,
	input [15:0]indata,
	
	output wrreq,
	output wrclk,
	output [15:0]wrdata,
	
	
	output [15:0]data
	
);

reg wr_req;
reg wr_clk;
reg [15:0]wr_data;
reg rd_req;
reg rd_clk;
reg fifo_clr;
reg [15:0]db_out;
reg [7:0]wrcnt;
reg [7:0]used_info;
reg rd_empty;

wire rdn = rd | cs;	
wire wrn = wr | cs;

always @(posedge clk or negedge rdn or negedge rst_n)
  begin
     if (!rst_n)
	   begin
		  //  rd_req <= 1'd1;
			// rd_clk <= 1'd0;
		   // db_out <= 16'd0;
	   end	
		else
		begin
		   if(!rdn)
          begin
			    case (addr)
				 4'd1: 
				    begin
					//    rd_clk <= 1'd1;	
					   // db_out <= rddata;
						// used_info <= usedfifo;	 
						// rd_empty <= rdempty;
						 
					 end
				 4'd2: 
				    begin
					  
			        
					 end 
				 4'd3:
				    begin
					  //  db_out <= used_info;
					 end
				 4'd4:
				    begin
					  //  db_out <= rd_empty;
					 end
				 default:db_out <= 16'hzzzz;
				 endcase
			 end
			 else
			 begin
			    // rd_clk <= 1'd0;
			 end
	 	end
  end
  
always@(posedge clk or negedge wrn or negedge rst_n)
	if(!rst_n)
	begin
		 wr_req <= 1'd1;
		 wr_clk <= 1'd0;	
		 wrcnt <= 8'd0;
	end
	else
	 begin
	    if(!wrn)
		  begin
		     case (addr)
			  4'd1: 
			     begin
				      wr_data <= indata;
						wr_clk <= 1'd0;				
				  end
			  4'd2: 
			     begin
						
				  end
			  
				
			  default:;
			  endcase
		    
		  end
		  else
		  begin
		     if(clk)
			  begin
			     wr_clk <= 1'd1;
				  
			  end
		  end
	 end


assign wrreq = wr_req;
//assign rdreq = rd_req;
//assign rdclk = rd_clk;
assign wrclk = wr_clk;
assign wrdata = wr_data; 
assign data = rdn ? 16'hzzzz : db_out;

endmodule


