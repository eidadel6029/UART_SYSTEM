module uart_rx_fsm #(parameter DATA_WIDTH =8)(
input wire									clk,
input wire									rst,
input wire									s_data,
input wire		[5:0]						prescale,
input wire		[5:0]						edge_count,
input wire		[3:0]						bit_count,
input wire									start_glitch,
input wire									stop_error,
input wire									parity_error,
output reg									data_sampling_en,
output reg									edge_bit_en,
output reg									deserializer_en,
output reg									start_chk_en,
output reg									stop_chk_en,
output reg									parity_chk_en,
output reg									data_valid);

localparam [2:0]  	IDEL=3'b000,
					START=3'b001,
					DATA=3'b010,
					PARITY=3'b011,
					STOP=3'b100,
					ERROR_CHK=3'b101;
					
reg [2:0] current_state, next_state;
wire [5:0] chk_edge,error_chk_edge; 