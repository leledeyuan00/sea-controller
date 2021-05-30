`ifndef FIXED_ADDER_V
`define FIXED_ADDER_V

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
`endif
