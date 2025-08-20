module data_sampling(
input wire 			clk,
input wire 			rst,
input wire 			enable,
input wire 	[5:0]	prescale,
input wire 	[5:0]	edge_count,
input wire 			s_data,
output reg 			sampled_bit);

wire [4:0]		half_edge,half_edge_p1,half_edge_n1;
reg  [2:0]  samples;


assign half_edge =(prescale>>1)-'b1;
assign half_edge_n1 =half_edge+'b1;
assign half_edge_p1 =half_edge-'b1;


always @(posedge clk or negedge rst) begin
	if(!rst)
		samples <= 'b0;
	else begin
		if (enable) begin
			if (edge_count = half_edge_p1)
				samples[0] <= s_data;
			else if (edge_count = half_edge)
				samples[1] <= s_data;
			else if (edge_count = half_edge_n1)
				samples[3] <= s_data;
		else
			samples<='b0;
	end
end


always @(posedge clk or negedge rst) begin
	if(!rst)
		sampled_bit <= 'b0;
	else begin
		if (enable) begin
			case (samples)
				3'b000:sampled_bit<=0;
				3'b001:sampled_bit<=0;
				3'b010:sampled_bit<=0;
				3'b011:sampled_bit<=1;
				3'b100:sampled_bit<=0;
				3'b101:sampled_bit<=1;
				3'b110:sampled_bit<=1;
				3'b111:sampled_bit<=1;
				default:sampled_bit<=0;
			endcase
		end
		else
			sampled_bit<=0;
	end
end
endmodule