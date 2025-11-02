module full_adder_bit_define #(
    parameter WIDTH=16
)(
    input [WIDTH-1:0] a,b,
    output [WIDTH-1:0] s,
    output cout
);    
    wire [WIDTH:1] c;

    full_adder_1bit fa_0(.in1(a[0]), .in2(b[0]), .cin(1'b0), .sum(s[0]), .cout(c[1]));
    
    genvar i; 
    generate
    	for (i = 1; i < WIDTH; i = i + 1) begin : instance_loop
        	full_adder_1bit fa(.in1(a[i]), .in2(b[i]), .cin(c[i]), .sum(s[i]), .cout(c[i+1]));
       	end
    endgenerate
  
    assign cout = c[WIDTH];
endmodule


module full_adder_1bit(
    input in1, in2, cin,
    output sum, cout
);
    wire s1, c1, c2;
    
    half_adder ha1(.A(in1), .B(in2), .S(s1), .Cout(c1));
    half_adder ha2(.A(s1), .B(cin), .S(sum), .Cout(c2));
    
    assign cout = c1|c2;
endmodule


module half_adder(
	input A, B,
	output S, Cout
);
	assign S = A^B;
	assign Cout = A&B;
endmodule
