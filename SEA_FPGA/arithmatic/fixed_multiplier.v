`ifndef FIXED_MULTIPLIER_V
`define FIXED_MULTIPLIER_V

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
`endif