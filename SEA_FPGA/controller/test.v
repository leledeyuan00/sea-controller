/* 
 * Do not change Module name 
*/
module main;
    reg clk,rst_n;
    reg signed[31:0]a,u;
    wire signed[31:0]t,t2;
    integer i;
     smc_3_1_nominal inst1(clk,rst_n,a,u,t,t2);
  initial 
    begin
    clk = 0;
   rst_n = 0;
        u = 414;
      $display("Hello, World");
      #1 rst_n = 1;
      for(i=0;i<100;i=i+1)begin
      #1 clk=~clk;end
      
      $display("%d,%d",t,t2);
      
      $finish;
    end
endmodule
`define ADD 1'b1
`define SUB 1'b0
`define sampletime 16'b10
//fixed_adder #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.op(),.ov());
//fixed_multiplier #(.p(),.q(),.n()) pipe (.x(),.y(),.z(),.ov());
module smc_3_1_nominal
(
	input clk,
	input rst_n,
	input signed[31:0] theta,
	input signed[31:0] u,

	output reg signed[31:0] thetan, //sfix32_En14
	output reg signed[31:0] dthetan_r2 //sfix32_En14
);
	reg signed [31:0] ddthetan; //six32
	wire signed [31:0] dthetan_inc;//sifx32_En14
	wire signed [47:0] thetan_inc;//sfix45_En28
	reg signed [31:0] dthetan_incr,thetan_incr,dthetan_r1,dthetan; //sfix32_En14
	wire signed [31:0] dthetan_t,thetan_t; //satuated sfix32_En14
		
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			ddthetan <= 32'd0;
		else
			ddthetan <= u <<<2;
	end
	
	fixed_multiplier #(.p(32),.q(16),.n(32)) pipe1 (.x(ddthetan),.y(`sampletime),.z(dthetan_inc),.ov());
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			dthetan_incr <= 32'd0;
		else 
			dthetan_incr <= dthetan_inc;
	end
	
	fixed_adder #(.p(32),.q(32),.n(32)) pipe2 (.x(dthetan_incr),.y(dthetan),.z(dthetan_t),.op(`ADD),.ov());
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			dthetan <= 32'd0;
			dthetan_r1 <= 32'd0;
			dthetan_r2 <= 32'd0;
			end
		else begin
			dthetan <= dthetan_t;
			dthetan_r1 <= dthetan;
			dthetan_r2 <= dthetan_r1; //delay_2
			end
	end
	
	fixed_multiplier #(.p(32),.q(16),.n(48)) pipe3 (.x(dthetan),.y(`sampletime),.z(thetan_inc),.ov());
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			thetan_incr <= 32'd0;
		else
			thetan_incr <= $signed(thetan_inc>>>16);
	end
	
	fixed_adder #(.p(32),.q(32),.n(32)) pipe4 (.x(thetan),.y(thetan_incr),.z(thetan_t),.op(`ADD),.ov());
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			thetan <= 32'd0;
	//	else if(thetan_e>32'd10000)
	//		thetan <= theta;
		else
			thetan <= thetan_t;
	end
	
	/*calibrate*/
	wire signed[31:0] thetan_et,thetan_e;
	fixed_adder #(.p(32),.q(32),.n(32)) pipe (.x((thetan>>>14)),.y(theta),.z(thetan_et),.op(`SUB),.ov());
	assign thetan_e = (thetan_et[31])?(-thetan_et):thetan_et;

endmodule

module fixed_adder
#(
	parameter p =32,
	parameter q = 32,
	parameter n = 32
)
(
	input signed[p-1:0] x,
	input signed[q-1:0] y,

	output reg signed[n-1:0] z,

	input op, // 1 add ,0 sub
	output reg ov
);
	localparam nx = max(p,q)+1;

	wire signed [p:0]xx = $signed({x[p-1],x});
	wire signed [q:0]yx = $signed({y[q-1],y});
	wire signed [nx-1:0]zx;

	assign zx = (op == 1)? xx + yx: xx - yx;

	always@(zx)begin
		ov = (&zx[nx-1:n-1])||(~(|zx[nx-1:n-1]))?0:1;
	end

	always@(ov,zx)begin
		case (ov)
			1'b0 : z = zx[n-1:0];
			1'b1 :
			begin
				if(zx[nx-1] == 1'b0)
					z = $signed({1'b0,{(n-1){1'b1}}});
				else
					z = $signed({1'b1,{(n-1){1'b0}}});
			end
		endcase
	end

	function integer max;
		input integer left,right;
		if(left > right)
			max = left;
		else
			max = right;
	endfunction
endmodule
module fixed_multiplier
#
(
	parameter p = 32,
	parameter q = 32,
	parameter n = 32
)
(
	input signed[p-1:0] x,
	input signed[q-1:0] y,

	output reg signed[n-1:0] z,
	output reg ov
);
	wire signed [p+q-1:0]zx;

	assign zx = x * y;

	always@(zx)begin
		ov = (&zx[(p+q-1):(n-1)]||(~(|zx[(p+q-1):(n-1)])))?0:1;
	end

	always@(ov,zx)
	case (ov)
		1'b0: z = zx[n-1:0];
		1'b1:
		begin
			if(zx[p+q-1] == 1'b0)
				z = $signed({1'b0,{(n-1){1'b1}}});
			else
				z = $signed({1'b1,{(n-1){1'b0}}});
		end
	endcase
endmodule