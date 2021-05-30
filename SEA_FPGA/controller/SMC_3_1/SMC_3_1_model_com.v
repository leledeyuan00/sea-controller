//latency = 5;
`include "../../arithmatic/arithmatic.v"
// sfix32_En14 0.00011001100110
//10k controller frequency
`define sampletime 16'b101
//fixed_adder #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.op(),.ov());
//fixed_multiplier #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.ov());
module smc_3_1_nominal
(
	input rst_n,
	input stop_rst,
	input start,
	input done,
	input signed[31:0] u,

	output signed[31:0] thetan, //sfix32_En16
	output signed[31:0] dthetan //sfix32_En16
);
	reg signed [31:0]u_r,thetan_r1,thetan_r2,dthetan_r1,dthetan_r2;
	wire signed[31:0] ddthetan,dthetan_inc,thetan_inct;
	wire signed[47:0] thetan_inc;

	always@(posedge start or negedge rst_n or posedge stop_rst)begin
		if(!rst_n)begin
			dthetan_r2 <= 32'd0;
			thetan_r2  <= 32'd0;
			u_r <= 32'd0;
		end
		else if(stop_rst)begin
			dthetan_r2 <= 32'd0;
			thetan_re <= 32'd0;
			u_r <= 32'd0;
		end
		else begin
			dthetan_r2 <= dthetan_r1;
			thetan_r2  <= thetan_r1;
			u_r <= u;
		end
	end
	always@(posedge done or negedge rst_n or posedge stop_rst)begin
		if(!rst_n)begin
			dthetan_r1 <= 32'd0;
			thetan_r1  <= 32'd0;
		end
		else if(stop_rst)begin
			dthetan_r1 <= 32'd0;
			thetan_r1 <= 32'd0;
		end
		else begin
			dthetan_r1 <= dthetan;
			thetan_r1 <= thetan;
		end
	end
	assign ddthetan = u_r<<<4;

	fixed_multiplier #(.p(32),.q(16),.n(32)) pipe1 (.x(ddthetan),.y(`sampletime),.z(dthetan_inc),.ov());

	fixed_adder #(.p(32),.q(32),.n(32)) pipe2 (.x(dthetan_inc),.y(dthetan_r2),.z(dthetan),.op(`ADD),.ov());

	fixed_multiplier #(.p(32),.q(16),.n(48)) pipe3 (.x(dthetan),.y(`sampletime),.z(thetan_inc),.ov());
	assign thetan_inct = thetan_inc>>>16;

	fixed_adder #(.p(32),.q(32),.n(32)) pipe4 (.x(thetan_r2),.y(thetan_inct),.z(thetan),.op(`ADD),.ov());

endmodule
