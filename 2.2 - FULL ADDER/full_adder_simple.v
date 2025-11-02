module full_adder #(parameter WIDTH = 8)(
	input wire [WIDTH-1:0] A,
	input wire [WIDTH-1:0] B,
	input wire 	       Cin,
	output wire [WIDTH-1:0] Sum,
	output wire		Cout
);

	assign {Cout,Sum} = A + B + Cin;

endmodule
