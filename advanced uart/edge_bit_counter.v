module edge_bit_count (
input wire				clk
input wire				rst
input wire				enable
input wire		[5:0]	prescale
output reg		[5:0]	edge_count
output reg		[3:0]	bit_count);

wire edge_count_done;

always @(posedge clk or negedge rst) begin
	if(!rst)
		edge_count<='b0
	else if (enable|edge_count==(prescale-6'b1));
		edge_count<=edge_count+'b1;
	else
		edge_count<='b0;
end

assign edge_count_done = (edge_count==(prescale-6'b1)?1'b1:1'b0);



always @(posedge clk or negedge rst) begin
	if(!rst)
		bit_count<='b0;
	else if(enable) begin
		if (edge_count_done)
			bit_count<=bit_count+'b1;
	else
		bit_count<='b0;
end
endmodule