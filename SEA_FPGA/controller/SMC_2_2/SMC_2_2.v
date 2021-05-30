`include "../../arithmatic/arithmatic.v"

module smc_2_2(
	input signed[31:0] thetad,
	input signed[31:0] dthetad,
	input signed[31:0] ddthetad,
	input signed[31:0] theta,
	input signed[31:0] dtheta,

	output signed[31:0] u
);

	localparam c = 32'd20; //fixe32
	localparam xite = 32'd10000; //fix32
	localparam k = 32'd10;

	wire signed[31:0] ce;
	wire signed[31:0] s;
	wire signed[31:0] ks;
	wire signed[31:0] cde;
	wire signed[31:0] chater;
	wire signed[31:0] u_1;
	wire signed[31:0] u_2;
	wire signed[31:0] u_3;
	wire signed[31:0] u_4;
	wire signed[31:0] xite_neg;
	wire signed[31:0] fx;

	wire signed[31:0] theta_e,dtheta_e;

	fixed_adder #(.p(32),.q(32),.n(32)) theta_e_inst (.x(theta),.y(thetad),.z(theta_e),.op(`SUB),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) dtheta_e_inst (.x(dtheta),.y(dthetad),.z(dtheta_e),.op(`SUB),.ov());


	fixed_adder #(32,32,32)inst7(32'd0,xite,xite_neg,`SUB,);

	fixed_multiplier #(32,32,32) inst1(theta_e,c,ce,); //ce = c * theta_e    --- sfixed32
	fixed_adder #(32,32,32) inst2(ce,dtheta_e,s,`ADD,); //s = c * theta_e + dtheta_e    --- sfixed32
	fixed_multiplier #(32,32,32) inst3(dtheta_e,c,cde,); //cde = c * dtheta_e  --- sfixed32
	fixed_multiplier #(32,32,32) inst8(32'd15,dtheta,fx,); //sfixed32
	fixed_multiplier #(32,32,32) inst10(k,s,ks,);

	assign chater = (s[31] == 1'b0)?xite:xite_neg; // sfixed32_En0

	fixed_adder #(32,32,32) inst4(ddthetad,cde,u_1,`ADD,); // sfixed32_En1
	fixed_adder #(32,32,32) inst5(ks,chater,u_2,`ADD,); // sfixed32_En1
	fixed_adder #(32,32,32) inst9(u_1,u_2,u_3,`ADD,);
	fixed_adder #(32,32,32) inst11(u_3,fx,u_4,`ADD,);

	assign u = (-u_4)>>>6; // b = 128
endmodule
