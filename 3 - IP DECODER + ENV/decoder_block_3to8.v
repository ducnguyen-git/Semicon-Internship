module decoder_block_3to8 (
	input wire pclk,
	input wire preset_n,
	input wire pwrite,
	input wire psel,
	input wire penable,
	input wire [7:0] paddr,
	input wire [7:0] pwdata,
	output reg pready,
	output reg pslverr 
);

	reg [7:0] reg_a;
	reg [7:0] reg_b;
	reg [7:0] reg_c;
	reg [7:0] reg_d;
	reg [7:0] reg_e;
	reg [7:0] reg_f;
	reg [7:0] reg_g;
	reg [7:0] reg_h;

	always @( posedge pclk or negedge preset_n) begin
		if (!preset_n) begin
			reg_a <= 8'h00;
			reg_b <= 8'h00;
			reg_c <= 8'h00;
			reg_d <= 8'h00;
			reg_e <= 8'h00;
			reg_f <= 8'h00;
			reg_g <= 8'h00;
			reg_h <= 8'h00;
			pslverr <= 1'b0;
          	pready <= 1'b0;
		end else begin
			if (psel) begin
				pready <= 1'b1;
              if (penable) begin
				if (pwrite) begin 
					case (paddr)
						8'h00: reg_a <= pwdata;
						8'h01: reg_b <= pwdata;
						8'h02: reg_c <= pwdata;
						8'h03: reg_d <= pwdata;
						8'h04: reg_e <= pwdata;
						8'h05: reg_f <= pwdata;
						8'h06: reg_g <= pwdata;
						8'h07: reg_h <= pwdata;
						default: pslverr <= 1'b1;
					endcase
                end
              end
			end
		end
	end

endmodule
