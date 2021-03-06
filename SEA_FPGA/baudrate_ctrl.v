/* 
 * --------------------
 * Company					: LUOYANG GINGKO TECHNOLOGY CO.,LTD.
 * BBS						: http://www.eeschool.org
 * --------------------
 * Project Name			: uart
 * Module Name				: baudrate_ctrl
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
//-----------------------Module rst_n---------------------------//
module baudrate_ctrl(
	input clk_25m,
	input rst_n,
	output uart_clk
);

//-------------------------baudrate-----------------------------//

parameter 	baudrate = 9;//2169;//BPS_25M;	//参照上面参数,得到不同的波特率

//----------------------uart_clk--------------------------------//	
reg clk_r;
reg [11:0]cnt;
always@(posedge clk_25m or negedge rst_n)
	if(!rst_n)
		cnt <= 12'd0;
	else if(cnt == baudrate)
		cnt <= 12'd0;
	else 
		cnt <= cnt + 1'd1;
		
always@(posedge clk_25m or negedge rst_n)
	if(!rst_n)
		clk_r <= 12'd0;
	else if(cnt <= baudrate >> 1)
		clk_r <= 1'd0;
	else 
		clk_r <= 1'd1;

assign uart_clk = clk_r;

endmodule


