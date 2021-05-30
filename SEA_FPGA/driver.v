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
`define FREQ     (16'd10000)
`define SLEN     (16'd10)
//--------------------Module_PLUSE---------------------//
module DRIVER
   (
	   input cs,
		input rst_n,
	   input rd,
		input wr,
		input clk,
		
		input rdempty,
		input [7:0]usedfifo,
	   input [15:0]rddata,	
		input [3:0]addr,
		input [15:0]indata,
		input [15:0]backdata,
		
		output cs_code,
		output rd_code,
		output cs_rate,
		output wr_rate,
		output pul_enable,
		output [3:0]outaddr,
		output [15:0]rate,
		output [15:0]outdata,
		
		output rdreq,
	   output rdclk,
	   output fifoclr		
	);


	wire rdn,wrn;
   
   reg start;
	reg rdfifobegin;

	reg [15:0]data_out;
   reg [31:0]tclk;
	reg signed [15:0]insignal;
	reg signed [15:0]backsignal;	
	reg [15:0]signindex;
	reg [15:0]tama_temp;
	reg [15:0]tama_temp_r;
	reg [15:0]tama;
   assign rdn = (cs | rd);
	assign wrn = (cs | wr);
	
   reg clk_cal;	
	
	
reg [15:0]cnt;	
reg [15:0]databuf;
reg [15:0]insignalbuf;
reg [15:0]debugbuf;

reg cs_code_out;
reg cs_rate_out;
reg pul_enable_out;

reg fifo_no_empty;
reg ov;
reg rd_req;
reg rd_empty;
reg rd_clk;
reg fifo_clr;

reg [7:0]used_info;
reg [15:0]db_fifo;

reg [31:0]debug;


always @(posedge clk or negedge rst_n)
  begin
     if(!rst_n)
	  begin
	      clk_cal <= 1'd0;
		   cnt <= 16'd0;  
	  end
	  else
	  begin
	      if(clk)
				 begin
				     if(cnt > 16'd100 && cnt < 16'd200)
					  begin
					      clk_cal <= 1'd1;
						   cnt <= cnt + 1'd1;
					  end
					  else
					  begin
					      if(cnt == 16'd200)
						   begin
						       clk_cal <= 1'd0;
								 cnt <= 16'd0;
						   end  
						   else
						   begin
						      clk_cal <= 1'd0;
						      cnt <= cnt + 1'd1;
						   end 
					  end 
			    end
	  end
  end
always @(negedge rdn or negedge rst_n)
  begin
     if(!rst_n)
	  begin
	  
	  end
	  else
	  begin
	      if(!rdn)
         begin
		       case (addr)
			    4'd1:
			      begin
					    data_out <= {backsignal[15:0]};
						// databuf <= {backsignal[31:16]};
			      end
				 4'd2:
			      begin
					    data_out <= databuf;
			      end
				 4'd3: 
				   begin
					    data_out <= {insignal[15:0]};
						 //insignalbuf <= {insignal[31:16]};
					end 
				 4'd4: data_out <= insignalbuf;	
				 
				 4'd5: data_out <= {{15'd0},start};
				 4'd6: data_out <= rateout;
				 4'd7: data_out <= error;
				 4'd8: data_out <= error1;
				 4'd9: data_out <= error2;
				 4'd10: data_out <= h1 + h2 + h3;
				 4'd11: 
					begin
						data_out <= debug[15:0];
						debugbuf <= debug[31:16];
						end
				 4'd12: data_out <= debugbuf;
			    default:;
			    endcase	 
		   end 
		
	  end		  
  end  

//-------------------
reg signed [31:0]u;
reg signed [31:0]uu;
reg signed [31:0]ud;
reg signed [31:0]uy;
reg signed [31:0]x1;
reg signed [31:0]x2;
reg signed [31:0]x3;

reg signed [31:0]y1;
reg signed [31:0]y2;
reg signed [31:0]y3;


reg signed [15:0]ditu;
reg signed [31:0]h1;
reg signed [31:0]h2;
reg signed [31:0]h3;
reg signed [15:0]error;
reg signed [15:0]error1;
reg signed [15:0]error2;
reg signed [15:0]ep;
reg signed [15:0]ei;
reg signed [15:0]ed;
reg [7:0]status;
reg [15:0]rateout;
reg wr_rate_out;
reg rd_code_out;
reg [3:0]outaddr_out;
reg [15:0]highdata;
reg [15:0]lowdata;

 always @(posedge clk_cal or negedge rst_n or negedge wrn)
   begin
	   if(!rst_n)
		begin
		    start  <= 1'd0;
			 error  <= 32'd0;
			 error1 <= 32'd0;
			 error2 <= 32'd0;
			 rd_code_out <= 1'd1;
			 wr_rate_out <= 1'd1;
			 cs_code_out <= 1'd1;
			 cs_rate_out <= 1'd1;
			 pul_enable_out <= 1'd0;
			 status <= 8'd0;
			 insignal <= 32'd0;
			 u <= 16'd0;
			 
			 rdfifobegin <= 1'd0;
			 fifo_no_empty <= 1'd0;
			 ov <= 1'd0;
			 rd_req <= 1'd1;
			 rd_clk <= 1'd0;
			 fifo_clr <= 1'd0;
			 backsignal <= 32'd0;
		end
		else
		  begin
		      if(!wrn)
				begin
				    case (addr)
			       4'd1:
			         begin
					       {backsignal[15:0]} <= indata;
			         end
				    4'd2:
			         begin
					       //{backsignal[31:16]} <= indata;
			         end
					 4'd3:
			         begin
					       //{insignal[15:0]} <= indata;
			         end
				    4'd4:
			         begin
					      // {insignal[31:16]} <= indata;
			         end
					 4'd5:
					   begin 
						    case (indata)
							 16'd0: 
							    begin 
								    start <= 1'd0;
									 rdfifobegin <= 1'd0;
									 pul_enable_out <= 1'd0;
								 end
							 16'd1:
							    begin
								    start <= 1'd1;
									 rdfifobegin <= 1'd1;
									// pul_enable_out <= 1'd1;
									 pul_enable_out <= 1'd1;
								 end
							 16'd2:
							    begin
								    rdfifobegin <= 1'd0;
								 end
							 16'd3:
							    begin
								    rdfifobegin <= 1'd1;
								 end
					       default:;
							 endcase
						end
					 4'd6: rateout <= indata;
					 4'd7: ep <= indata;
					 4'd8: ei <= indata;
					 4'd9: ed <= indata;
			       default:;
			       endcase	 
				end
		      else
			   begin
			      if(clk_cal)
			      begin
			          case (status)
						 8'd0:
						   begin
							    if(rdfifobegin)
								 begin
								     rd_clk <= 1'd1;	
									  status <= status + 1'd1; 
								 end
								 else
								 begin
								    status <= 8'd8; 
								 end
							end
					 	 8'd1:
						   begin
					          db_fifo <= rddata;
						       used_info <= usedfifo;	 
						       rd_empty <= rdempty; 
						 	    status <= status + 1'd1; 
							end
						 8'd2:
						   begin  
								if(fifo_no_empty)
								begin
								   if(ov == 1'd0)
									 begin
									   //  ov = 1'd1;
										  insignal[15:0] <= db_fifo;
									 end
							   end
								rd_clk <= 1'd0;
								status <= status + 1'd1; 
							end
						 8'd3:
						   begin  
								if(rd_empty == 16'd0)
								begin
								   fifo_no_empty <= 1'd1;
							   end
								else
								begin
								   fifo_no_empty <= 1'd0;
								end
								status <= 8'd4; 
							end
						 		 
					    8'd4:
					      begin
						      outaddr_out <= 4'd1;
								cs_code_out <= 1'd0;
							   status <= status + 1'd1;
						   end
					    8'd5:
					      begin
						       rd_code_out <= 1'd0;
			                status <= status + 1'd1;	
								
					      end	
					    8'd6:
					      begin
							    status <= status + 1'd1;
					      end	
					    8'd7:
					      begin
							    cs_code_out <= 1'd1;
						       rd_code_out <= 1'd1;
			                status <= status + 1'd1;	
						   end
					    8'd8:
					      begin
						       outaddr_out <= 4'd2;
								 cs_code_out <= 1'd0;
							    status <= status + 1'd1;
						   end
					    8'd9:
					      begin
						       rd_code_out <= 1'd0;
			                status <= status + 1'd1;	
					      end	
					    8'd10:
					      begin
							    lowdata <= backdata;
						    	 status <= status + 1'd1;
					      end	
					    8'd11:
					      begin
						       rd_code_out <= 1'd1;	
								 cs_code_out <= 1'd1;
	                      status <= status + 1'd1;	
						   end
					    8'd12:
					      begin
						       outaddr_out <= 4'd3;
								 cs_code_out <= 1'd0;
							    status <= status + 1'd1;
						   end
					    8'd13:
					      begin
						       rd_code_out <= 1'd0;
			                status <= status + 1'd1;	
					      end	
					    8'd14:
					      begin
						       highdata <= (backdata & 4'h1);
							    status <= status + 1'd1;
					      end	
						 8'd15:
							begin
								 tama_temp[14:0] <= {highdata[0],lowdata[15:2]};
								 status <= status + 1'd1;
							end
						 8'd16:
							begin
								 if(((tama_temp<15'd100 && tama_temp_r > 15'd32567)||(tama_temp_r<15'd100 && tama_temp > 15'd32567)) && backsignal[15] == 0)
									backsignal[15] <= 1;
								 else if(((tama_temp<15'd100 && tama_temp_r > 15'd32567)||(tama_temp_r<15'd100 && tama_temp > 15'd32567)) && backsignal[15] == 1)
									backsignal[15] <= 0;
								 status <= status + 1'd1;
							end
					    8'd17:
					      begin
								 tama_temp_r <= tama_temp;
						       rd_code_out <= 1'd1;	
								 cs_code_out <= 1'd1;
	                      //backsignal <= {highdata,lowdata};
								 backsignal[14:0] <= {highdata[0],lowdata[15:2]};
								 //backsignal[31:16]<= 16'd0;
			                if(start)			 
							       status <= 8'd20;	
								 else
								    status <= 1'd0;	
						   end
					    8'd20:
					       begin
						        error <= insignal - backsignal;
							     status <= status + 1'd1;
						    end
					    8'd21:
					      begin
						       h1 <= ep + ei + ed;
					          h2 <= ep + 2*ed;
					          h3 <= ed; 			 
							    status <= status +1'd1;
						   end
						 8'd22:
						   begin
							    ditu <= uu;
								 status <= status +1'd1;
							end
					  
						 8'd23:
					      begin
						       x1 <= h1 * error;
							    x2 <= h2 * error1;
								 x3 <= h3 * error2;
								 
								 status <= status +1'd1;
					      end
						8'd24:
					      begin
						       ud <= x1 - x2;
								 status <= status +1'd1;
					      end
						8'd25:
					      begin
							    uy <= ditu + x3;
								 status <= status +1'd1;
					      end
						8'd26:
					      begin
							    uu <= ud + uy;
								 status <= status +1'd1;
					      end
						8'd27:
					      begin
								 u <=  uu / 100;
								 status <= status +1'd1;
					      end
					    8'd28:
					      begin
						       if(u >= 32'd2000 && u < 32'h80000000)
							    begin
							        u <= 32'd2000;
							    end
							    else 
								 begin
								    if(u >= 32'h80000000 && u <= 32'hFFFFF830)//16'hD8F0)//16'hF448)
							       begin
							            u <= 32'hFFFFF830;
							       end
								 end
								 
							    status <= status +1'd1;
					      end
					    8'd29:
					      begin
						       rateout <= 16'd5000 - {u[15:0]};
							    status <= status +1'd1;
					      end
						 8'd30:
					      begin
						       outaddr_out <= 4'd1;
							    status <= status +1'd1;
					      end
						 8'd31:
					      begin
						       cs_rate_out <= 1'd0;
							    status <= status +1'd1;
					      end
						 8'd32:
					      begin
						       wr_rate_out <= 1'd0;
							    status <= status +1'd1;
					      end
						 8'd33:
					      begin
						       wr_rate_out <= 1'd1;
							    status <= status +1'd1;
					      end
						 8'd34:
					      begin
						       cs_rate_out <= 1'd1;
							    status <= status +1'd1;
					      end
					    8'd35:
					      begin
						       error2 <= error1;
							    status <= status +1'd1;
					      end
					    8'd36:
					      begin
						       error1 <= error;
								 
							    status <= 8'd0;
					      end
					    default:status <= 8'd0;
					    endcase
			  end
		  end
      end
	end

	always@(*)begin
		debug = 32'hffffffff * 2'b10;
	end
	assign rd_code = rd_code_out;
	assign outaddr = outaddr_out;
	assign wr_rate = wr_rate_out;
	assign cs_code = cs_code_out;
	assign cs_rate = cs_rate_out;
	assign pul_enable = pul_enable_out;
	assign rate = rateout;
	
	assign rdreq = rd_req;
   assign rdclk = rd_clk;
   assign fifoclr = fifo_clr;
	assign outdata = !rdn ? data_out : 16'hzzzz;
//------------------------enmodule ---------------------------//
endmodule
