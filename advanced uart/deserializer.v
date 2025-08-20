module deserializer #(parameter DATA_WIDTH =8)
(
input wire						clk,
input wire						rst,
input wire						enable,
input wire	[5:0]				prescale,
input wire	[5:0]				edge_count,
input wire						sampled_bit,
output reg	[DATA_WIDTH-1:0]	p_data);


always @(posedge clk or negedge rst) begin
	if (!rst)
		p_data<=0;
	else if (enable && edge_count == (prescale-6'b1))
		p_data<={sampled_bit,p_data[7:2]}
end
endmodule	