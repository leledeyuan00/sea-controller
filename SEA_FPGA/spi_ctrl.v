/* 
 * --------------------
 * Company					: Shenzhen MileBot Robotics Tech Co., Ltd.
 * --------------------
 * Project Name			: SEA
 * Module Name				: IO
 * Description				: 
 * --------------------
 * Tool Versions			: Quartus II 13.1
 * Target Device			: Cyclone IV E  EP4CE15F
 * --------------------
 * Engineer					: Jamut_Wang
 * Revision					: V1.0
 * Created Date			: 2018-06-25
 * --------------------
 * Engineer					:
 * Revision					:
 * Modified Date			:
 * --------------------
 * Additional Comments	: 
 */
//-------------------------Timescale----------------------------//
`timescale 1 ns / 1 ps 
//-----------------------Module spi_ctrl------------------------//
module spi_ctrl(

   input cs,
   input clk_1m,
	input rst_n,
   input rd,
   input wr,	
	input mi,
	input [3:0]addr,
	
	output cso,
	output clk,
	output [15:0]data
);
//--------------------------parameter--------------------------//

//--------------------------spi_mosi---------------------------//			 
reg[6:0]i;
reg[15:0]data_in;
reg [15:0]temp_data;
reg [15:0]db_out;
reg spi_cs;
reg spi_clk;
reg tr_clk;
reg [15:0]p_num;
wire rdn = (cs | rd);

always @(posedge clk_1m  or negedge rst_n)
  begin
     if(!rst_n)
	  begin
	     tr_clk <= 1'd0;
		  p_num <= 16'd0;
	  end
	  else
	  begin
	     if(clk_1m)
		  begin
		      p_num <= p_num + 1'd1;
				
				if(p_num <= 16'd100 )
				begin
				   tr_clk <= 1'd1;
				end
				else 
				begin
				   if(p_num > 16'd100 && p_num <= 16'd200)
				    begin
				       tr_clk <= 1'd0;
						 p_num <= 16'd0;
				   end
				end
		  end
	  end
  end
always @(negedge rdn or negedge rst_n)
  begin
     if (!rst_n)
	   begin
		    db_out <= 16'd0;
	   end	
		else
		begin
		   if(!rdn)
          begin
			    case (addr)
				 4'd1: db_out <= temp_data;
				 default:db_out <= 16'hzzzz;
				 endcase
			 end
	 	end
  end
always@(posedge tr_clk or negedge rst_n)
	if(!rst_n)
		begin
			i <= 6'd0;	
			data_in <= 16'd0;
			spi_cs <= 1'd1;
			spi_clk <= 1'd1;
		end
	else
 	if(tr_clk)
	begin
	case(i)   
		6'd0:
			begin
				i <= i + 1'd1;
				spi_cs <= 1'd0;		
			end
		6'd1:
	      begin
			   i <= i + 1'd1;
				spi_clk <= 1'd0;
		   end	
		 6'd2,6'd5,6'd8,6'd11,6'd14,6'd17,6'd20,6'd23,6'd26,6'd29,6'd32,6'd35,6'd38,6'd41,6'd44,6'd47:
	      begin
			   i <= i + 1'd1;
				spi_clk <= 1'd1;
		   end
	   6'd3,6'd6,6'd9,6'd12,6'd15,6'd18,6'd21,6'd24,6'd27,6'd30,6'd33,6'd36,6'd39,6'd42,6'd45,6'd48:
    		begin
			   i <= i + 1'd1;
				spi_clk <= 1'd0;
			//	data_in <= {data_in[14:0],mi};
		   end
		6'd4,6'd7,6'd10,6'd13,6'd16,6'd19,6'd22,6'd25,6'd28,6'd31,6'd34,6'd37,6'd40,6'd43,6'd46,6'd49:
		   begin
			 i <= i + 1'd1;
			    data_in <= {data_in[14:0],mi};
			end
		6'd50:
		   begin
			   i <= 6'd0;
				spi_cs <= 1'd1;
				spi_clk <= 1'd1;
				temp_data <= data_in;
			end
		default: i <= 6'd0;
	endcase
   end

assign cso = spi_cs;
assign clk = spi_clk;
assign data = !rdn ? db_out : 16'hzzzz;	
//--------------------------endmodule----------------------------//


endmodule
