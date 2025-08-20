module parity_chk #(parameter DATA_EIDTH=8)
(input wire						clk,
input wire						rst,
input wire						enable,
input wire						parity_type,
input wire						sampled_bit,
input wire	[DATA_EIDTH-1:0]	p_data,
output reg						parity_err);

wire parity;

always @(*) begin
	case(parity_type) begin
		1'b0:parity <= ^p_data;
		1'b1:parity <= ~^p_data;
	endcase
end


always @(posedge clk or negedge rst) begin
	if(!rst)
		parity_err <= 0;
	else if(enable)
		parity_err <= parity ^ sampled_bit;
	else
		parity_err <=0;
end
endmodule