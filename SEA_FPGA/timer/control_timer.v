// clk_h & clk_l phase 50% differ
module control_timer
(
	input clk,
	input rst_n,
	output reg clk_h,
	output reg clk_l,
	output reg clk_m
);


	reg[15:0] cnt;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			cnt <= 0;
		else begin
			if(cnt == 14'd9999)begin
				cnt <= 0;
				clk_l <= 1;
			end
			else if(cnt < 14'd5000)
				cnt <= cnt +1'd1;
			else begin
				cnt <= cnt +1'd1;
				clk_l <= 0;
			end
		end
	end

	reg[7:0] cnt_h;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			cnt_h <=0;
		else begin
			if(cnt_h == 8'd100)begin
				cnt_h <= 0;
				clk_h <= 1;
			end
			else if(cnt_h < 8'd50)
				cnt_h <= cnt_h +1'd1;
			else begin
				cnt_h <= cnt_h +1'd1;
				clk_h <= 0;
			end
		end
	end
	
	reg[7:0] cnt_m;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			cnt_m <=0;
		else begin
			if(cnt_m == 8'd1000)begin
				cnt_m <= 0;
				clk_m <= 1;
			end
			else if(cnt_m < 8'd500)
				cnt_m <= cnt_m +1'd1;
			else begin
				cnt_m <= cnt_m +1'd1;
				clk_m <= 0;
			end
		end
	end
endmodule