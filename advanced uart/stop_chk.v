module stop_chk (
input wire			clk,
input wire			rst,
input wire			enable,
input wire			sampled_bit,
output reg			stop_err);



always @(posedge clk or negedge rst) begin
	if(!rst)
		stop_err <= 'b0;
	else if (enable)
		stop_err <= sampled_bit ^ 1'b1;
	else
		stop_err <= 'b0;
end
endmodule