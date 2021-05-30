`include "../../arithmatic/arithmatic.v"
//fixed_adder #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.op(),.ov());
//fixed_multiplier #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.ov());
module smc_3_1_nc(
	input signed[31:0] thetad, //sifx32
	input signed[31:0] dthetad,
	input signed[31:0] ddthetad,
	
	input signed[31:0] thetan, //sfix32_En16
	input signed[31:0] dthetan,//sfix32_En16
	
	output signed[31:0] u //sfix32
);
	localparam k  = 16'd20;
	localparam Bn = 16'd400;
	localparam Jn = 8'd16;
	localparam h1 = 16'd400; //k^2
	localparam h2 = 16'd15; //2*k - Bn/Jn
	localparam h3 = 8'd25; //Bn/Jn
	
	wire signed[31:0] e,de,eh,deh,dthdh,esum,esum1,esum2,ut;
	
	fixed_adder #(.p(32),.q(32),.n(32)) pipe1_1 (.x($signed(thetan>>>16)),.y(thetad),.z(e),.op(`SUB),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe1_2 (.x($signed(dthetan>>>16)),.y(dthetad),.z(de),.op(`SUB),.ov());

	fixed_multiplier #(.p(32),.q(16),.n(32)) pipe2_1 (.x(e),.y(h1),.z(eh),.ov());
	fixed_multiplier #(.p(32),.q(16),.n(32)) pipe2_2 (.x(de),.y(h2),.z(deh),.ov());
	fixed_multiplier #(.p(32),.q(8),.n(32)) pipe2_3 (.x(dthetad),.y(h3),.z(dthdh),.ov());
	
	fixed_adder #(.p(32),.q(32),.n(32)) pipe3_1 (.x(eh),.y(deh),.z(esum1),.op(`ADD),.ov());
	fixed_adder #(.p(32),.q(32),.n(32)) pipe3_2 (.x(ddthetad),.y(dthdh),.z(esum2),.op(`ADD),.ov());
	
	fixed_adder #(.p(32),.q(32),.n(32)) pipe4_1 (.x(esum2>>>2),.y(esum1),.z(esum),.op(`SUB),.ov());
	
	fixed_multiplier #(.p(32),.q(8),.n(32)) pipe5_1 (.x(esum),.y(Jn),.z(ut),.ov());
	
	assign u = ut;
endmodule
