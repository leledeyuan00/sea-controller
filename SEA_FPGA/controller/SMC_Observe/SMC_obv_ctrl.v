`include "../../arithmatic/arithmatic.v"
//fixed_adder #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.op(),.ov());
//fixed_multiplier #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.ov());
module smc_ob_ctrl(
	input signed[31:0] thetad,
	input signed[31:0] dthetad,
	input signed[31:0] ddthetad,
	input signed[31:0] theta,
	input signed[31:0] dtheta,
	input signed[31:0] dp,

	output signed[31:0]u
);

	/*  coefficient    */
	localparam Jd = 7; //128
	localparam Jm = 7;
	localparam b = 9'd25;
	localparam c = 9'd10;
	localparam xite = 32'd1000;
	localparam k = 9'd10;


	/*  variable       */
	wire signed[31:0] e, de,b_dth;
	wire signed[31:0] ce,cde,obv_e;
	wire signed[31:0] s,s_xite,obv,u_1;
	wire signed[31:0] ks,u_2,u_3;
	wire signed[31:0] ut;

	fixed_adder #(.p(32),.q(32),.n(32)) pipe1_1 (.x(thetad),.y(theta),.z(e),.op(`SUB),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe1_2 (.x(dthetad),.y(dtheta),.z(de),.op(`SUB),.ov());
	fixed_multiplier #(.p(32),.q(9),.n(32)) pipe1_3 (.x(dtheta),.y(b),.z(b_dth),.ov());

	fixed_multiplier #(.p(32),.q(9),.n(32)) pipe2_1 (.x(e),.y(c),.z(ce),.ov());
	fixed_multiplier #(.p(32),.q(9),.n(32)) pipe2_2 (.x(de),.y(c),.z(cde),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe2_3 (.x(b_dth),.y(dp),.z(obv_e),.op(`SUB),.ov());

	fixed_adder #(.p(32),.q(32),.n(32)) pipe3_1 (.x(ce),.y(de),.z(s),.op(`ADD),.ov());
	assign s_xite = s[31]?-xite:xite; //pipe3_2
	fixed_adder #(.p(32),.q(32),.n(32)) pipe3_3 (.x(cde),.y(ddthetad),.z(u_1),.op(`ADD),.ov());
	assign obv = obv_e >>> Jm;

	fixed_multiplier #(.p(32),.q(9),.n(32)) pipe4_1 (.x(s),.y(k),.z(ks),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe4_2 (.x(obv_e),.y(s_xite),.z(u_2),.op(`ADD),.ov());

	fixed_adder #(.p(32),.q(32),.n(32)) pipe5_1 (.x(u_1),.y(u_2),.z(u_3),.op(`ADD),.ov());

	fixed_adder #(.p(32),.q(32),.n(32)) pipe6_1 (.x(u_3),.y(ks),.z(ut),.op(`ADD),.ov());
	assign u = ut >>> Jd ;
endmodule
