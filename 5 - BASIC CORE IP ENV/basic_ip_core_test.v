module demux_3to8_tb;
	reg pclk;
	reg preset_n;
	reg pwrite;
	reg psel;
	reg penable;
	reg [7:0] paddr;
	reg [7:0] pwdata;
	wire [7:0] prdata;
	wire pready;
	wire pslverr;

    demux_3to8 dut (
        .pclk(pclk),
        .preset_n(preset_n),
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr)
    );

    initial begin 
        pclk = 0;
        forever #10 pclk = ~ pclk;
    end

    task demux_write;
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

    task demux_read;
        input [7:0] addr_out;
        begin
            @(posedge pclk);
            psel    = 1'b1;
            pwrite  = 1'b0;
            paddr = addr_out;
            penable = 1'b0;

            @(posedge pclk);
            penable = 1'b1;

            @(posedge pclk);
          	@(posedge pclk);
            psel    = 1'b0;
            penable = 1'b0;
        end
    endtask

    integer i;
    integer a;

    initial begin
      	$dumpfile("dump.vcd"); $dumpvars;
        // Reset
        psel = 1'b0; penable = 1'b0; pwrite = 1'b0; paddr = 8'h0; pwdata = 8'h0;
        preset_n = 1'b1;
        #5 preset_n = 1'b0;
        @(posedge pclk); preset_n = 1'b1;

      	demux_write(8'h00, 8'h36);
      	for (i = 1; i < 9; i = i + 1) begin
          	demux_write(i, 1*i + 8*i);
        end

      for (a = 0; a < 9; a = a + 1) begin
            demux_read(a);
        end

        #100;
        $stop;
    end

endmodule
