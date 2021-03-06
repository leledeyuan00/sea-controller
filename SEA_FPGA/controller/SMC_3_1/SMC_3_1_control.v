`include "../../arithmatic/arithmatic.v"
//fixed_adder #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.op(),.ov());
//fixed_multiplier #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.ov());
module smc_3_1_control(
	input rst_n,
	input start,

	input signed [31:0] nu, //sfix32

	input signed [31:0] thetan, //sfix32_En14
	input signed [31:0] dthetan, //sfix32_En14

	input signed [31:0] theta, //sfix32
	input signed [31:0] dtheta, //sfix32

	output signed [15:0] u
);
	/*coefficient */
	localparam Bn 	= 16'd400;
	localparam Jn 	= 8'd16;
	localparam lamt = 8'd25; //Bn/Jn
	localparam Ja 	= 8'd17; // Jm = 2.5 JM = 3.5 Ja = 1/2(Jm + JM)
	localparam Je 	= 8'd6; // Je = JM - Jm
	localparam Ba 	= 16'd400; // Bm = 7 BM = 13 Ba = 1/2(Bm + BM)
	localparam Be 	= 8'd20; //(BM - Bm)/2
	localparam dM 	= 32'd10000;
	localparam K  	= 8'd10;
	/*variable */
	wire signed[31:0] e,de,ldth,le,Jnu,Ba_dth,temp;
	wire signed[31:0] abs_dth,abs_temp,s,h_1;
	wire signed[31:0] h_2,h_3,ks,Jtemp;
	wire signed[31:0] h;
	wire signed[32:0] u_1,u_2,ut;

	reg signed[31:0]u_r;
	always@(posedge start or negedge rst_n)begin
		if(!rst_n)
			u_r <= 32'd0;
		else
			u_r <= u;
	end

	fixed_adder #(.p(32),.q(32),.n(32)) pipe1_1 (.x(theta),.y($signed(thetan>>>16)),.z(e),.op(`SUB),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe1_2 (.x(dtheta),.y($signed(dthetan>>>16)),.z(de),.op(`SUB),.ov());
	fixed_multiplier #(.p(32),.q(8),.n(32)) pipe1_3 (.x(dtheta),.y(lamt),.z(ldth),.ov());
	assign Jnu = u_r>>>4; // nu/Jn pipe1_4
	assign abs_dth = dtheta[31]?(-dtheta):dtheta; // pipe1_5
	fixed_multiplier #(.p(32),.q(16),.n(32)) pipe1_6 (.x(dtheta),.y(Ba),.z(Ba_dth),.ov());

	fixed_multiplier #(.p(32),.q(8),.n(32)) pipe2_1 (.x(e),.y(lamt),.z(le),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe2_2 (.x(Jnu),.y(ldth),.z(temp),.op(`SUB),.ov());
	assign abs_temp = temp[31]?(-temp):temp; // pipe2_3
	fixed_multiplier #(.p(32),.q(8),.n(32)) pipe2_4 (.x(abs_dth),.y(Be),.z(h_1),.ov());

	fixed_adder #(.p(32),.q(32),.n(32)) pipe3_1 (.x(de),.y(le),.z(s),.op(`ADD),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe3_2 (.x(h_1),.y(dM),.z(h_2),.op(`ADD),.ov());
	assign h_3 = abs_temp >>>1; //abs_temp /2; pipe3_3
	fixed_multiplier #(.p(32),.q(8),.n(32)) pipe3_4 (.x(temp),.y(Ja),.z(Jtemp),.ov());

	fixed_multiplier #(.p(32),.q(8),.n(32)) pipe4_1 (.x(s),.y(K),.z(ks),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe4_2 (.x(h_2),.y(h_3),.z(h),.op(`ADD),.ov());
	
	fixed_adder #(.p(32),.q(32),.n(32)) pipe5_1 (.x(Ba_dth),.y(ks),.z(u_1),.op(`SUB),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe5_2 (.x(Jtemp),.y(h),.z(u_2),.op(s[31]),.ov());

	fixed_adder #(.p(32),.q(32),.n(32)) pipe6_1 (.x(u_1),.y(u_2),.z(ut),.op(`ADD),.ov());

	assign u = ut >>6;

endmodule
