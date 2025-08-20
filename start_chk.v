module start_chk (
input wire				clk,
input wire				rst,
input wire				enable,
input wire				sampled_bit,
output reg				start_glitch);


always @(posedge clk or negedge rst) begin
	if(!rst)
		start_glitch<=0;
	else if(enable)
		start_glitch <= sampled_bit;
	else
		start_glitch <= 0;
end
endmodule