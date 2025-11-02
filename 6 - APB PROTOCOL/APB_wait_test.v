module apb_testbench;
  	// Local parameters
  	localparam ADDR_WIDTH = 8;
  	localparam DATA_WIDTH = 8;
  	
	// Inputs
	reg pclk;
	reg prst_n;
	reg psel;
	reg penable;
	reg pwrite;
  	reg [ADDR_WIDTH-1:0] paddr;
  	reg [DATA_WIDTH-1:0] pwdata;
	
	// Outputs
	wire pready;
	wire pslverr;
  	wire [DATA_WIDTH-1:0] prdata;
	
  	// Clock generation
	initial begin
    	pclk = 1'b0;
		forever #10 pclk = ~pclk;
    end
  
	// Instantiation of DUT
  	apb_protocol #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
    ) dut (
      .pclk(pclk), 
      .prst_n(prst_n), 
      .psel(psel), 
      .penable(penable), 
      .pwrite(pwrite),
      .paddr(paddr),
      .pwdata(pwdata),
      .pready(pready), 
      .pslverr(pslverr),
      .prdata(prdata)
    );
	
	// Reset and Instantiation
	task reset_and_initialization;
		begin
			prst_n = 1'b0;
          	psel = 1'b0;
			penable = 1'b0;
			pwrite = 1'b0;
			paddr = 8'h00;
          	pwdata = 8'h00;
			@(posedge pclk);
			prst_n = 1'b1;
		end
	endtask
	
	// WRITE transfer
	task write_transfer;
      input [ADDR_WIDTH-1:0] addr;
      input [DATA_WIDTH-1:0] data_in;
		begin
          	// SETUP phase
          	@(posedge pclk);
			psel = 1'b1;
			pwrite = 1'b1;
          	paddr = addr;
          	pwdata = data_in;
          	
          	// ACCESS phase
			@(posedge pclk);
			penable = 1'b1;
			
          	wait (pready);
			@(posedge pclk);
          	psel = 1'b0;
			penable = 1'b0;
          	if (pslverr)
              $display ("Writing 8'h%h to address 8'h%h failed.", pwdata, paddr);
            else
              $display ("Writing 8'h%h to address 8'h%h successfully.", pwdata, paddr);
		end
	endtask
	
	// READ transfer
	task read_transfer;
      input [ADDR_WIDTH-1:0] addr;
		begin
          	// SETUP phase
          	@(posedge pclk);
			psel = 1'b1;
			pwrite = 1'b0;
          	paddr = addr;
          	
          	// ACCESS phase
			@(posedge pclk);
			penable = 1'b1;
			
          	wait (pready);
			@(posedge pclk);
          	psel = 1'b0;
			penable = 1'b0;
          	if (pslverr)
              $display ("Read from address 8'h%h failed.", paddr);
            else
              $display ("Read 8'h%h from address 8'h%h successfully.", prdata, paddr);
		end
	endtask
  
	// Initiate Simulation
	initial begin
      	$dumpfile("dumb.vcd");
		$dumpvars;
		reset_and_initialization;
        #10 write_transfer(8'h00, 8'd36);
        #10 write_transfer(8'h01, 8'd72);
      	#10 write_transfer(8'h02, 8'd18);
        #10 write_transfer(8'h03, 8'd05);
      	#10 write_transfer(8'h04, 8'd09);
        #10 write_transfer(8'h05, 8'd22);
        #10 write_transfer(8'h06, 8'd76);
      	#10 write_transfer(8'h07, 8'd02);
      	#10 write_transfer(8'h08, 8'd69); // Test failed
      
        #10 read_transfer(8'h00);
        #10 read_transfer(8'h01);
        #10 read_transfer(8'h02);
        #10 read_transfer(8'h03);
        #10 read_transfer(8'h04);
        #10 read_transfer(8'h05);
        #10 read_transfer(8'h06);
        #10 read_transfer(8'h07);
      	#10 read_transfer(8'h08); // Test failed
		#200; $finish;
	end
	
endmodule
