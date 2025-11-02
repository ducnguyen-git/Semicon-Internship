`define WIDTH_2		2
`define WIDTH_4		4
`define WIDTH_8		8
`define WIDTH_16	16
`define WIDTH_32	32

module tb_full_adder;
	reg	    [1:0] 	A2, B2;
	wire 	[1:0] 	SUM2;
	wire 	COUT2;

	reg	    [3:0] 	A4, B4;
	wire 	[3:0] 	SUM4;
	wire 	COUT4;

	reg	    [7:0] 	A8, B8;
	wire 	[7:0] 	SUM8;
	wire 	COUT8;

	reg	    [15:0] 	A16, B16;
	wire 	[15:0] 	SUM16;
	wire 	COUT16;

	reg	    [31:0] 	A32, B32;
	wire 	[31:0] 	SUM32;
	wire 	COUT32;

  full_adder_bit_define #(`WIDTH_2) fa_2 (.a(A2), .b(B2), .s(SUM2), .cout(COUT2));
  full_adder_bit_define #(`WIDTH_4) fa_4 (.a(A4), .b(B4), .s(SUM4), .cout(COUT4));
  full_adder_bit_define #(`WIDTH_8) fa_8 (.a(A8), .b(B8), .s(SUM8), .cout(COUT8));
  full_adder_bit_define #(`WIDTH_16) fa_16 (.a(A16), .b(B16), .s(SUM16), .cout(COUT16));
  full_adder_bit_define #(`WIDTH_32) fa_32 (.a(A32), .b(B32), .s(SUM32), .cout(COUT32));

	initial begin
      	$dumpfile("dump.vcd"); 
      	$dumpvars;
		A4 = 4'd0; B4 = 4'd0; A8 = 8'd0; B8 = 8'd0; 
      	A16 = 16'd0; B16 = 16'd0; A32 = 32'd0; B32 = 32'd0;
      
		A2 = 2'b11; B2 = 2'b01;
		#10 A4 = 4'd8; B4 = 4'd8;
      	#10 A8 = 8'd12; B8 = 4'd5;
      	#10 A16 = 16'd20; B16 = 16'd10;
      	#10 A32 = 32'd50; B32 = 32'd43;
      #500 $stop;
	end
endmodule
