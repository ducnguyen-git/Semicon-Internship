module demux_3to8_tb;
	reg pclk;
	reg preset_n;
	reg pwrite;
	reg psel;
	reg penable;
	reg [7:0] paddr;
	reg [7:0] pwdata;
	wire pready;
	wire pslverr;

	decoder_block_3to8 dut (
		.pclk(pclk),
        .preset_n(preset_n),
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable),
        .paddr(paddr),
        .pwdata(pwdata),
        .pready(pready),
		.pslverr(pslverr)
	);

	initial begin 
		pclk = 0;
		forever #10 pclk = ~ pclk;
	end

	task decoder_write;
		input [7:0] addr_in;
		input [7:0] data_in;
		begin 
			@(posedge pclk);
			psel	= 1'b1;
			pwrite	= 1'b1;
			pwdata	= data_in;
			paddr	= addr_in;
			penable	= 1'b0;

			@(posedge pclk);
			penable	= 1'b1;

			@(posedge pclk);
			@(posedge pclk);
			psel	= 1'b0;
			penable	= 1'b0;
		end
	endtask

  integer i;

	initial begin
      	$dumpfile("dump.vcd"); $dumpvars;
		// Reset
		psel = 1'b0; penable = 1'b0; pwrite = 1'b0; paddr = 1'b0; pwdata = 8'h0;
		preset_n = 1'b1;
		#5 preset_n = 1'b0;
		@(posedge pclk); preset_n = 1;

		//ghi 8 thanh ghi
		decoder_write(8'h00, 8'h33);
      	for (i = 8'h01; i < 8'h09; i = i + 8'h01) begin
          decoder_write(i, 3*i + 6*i);
		end 

		#100;
		$stop;
	end

endmodule
