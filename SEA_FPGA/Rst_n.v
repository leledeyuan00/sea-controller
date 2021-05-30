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
 * --------------------
 */
//-------------------------Timescale----------------------------//
`timescale 1 ns / 1 ps 
//-----------------------Module rst_n---------------------------//
module rst_n(
	input clk_25m,
	output rst_n
);

reg [5:0]rst_cnt;
always@(posedge clk_25m)
	if(rst_cnt == 4'd50)
		begin 
			rst_cnt <= 4'd50;
		end 
	else 
		rst_cnt <= rst_cnt + 1'd1;
		
assign rst_n = (rst_cnt == 4'd50) ? 1'd1 : 1'd0;

endmodule 
		