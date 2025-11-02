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