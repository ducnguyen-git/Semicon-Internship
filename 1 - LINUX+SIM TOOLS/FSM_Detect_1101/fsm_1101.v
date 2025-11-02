module fsm_1101(
	input wire clk,
	input wire rst_n,
	input wire a,
	output reg y
	);

	parameter s0 = 3'b000; // IDLE STATE
	parameter s1 = 3'b001; // STRING 1
	parameter s2 = 3'b010; // STRING 11
	parameter s3 = 3'b011; // STRING 110
	parameter s4 = 3'b100; // STRING 1101

reg [2:0] current_state, next_state;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		current_state <= s0;
	end else begin
		current_state <= next_state;
	end
end

always @(*) begin
	case (current_state)
		s0: next_state = a ? s1 : s0;
		s1: next_state = a ? s2 : s0; // found 1
		s2: next_state = a ? s2 : s3; // found 11
		s3: next_state = a ? s4 : s0; // found 110
		s4: next_state = a ? s2 : s0; // found 1101
	endcase
end

always @(*) begin
	y = (current_state == s4) ? 1 : 0;
end

endmodule
