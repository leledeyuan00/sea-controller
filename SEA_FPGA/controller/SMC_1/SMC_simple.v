`include "../../arithmatic/arithmatic.v"

module smc_simple(
	input signed[31:0] thetad,
	input signed[31:0] dthetad,
	input signed[31:0] ddthetad,
	input signed[31:0] theta,
	input signed[31:0] dtheta,

	output signed[31:0] u
);

	localparam J = 8'd10;
	localparam c = 8'd20; //fix2_en1
	localparam xite = 32'd10000; //fix32

	wire signed[31:0] ce;
	wire signed[31:0] s;
	wire signed[31:0] cde;
	wire signed[31:0] chater;
	wire signed[31:0] u_1;
	wire signed[31:0] u_2;
	wire signed[31:0] u_3;
	wire signed[31:0] xite_neg;

	wire signed[31:0] theta_e,dtheta_e;

	fixed_adder #(.p(32),.q(32),.n(32)) theta_e_inst (.x(theta),.y(thetad),.z(theta_e),.op(`SUB),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) dtheta_e_inst (.x(dtheta),.y(dthetad),.z(dtheta_e),.op(`SUB),.ov());

	fixed_adder #(32,32,32)inst7(32'd0,xite,xite_neg,`SUB,);

	fixed_multiplier #(32,8,32)	inst1(theta_e,c,ce,); //ce = c * theta_e    --- sfixed32_En1
	fixed_adder #(32,32,32) inst2(ce,dtheta_e,s,`ADD,); //s = c * theta_e + dtheta_e    --- sfixed32_En1
	fixed_multiplier #(32,8,32) inst3(dtheta_e,c,cde,); //cde = c * dtheta_e  --- sfixed32_En1

	assign chater = (s[31] == 1'b0)?xite:xite_neg; // sfixed32_En0

	fixed_adder #(32,32,32) inst4(ddthetad,cde,u_1,`SUB,); // sfixed32_En1
	fixed_adder #(32,32,32) inst5(u_1,chater,u_2,`SUB,); // sfixed32_En1
	fixed_multiplier #(32,8,32) inst6(u_2,J,u_3,); //sfixed_En1
	assign u = u_3>>>7;
endmodule
