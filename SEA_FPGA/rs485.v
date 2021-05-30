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
 * Additional Comments	: rs485
 * 
 * --------------------
 */
//-------------------------Timescale----------------------------//
`timescale 1 ns / 1 ps 
//-----------------------Macro Declaration----------------------//
`define LINK 1
`define MOTOR 0
`define DATA_ID_0 8'h02
`define DATA_ID_3 8'h1A
`define CRC
//-----------------------Module rst_n---------------------------//
module rs485
#(parameter Encoder_switch = `LINK)
(
	input cs,
	input cs_m,
	input rst_n,
	input clk,
	input rd,
	input rd_m,
	input wr,
	input rx,

	input [3:0]addr,
	input [3:0]addr_m,
	inout [15:0]indata,

	output dir,
	output tx,
	output[15:0]db


);
	//---------------------------parameter--------------------------//
	//localparam crc_polynominal = 9'h101; // x^8 + 1;

	reg[7:0]j;
	reg[7:0]data_in;

	reg [7:0]receive_data[10:0];

	reg [7:0]control_filed;
	reg [7:0]state_filed;
	reg [7:0]absolute_data[2:0];
	reg [7:0]end_id;
	reg [7:0]multi_turn_data[2:0];
	reg [7:0]error;
	reg [7:0]crc_filed;
	reg [15:0]crc_error;

	reg [7:0]crc_calculate;

	reg [15:0]db_out;
	reg dir_out;
	reg [7:0]cnt;
	reg startrecode;
	reg [15:0]databuf;


	wire wrn_m = (cs_m | wr);
	wire rdn_m = (cs_m | rd_m);
	wire rdn = (cs | rd);

	wire [16:0] tama_raw,tama_p,tama_n;
	reg [16:0] tama_rawr;
	wire [15:0] tama_cal,tama;
	reg [15:0] tama_zero[0],tama_calr,tama_out;

	assign tama_raw = {{absolute_data[2][0]},{absolute_data[1]},{absolute_data[0]}};
	assign tama_cal = (((tama_raw > 17'd130000)&&(tama_rawr<17'd1000))||((tama_rawr>17'd130000)&&(tama_raw<17'd1000)))?
	{!tama_calr[15],tama_raw[16:2]}:{tama_calr[15],tama_raw[16:2]};

	assign tama_n = {1'b1,tama_cal} - tama_zero[0];
	assign tama_p = tama_cal - tama_zero[0];
	assign tama = (tama_cal >= tama_zero[0])?tama_p[15:0]:tama_n[15:0];

	always@(posedge clk or negedge rst_n)
	if(!rst_n)begin
		tama_rawr <= 17'd0;
		tama_calr <= 16'd0;
	end
	else begin
		tama_rawr <= tama_raw;
		tama_calr <= tama_cal;
	end
	//-------------------------------zero---------------------------//
	always@(posedge clk or negedge rst_n or negedge wrn_m)begin
		if(!rst_n)
			tama_zero[0] <= 16'd0;
		else if(!wrn_m) begin
			case (addr_m)
				4'd1: tama_zero[0]<= indata;
				default:;
			endcase
		end
		else
			tama_zero[0] <= tama_zero[0];
	end
	//------------------------------debug---------------------------//
	always@(negedge rdn_m)begin
		case(addr_m)
			4'd1: tama_out <= tama_cal;
			4'd2: tama_out <= tama;
			4'd3: tama_out <= tama_zero[0];
			4'd4: tama_out <= {state_filed,control_filed};
			4'd5: tama_out <= {absolute_data[1],absolute_data[0]};
			4'd6: tama_out <= {crc_filed,absolute_data[2]};
			4'd7: tama_out <= crc_error;
			default:;
		endcase
	end
	assign indata = !rdn_m?tama_out:16'hzzzz;
	//-----------------------------data_read------------------------//
	always @(negedge rdn)
	if(!rdn)
		begin
			case (addr)

				4'h0:   db_out <= {{15'd0},dir_out};
				4'h1:
				begin
					db_out <= {state_filed,control_filed};
				end
				4'h2:
				begin
					db_out <= tama;
					databuf <= {crc_filed,absolute_data[2]};
				end
				4'h3:  db_out <= databuf;

				default:  db_out <= 16'hzzzz;
			endcase
		end
		//---------------------------------rx---------------------------//
	always@(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
			j 				<= 8'd0;
			data_in 		<= 8'd0;
			cnt 			<= 8'd0;
			startrecode		<= 1'd0;
			control_filed	<= 8'd0;
			state_filed		<= 8'd0;
			end_id			<= 8'd0;
			error			<= 8'd0;
			crc_calculate 	<= 8'd0;
			crc_error		<= 16'd0;
		end
	else begin
		if(!dir_out)
			begin
				case(j)
					4'd0:
					begin if(!rx)begin
							data_in <= 8'd0;
							j <= j + 1'd1;
						end
						else j <= j;
					end
					4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8:
					begin
						j <= j + 1'd1;
						data_in <= {rx,data_in[7:1]};
					end
					4'd9:
					begin
						case(cnt)
							8'd0: begin
								if({data_in} == (Encoder_switch?`DATA_ID_0:`DATA_ID_3) && startrecode == 1'd0)begin
									j <= 8'd0;
									cnt <= 1'd1;
									receive_data[0] <= data_in;
									crc_calculate <= 8'd0;
								end
								else
									cnt <= 8'd0;
							end
							8'd1,8'd2,8'd3,8'd4:
							begin
								j <= 8'd0;
								cnt <= cnt + 1'd1;
								receive_data[cnt] <= data_in;
								crc_calculate <= crc_calculate ^ receive_data[cnt - 1'b1];
							end
							8'd5:begin
								if(Encoder_switch)begin
									j			<= 8'd10;
									cnt			<= 8'd0;
									crc_filed	<= data_in;
								end
								else begin
									j <= 8'd0;
									cnt <= cnt + 1'd1;
									receive_data[5] <= data_in;
								end
								crc_calculate <= crc_calculate ^ receive_data[cnt - 1'b1];
							end
							8'd6,8'd7,8'd8,8'd9:
							begin
								j <= 8'd0;
								cnt<= cnt + 1'd1;
								receive_data[cnt] <= data_in;
								crc_calculate <= crc_calculate ^ receive_data[cnt - 1'b1];
							end
							8'd10:begin
								j 			<= 8'd10;
								cnt			<= 8'd0;
								crc_filed 	<= data_in;
								crc_calculate <= crc_calculate ^ receive_data[cnt - 1'b1];
							end
							default:cnt<= 8'd0;
						endcase
					end
					//-----------------CRC--------------//
					8'd10:
					begin
						j <= 8'd0;
						`ifdef CRC
						if(crc_calculate == crc_filed) begin
							`endif
							if(Encoder_switch)
								begin
									control_filed 		<= receive_data[0];
									state_filed			<= receive_data[1];
									absolute_data[0]	<= receive_data[2];
									absolute_data[1]	<= receive_data[3];
									absolute_data[2]	<= receive_data[4];
								end
							else
								begin
									control_filed		<= receive_data[0];
									state_filed			<= receive_data[1];
									absolute_data[0]	<= receive_data[2];
									absolute_data[1]	<= receive_data[3];
									absolute_data[2]	<= receive_data[4];
									end_id				<= receive_data[5];
									multi_turn_data[0]	<= receive_data[6];
									multi_turn_data[1]	<= receive_data[7];
									multi_turn_data[2]	<= receive_data[8];
									error				<= receive_data[9];
								end
								`ifdef CRC
						end
						else crc_error <= crc_error + 1'b1;
						`endif
					end
					default: j <= 4'd0;
				endcase
			end
		else begin //state reset
			j <= 8'd0;
			cnt <= 8'd0;
		end
	end

	//---------------------------------tx---------------------------//

	reg tx_r;
	reg [7:0]cmd;
	reg [21:0]i;
	always @(posedge clk or negedge rst_n)
	if (!rst_n)
		begin
			i <= 22'd0;
			cmd <=  Encoder_switch?`DATA_ID_0:`DATA_ID_3;
		end
	else if(clk)
		begin
			case(i)
				22'd0: begin
					i <= i + 1'd1;

					cmd <= Encoder_switch?`DATA_ID_0:`DATA_ID_3;
					tx_r <= 1'd0;
					dir_out <= 1'd1;
				end
				22'd1,14'd2,14'd3,14'd4,14'd5,14'd6,14'd7,14'd8: //tx_r
				begin
					i <= i + 1'd1;
					{cmd[6:0],tx_r} <= cmd;
				end
				22'd9: begin
					i <= i + 1'd1;
					tx_r <= 1'd1;

				end
				22'd10: begin
					i <= i + 1'd1;
					dir_out <= 1'd0;
				end
				22'd250: begin
					i <= 22'd0;
				end
				default: i <= i + 1'd1;
			endcase
		end

	assign dir = dir_out;
	assign tx = tx_r;
	assign db = !rdn ? db_out : 16'hzzzz;
endmodule
			 
				 
				 