`include "../../arithmatic/arithmatic.v"
//fixed_adder #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.op(),.ov());
//fixed_multiplier #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.ov());
//10k controller frequency
`define sampletime 16'b101

module smc_obv_ob(
	input rst_n,
	input stop_rst,
	input start,
	input done,

	input signed [31:0] u,
	input signed [31:0] dtheta,

	output signed [31:0] dp
);

	/*		coefficient		 */
	localparam k = 9'd50;
	localparam J = 7;
	localparam b = 9'd25;

	/*		variable		 */
	reg signed[31:0] z_r1,z_r2,u_r;
	wire signed [31:0] z,dz,dz_inc,dz_inc_t;
	wire signed [31:0] b_dth,b_dth_t,k_dth,k_dth_t;
	wire signed [31:0] bdth_u,temp_z;

	always @(posedge start or negedge rst_n or posedge stop_rst) begin
		if(!rst_n)
			u_r <= 32'd0;
		else if(stop_rst)
			u_r <= 32'd0;
		else
			u_r <= u;
	end

	always @(posedge start or negedge rst_n or posedge stop_rst) begin
		if(!rst_n)
			z_r2 <= 32'd0;
		else if(stop_rst)
			z_r2 <= 32'd0;
		else
			z_r2 <= z_r1;
	end

	always @(posedge done or negedge rst_n or posedge stop_rst) begin
		if(!rst_n)
			z_r1 <= 32'd0;
		else if(stop_rst)
			z_r1 <= 32'd0;
		else
			z_r1 <= z;
	end

	fixed_multiplier #(.p(32),.q(9),.n(32)) comb_1_1 (.x(dtheta),.y(k),.z(k_dth_t),.ov());
	assign k_dth = k_dth_t >>> J;
	fixed_multiplier #(.p(32),.q(9),.n(32)) comb_1_2 (.x(dtheta),.y(b),.z(b_dth_t),.ov());
	assign b_dth = b_dth_t >>> J;

	fixed_adder #(.p(32),.q(32),.n(32)) comb_2_1 (.x(k_dth),.y(z_r2),.z(dp),.op(`ADD),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) comb_2_2 (.x(b_dth),.y(u_r),.z(bdth_u),.op(`SUB),.ov());

	fixed_adder #(.p(32),.q(32),.n(32)) comb_3 (.x(bdth_u),.y(dp),.z(temp_z),.op(`SUB),.ov());
	
	fixed_multiplier #(.p(32),.q(9),.n(32)) comb_4 (.x(temp_z),.y(k),.z(dz),.ov());
	
	fixed_multiplier #(.p(32),.q(16),.n(48)) comb_5 (.x(dz),.y(`sampletime),.z(dz_inc_t),.ov());
	assign dz_inc = dz_inc_t>>>16;
	
	fixed_adder #(.p(32),.q(32),.n(32)) comb_6 (.x(z_r2),.y(dz_inc),.z(z),.op(`ADD),.ov());

endmodule
