/* 
 * --------------------
 * Company					: Shenzhen MileBot Robotics Tech Co., Ltd.
 * --------------------
 * Project Name				: SEA
 * model Name				: Drive_nominal
 * Description				:
 * --------------------
 * Tool Versions			: Quartus II 13.1
 * Target Device			: Cyclone IV E  EP4CE15F
 * --------------------
 * Engineer					: Dayuan
 * Revision					: V1.0
 * Created Date				: 2018-11-04
 * --------------------
 * Engineer					:
 * Revision					:
 * Modified Date			:
 * --------------------
 * Additional Comments	: PLUSE_DESIRE
 * 
 * --------------------
 */
//-------------------------Timescale----------------------------//
`include "controller_defines.v"
`include "../arithmatic/arithmatic.v"
`include "../timer/control_timer.v"
//------------------------Macro_Define--------------------------//
/*  
	 * ---fix-point sfix16_En13  
	 * ---3.1415(d)(pi)  = 011.0010010000111(b) >= 3.141357421875
	 * ---6.2831(d)(2pi) = 110.0100100001110(b) >= 6.282958984375
	 * ---error = 0.000244140625
	 * ---0.1 = 12'b110011001
	 */
`define PI 		 (16'b0110010010000111)
`define PI_2     (16'b1100100100001110)
//--------------------model_PLUSE---------------------//
module nominal_top
(
	input cs,
	input rst_n,
	input rd,
	input wr,
	input clk,

	input rdempty,
	input [7:0] usedfifo,
	input [15:0] rddata,
	input [3:0] addr,
	input [15:0] indata,
	input [15:0] backdata,

	output [1:0]cs_code,
	output rd_code,
	output cs_rate,
	output wr_rate,
	output pul_enable,
	output [3:0] outaddr,
	output [15:0] rate,
	output [15:0] outdata,

	output rdreq,
	output rdclk,
	output fifoclr
);
	/*---------Add user variable here---------*/
	wire rdn,wrn;

	wire clk_h,clk_l,clk_m;
	reg clk_c;
	
	localparam k_imp = 6;

	//fifo
	reg fifo_no_empty;
	reg rd_req;
	reg rd_empty;
	reg rd_clk;
	reg fifo_clr;
	//interpolation
	reg signed[15:0] intpl_thetad_r,intpl_thetad_temp,intpl_thetad_r2,dtheta_d_r,ddtheta_d_r;
	wire signed[15:0] intpl_error,inte_error_dt,intpl_thetad_next;
	wire signed[24:0] intpl_error_temp;
	reg[7:0] intpl_cnt;
	//encoder
	localparam delay_vel = 100<<4;
	reg [(delay_vel)-1:0] delay_theta_r;
	reg[1:0] cs_code_out;
	reg rd_code_out;
	reg[3:0] outaddr_out;
	reg signed[15:0] tama_temp,tama_temp_r;
	reg signed[15:0] highdata;
	reg signed[15:0] lowdata;
	reg signed[15:0] enc_inc;
	reg[15:0] insignal;
	reg [15:0] backsignal;
	wire signed[31:0] enc_tama32;
	wire signed[31:0] enc_inc32;
	
	wire signed[31:0] enc_sub;
	wire signed[31:0] force_cal;

	//driver
	reg cs_rate_out;
	reg wr_rate_out;
	reg pul_enable_out;
	reg[15:0] rateout;
	reg signed[15:0] u;

	//algorithm
	wire signed[15:0] theta_delay;
	wire signed[31:0] theta_delay_t1, dtheta,ddtheta; //int
	wire signed[31:0] theta_e, dtheta_e; //
	wire signed[31:0] theta_d_a; // int
	reg signed [31:0] theta_d_r1, theta_d_r2;
	reg signed [31:0]theta_d_v1, theta_d_v2;

	wire[31:0] u_t; //sfix32_En10
	wire[31:0] u_t_c; //int

	reg signed[31:0] theta_dot_r; //int
	reg signed[31:0] theta_e_r, theta_dote_r; //sfix32_En10
	wire signed[15:0] controller_u;
	
	`ifdef NOMINAL
	wire signed[31:0] nu;
	wire signed[31:0] thetan,dthetan;
	`else
	`endif
	


	reg start;
	reg rdfifobegin;
	reg[7:0] used_info;
	reg[7:0] status;
	reg[15:0] db_fifo;
	reg[15:0] dataout;
	reg[15:0] databuf;
	reg[15:0] insignalbuf;

	reg signed[15:0] theta_d,dtheta_d,ddtheta_d;
	wire signed[31:0] theta_desire,theta_d32,theta_dtemp,theta_dtemp_abs,theta_dlimit;
	wire signed[31:0] dtheta_d32,dtheta_d32_t,ddthetad;

	reg[31:0] debug;
	reg[15:0] debugbuf;
	reg[15:0] error_cnt;
	wire[31:0] u_out;

	/*-----------debug variable---------------- */
	wire[31:0] u_debug;
	reg[15:0] u_debug_buffer;
	/*---------Add user logic here -------------*/
	assign rdn = cs|rd;
	assign wrn = cs|wr;


	/* --------- timer -----------------*/
	control_timer inst1 (clk, rst_n, clk_h, clk_l,clk_m);


	/*---------  model inst----------- */
	`ifdef NOMINAL	
	reg [7:0] stop_cnt;
	wire stop_rst;
	//nominal model controller
	smc_3_1_nc smc_3_1_nc_instance (
		.thetad(theta_d32),
		.dthetad(dtheta_d32),
		.ddthetad(ddthetad),
		.thetan(thetan),
		.dthetan(dthetan),
		.u(nu)
	);

	smc_3_1_nominal smc_3_1_nominal_instance (
		.stop_rst(stop_rst)
		.rst_n(rst_n),
		.start(start_model),
		.done(done_model),
		.u(nu),
		.thetan(thetan),
		.dthetan(dthetan)
	);

	smc_3_1_control smc_3_1_control_instance (
		.rst_n(rst_n),
		.start(start_model),
		.nu(nu),
		.thetan(thetan),
		.dthetan(dthetan),
		.theta(enc_inc32),
		.dtheta(dtheta),
		.u(controller_u)
	);
	`elsif SMC_2_2
	//Reaching law
	smc_2_2 smc_2_2_instance (
		.thetad(theta_d32),
		.dthetad(dtheta_d32),
		.ddthetad(ddthetad),
		.theta(enc_inc32),
		.dtheta(dtheta),
		.u(controller_u)
	);
	`elsif SMC_1
	smc_simple smc_simple_instance (
		.thetad(theta_d32),
		.dthetad(dtheta_d32),
		.ddthetad(ddthetad),
		.theta(enc_inc32),
		.dtheta(dtheta),
		.u(controller_u)
	);
	`elsif OBSERVE
	wire signed[31:0] dp;
	reg [7:0] stop_cnt;
	wire stop_rst;
	smc_ob_ctrl smc_ob_ctrl_instance (
		.thetad(theta_desire),
		.dthetad(dtheta_d32),
		.ddthetad(ddthetad),
		.theta(enc_tama32),
		.dtheta(dtheta),
		.dp(dp),
		.u(controller_u)
	);
	smc_obv_ob smc_obv_ob_instance (
		.rst_n(rst_n),
		.stop_rst(stop_rst),
		.start(start_model),
		.done(done_model),
		.u(controller_u),
		.dtheta(dtheta),
		.dp(dp)
	);
	assign stop_rst = (stop_cnt < 8'd50 && stop_cnt>1'b1)?1'b1:1'b0;
	`endif
	
	
	fixed_adder #(.p(32),.q(32),.n(32)) enc_error_inst (.x(enc_tama32),.y(enc_inc32),.z(enc_sub),.op(`SUB),.ov());
	assign force_cal = enc_sub <<< k_imp;
	fixed_adder #(.p(32),.q(32),.n(32)) theta_d_inst (.x(theta_desire),.y(force_cal),.z(theta_dtemp),.op(`ADD),.ov());
	assign theta_dtemp_abs = (!theta_dtemp[31])?theta_dtemp:-theta_dtemp;
	assign theta_d32 = (theta_dtemp_abs <= 32'd10922)?theta_dtemp:((!theta_dtemp[31])?32'd10922:32'hffffd556);
	
	//Encoder position and velocity calculated logic
	assign theta_desire = $signed({{16{intpl_thetad_r2[15]}},intpl_thetad_r2});
	assign enc_tama32 = $signed({{16{backsignal[15]}},backsignal});
	assign enc_inc32  = $signed({{16{enc_inc[15]}},enc_inc});

	assign dtheta_d32 = $signed({{16{dtheta_d_r[15]}},dtheta_d_r});
	assign ddthetad = $signed({{16{ddtheta_d_r[15]}},ddtheta_d_r});

	always@(posedge clk_c or negedge rst_n)begin
		if(!rst_n)
			delay_theta_r <= 0;
		else begin
			delay_theta_r[15:0] <= enc_tama32[15:0];
			delay_theta_r[(delay_vel)-1:16] <= delay_theta_r[(delay_vel)-17:0];
		end
	end

	assign theta_delay = delay_theta_r[(delay_vel)-1:(delay_vel)-16];
	fixed_adder #(.p(32),.q(32),.n(32)) inst9 (.x(enc_tama32),.y($signed({{16{theta_delay[15]}},theta_delay})),.z(theta_delay_t1),.op(`SUB),.ov());

	fixed_multiplier #(32,16,32) inst3(theta_delay_t1,16'd100,dtheta,);

	always@(posedge clk_c or negedge rst_n) begin
		if(!rst_n)
			theta_dot_r <= 32'd0;
		else
			theta_dot_r <= dtheta;
	end

	fixed_adder #(32,32,32) inst4(dtheta,theta_dot_r,ddtheta,`SUB,);

	//interpolation
	//position
	always@(posedge clk_c or negedge rst_n)begin
		if(!rst_n)
			intpl_cnt <= 8'd0;
		else if(intpl_cnt == 8'd9)
			intpl_cnt <= 8'd0;
		else
			intpl_cnt <= intpl_cnt + 1'b1;
	end
	always@(posedge clk_c or negedge rst_n)begin
		if(!rst_n)begin
			intpl_thetad_r <= 16'd0;
			intpl_thetad_temp <= 16'd0;
			intpl_thetad_r2<= 16'd0;
			end
		else if(intpl_cnt == 8'd0) begin
			intpl_thetad_r <= theta_d;
			intpl_thetad_r2 <= intpl_thetad_r;
			intpl_thetad_temp <= intpl_thetad_r;
		end
		else
			intpl_thetad_r2 <= intpl_thetad_next;
	end
	
	fixed_adder #(.p(16),.q(16),.n(16)) intpl_error_inst (.x(intpl_thetad_r),.y(intpl_thetad_temp),.z(intpl_error),.op(`SUB),.ov());
	fixed_multiplier #(.p(16),.q(9),.n(25)) intpl_temp_inst (.x(intpl_error),.y(9'b110011001),.z(intpl_error_temp),.ov());
	assign inte_error_dt = intpl_error_temp>>>12;
	fixed_adder #(.p(16),.q(16),.n(16)) intpl_inc_inst (.x(intpl_thetad_r2),.y(inte_error_dt),.z(intpl_thetad_next),.op(`ADD),.ov());
	
	//velocity
	always @(posedge clk_c or negedge rst_n) begin
		if(!rst_n)
			dtheta_d_r <= 16'd0;
		else
			dtheta_d_r <= dtheta_d;
	end
	
	//acclerate
	always @(posedge clk_c or negedge rst_n) begin
		if(!rst_n)
			ddtheta_d_r <= 16'd0;
		else
			ddtheta_d_r <= ddtheta_d;		
	end
	

	/*------------- read ----------- */
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
							4'd0:dataout <= theta_desire;
							4'd1:
							begin
								dataout <= {enc_tama32[15:0]};
								databuf <= {enc_tama32[31:16]};
							end
							4'd2:
							begin
								dataout <= databuf;
							end
							4'd3:
							begin
								dataout <= {start_flag,start_flag_1,start_flag_2};
							end
							4'd4: dataout <= controller_u;

							4'd5: dataout <= {pul_enable_out,rdfifobegin,start};
							4'd6: dataout <= rateout;
							4'd7: dataout <= enc_inc32[15:0];
							4'd8:
							begin
								dataout <= u_debug[15:0];
								u_debug_buffer <= u_debug[31:16];
							end
							4'd9:
							begin
								dataout <= theta_d32[15:0];
								//debugbuf <= theta_e_r[31:16];
							end
							4'd10: dataout <= dtheta_d32[15:0];
							4'd11:
							begin
								dataout <= ddthetad[15:0];
								//debugbuf <= theta_dot_r[31:16];
							end
							`ifdef NOMINAL
							4'd12: dataout <= thetan[31:16];
							4'd13:
							begin
								dataout <= dthetan[31:16];
								//debugbuf <= thetan[31:16];
							end
							4'd14: dataout <= nu;
							`elsif OBSERVE
							4'd12:dataout <= dp;
							4'd13,4'd14:dataout<=15'd10;
							`endif
							4'd15: dataout <= dtheta;
							default:;
						endcase
					end
			end
	end

	/*------------- write ------------- */
	/*
	always@(negedge wrn or negedge rst_n)begin
		if(!rst_n) begin
			start <= 1'd0;
			rdfifobegin <= 1'd0;
			pul_enable_out <= 1'd0;
		end
		else if(!wrn)begin
			case(addr)
				4'd1:{insignal[15:0]} <= indata;
				4'd2:;
				4'd3:;
				4'd4:;
				4'd5:
				begin
					case(indata)
						16'd0:
						begin
							start <= 1'd0;
							rdfifobegin <= 1'd0;
							pul_enable_out <= 1'd0;
						end
						16'd1:
						begin
							start <=1'd1;
							rdfifobegin <= 1'd1;
							pul_enable_out <=1'd1;
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
				default:;
			endcase
		end
	end
	
	*/


	/*------------- for debug --------- */
	`ifdef DEBUG
	always@(*)
	begin
		debug[15:0] = rataout;
			wire signed [31:0]debug_variable1 ;
	wire signed [31:0]debug_variable2;
	assign debug_variable1 = 32'h8ffffff0 * 2'd2;
	assign debug_variable2 = (debug_variable1 >>>3);
	end
	`endif

	/*------------start logic ----------- */
	wire start_flag;
	reg start_flag_1,start_flag_2;
	assign start_flag = start_flag_1 ^ start_flag_2;
	reg start_model,done_model;
	always@(posedge clk_l,negedge rst_n) begin
		if(!rst_n)begin
			start_flag_1<=0;
		end
		else
			if(status == 0)
				start_flag_1 <= !start_flag_1;
			else begin
				start_flag_1 <= start_flag_1;
				debug <= debug + 1'd1;
			end
	end
	/*-------------- main -----------*/
	always@(posedge clk_h or negedge rst_n or negedge wrn)begin
		if(!rst_n)begin
			status<=  8'd0;
			rateout<= 16'd5000;
			u <= 16'd0;
			error_cnt <= 16'd0;
			start_flag_2 <= 1'd0;

			tama_temp <= 16'd0;
			tama_temp_r <= 16'd0;

			rdfifobegin <= 1'd0;
			fifo_no_empty <= 1'd0;
			fifo_clr <= 1'd0;
			start  <= 1'd0;
			rd_code_out <= 1'd1;
			wr_rate_out <= 1'd1;
			cs_code_out <= 2'b11;
			cs_rate_out <= 1'd1;
			pul_enable_out <= 1'd0;
			rd_clk <= 1'd0;
			theta_d <= 16'd0;
			start_model <= 1'd0;
			done_model <= 1'd0;
		end
		else begin
			if(!wrn)begin
				case (addr)
					4'd1:
					begin
						theta_d <= indata;
					end
					4'd2:
					begin
						dtheta_d <= indata;
					end
					4'd3:
					begin
						ddtheta_d <= indata;
					end
					4'd4:;
					4'd5:
					begin
						case (indata)
							16'd0:
							begin
								start <= 1'd0;
								rdfifobegin <= 1'd0;
								pul_enable_out <= 1'd0;
								`ifdef OBSERVE
								stop_cnt <= 8'd0;
								`elsif NOMINAL
								stop_cnt <= 8'd0;								
								`endif
								
							end
							16'd1:
							begin
								start <= 1'd1;
								rdfifobegin <= 1'd1;
								pul_enable_out <= 1'd1; //TODO:ENABLE
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
					default:;
				endcase
			end
			else begin
				if(clk_h)begin
					case(status)
						8'd0:
						if(start_flag)
							status <= status + 1'd1;
						8'd1:
						begin
							if(rdfifobegin)
								begin
									rd_clk <= 1'd1;
									status <= status +1'd1;
								end
							else status <= 8'd9;
						end
						8'd2:
						begin
							db_fifo <= rddata;
							used_info <= usedfifo;
							rd_empty <= rdempty;
							status <= status + 1'd1;
						end
						8'd3:
						begin
							if(fifo_no_empty)begin
								//	theta_d[15:0] <= db_fifo;
								error_cnt <= error_cnt +1'd1;
							end
							rd_clk <= 1'd0;
							status <= status + 1'd1;
						end
						8'd4:
						begin
							if(rd_empty == 1'd0)
								fifo_no_empty <= 1'd1;
							else
								fifo_no_empty <= 1'd0;
							status <= status + 1'd1;
						end
						8'd5:
						begin
							outaddr_out <= 4'd1;
							cs_code_out <= 2'd1;
							status <= status + 1'd1;
						end
						8'd6:
						begin
							rd_code_out <= 1'd0;
							status <= status +1'd1;
						end
						8'd7:
						begin
							enc_inc <= backdata;
							status <= status + 1'd1;
						end
						8'd8:
						begin
							cs_code_out <= 2'd3;
							rd_code_out <= 1'd1;
							status <= status +1'd1;
						end
						8'd9:
						begin
							outaddr_out <= 4'd2;
							cs_code_out <= 2'd0;
							status <= status +1'd1;
						end
						8'd10:
						begin
							rd_code_out <= 1'd0;
							status <= status + 1'd1;
						end
						8'd11:
						begin
							lowdata <= backdata;
							status <= status +1'd1;
						end
						8'd12:
						begin
							rd_code_out <= 1'd1;
							cs_code_out <= 2'd3;
							status <= status +1'd1;
						end
						8'd13:
						begin
							outaddr_out <= 4'd3;
							cs_code_out <= 1'd0;
							status <= status +1'd1;
						end
						8'd14:
						begin
							rd_code_out <= 1'd0;
							status <= status + 1'd1;
						end
						8'd15:
						begin
							highdata <= (backdata& 4'h1);
							status <= status + 1'd1;
						end
						8'd16:
						begin
							tama_temp[14:0] <= {highdata[0],lowdata[15:2]};
							status <= status + 1'd1;
						end
						8'd17:begin
						backsignal <= lowdata;
						rd_code_out <= 1'd1;
						cs_code_out <= 2'd3;
						status<= 8'd19;
						end
						/* 
						8'd17:
						begin
							if(((tama_temp<15'd100 && tama_temp_r > 15'd32567)||(tama_temp_r<15'd100 && tama_temp > 15'd32567)) && backsignal[15] == 0)
								backsignal[15] <= 1;
							else if(((tama_temp<15'd100 && tama_temp_r > 15'd32567)||(tama_temp_r<15'd100 && tama_temp > 15'd32567)) && backsignal[15] == 1)
								backsignal[15] <= 0;
							status <= status + 1'd1;
						end
						8'd18:
						begin
							tama_temp_r <= tama_temp;
							rd_code_out <= 1'd1;
							cs_code_out <= 2'd3;
							backsignal[14:0] <= {highdata[0],lowdata[15:2]};
							if(start)
								status <= status +1'd1;
							else
								status <= 1'd0;
						end
						*/
						8'd19:
						begin
							clk_c <= 1'd1;
							status <= status + 1'd1;
						end
						8'd20:status <= status + 1'd1;
						8'd21:begin
							start_model <= 1'b1;
							status <= status + 1'd1;
						end
						8'd22,8'd23,8'd24,8'd25,8'd26,8'd27,8'd28,8'd29:status <= status + 1'd1;
						8'd30:begin
							done_model <= 1'b1;
							status <= status + 1'd1;
						end
						8'd31:
						begin
							if(controller_u >= 16'd2000 && controller_u < 16'h8000)
								u <= 16'd2000;
							else if (controller_u >= 16'h8000 && controller_u <= 16'hF830)
								u<= 16'hF830;
							else
								u<= controller_u;
							status <= status +1'd1;
						end
						8'd32:
						begin
							rateout <= 16'd5000 + {u[15:0]};
							status <= status + 1'd1;
						end
						8'd33:
						begin
							outaddr_out <= 4'd1;
							status <= status + 1'd1;
						end
						8'd34:
						begin
							cs_rate_out <= 1'd0;
							status <= status + 1'd1;
						end
						8'd35:
						begin
							wr_rate_out <= 1'd0;
							status <= status + 1'd1;
						end
						8'd36:
						begin
							wr_rate_out <= 1'd1;
							status <= status + 1'd1;
						end
						8'd37:
						begin
							cs_rate_out <= 1'd1;
							status <= 8'd40;
						end

						8'd40:
						begin
							clk_c <= 1'd0;
							start_model <= 1'b0;
							done_model <= 1'b0;
							status <= 8'd0;
							start_flag_2 <= !start_flag_2;
						end

						default status<=8'd0;
					endcase
					`ifdef OBSERVE
					if(stop_cnt < 8'd50)
						stop_cnt <= stop_cnt + 1'd1;
					`elsif NOMINAL
					if(stop_cnt < 8'd50)
						stop_cnt <= stop_cnt + 1'd1;
					`endif
					
				end
			end
		end
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
	assign outdata = !rdn ? dataout : 16'hzzzz;
endmodule
