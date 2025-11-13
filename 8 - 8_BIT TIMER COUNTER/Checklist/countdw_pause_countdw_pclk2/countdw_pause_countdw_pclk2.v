// countdw_pause_countdw_pclk2.v
module countdw_pause_countdw_pclk2;
  localparam DATA_WIDTH = 8;
  localparam ADDR_WIDTH = 3;
  localparam COUNT_PAUSE = 10;
  
  reg [3:0] clk_in;
  reg pclk, preset_n;
  reg psel, pwrite, penable;
  reg [ADDR_WIDTH-1:0] paddr;
  reg [DATA_WIDTH-1:0] pwdata;
  
  wire [DATA_WIDTH-1:0] prdata;
  wire pready, pslverr;
  wire TMR_OVF, TMR_UDF;
  
  always #10 pclk = ~pclk;
  
  // Prescaler Initialization
  prescaler pres_dut(
    .clk_in(pclk), 
    .reset_n(preset_n), 
    .clk_0(clk_in[0]), 
    .clk_1(clk_in[1]), 
    .clk_2(clk_in[2]), 
    .clk_3(clk_in[3])
	);
  
  timer_counter_8bit timer_dut(
    .clk_in(clk_in),
    .pclk(pclk), 
    .preset_n(preset_n), 
    .psel(psel), 
    .pwrite(pwrite), 
    .penable(penable),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready), 
    .pslverr(pslverr),
    .TMR_OVF(TMR_OVF), 
    .TMR_UDF(TMR_UDF)
  );
  /*
  always @(prdata) begin
    if (prdata == 8'h00) begin
      $display(,$time,,, "faulty");
      paddr = 3'b011; pwdata = 8'b0000_0000;
      #3000 $stop;
    end else begin
      $display(,$time,,, "pass");
    end
  end
  */
  always @(TMR_OVF) begin
    if (TMR_OVF) begin
      $display(,$time,,, "faulty");
      paddr = 3'b011; pwdata = 8'b0000_0000;
      #3000 $stop;
    end else begin
      $display(,$time,,, "pass");
    end
  end
  /*
  always @(TMR_UDF) begin
    if (TMR_UDF) begin
      $display(,$time,,, "faulty");
      paddr = 3'b011; pwdata = 8'b0000_0000;
      #3000 $stop;
    end else begin
      $display(,$time,,, "pass");
    end
  end
  */
  integer a;
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    pclk = 1; preset_n = 0; 
    psel = 0; penable = 0; pwrite = 0; paddr = 3'b000; pwdata = 8'h00;
    #20 preset_n = 1;
    
    #40 psel = 1; penable = 0; pwrite = 0;
    #40 penable = 1; 
    // Write TDR
    #80 pwrite = 1; paddr = 3'b010; pwdata = {$random()} % 255; // Random 0-255
    // Write TCR
    #120 pwrite = 1; paddr = 3'b011; pwdata = 8'b1000_0000; // Load, Count Down and choose clock T*2
    #210 pwdata = 8'b0001_0000; // Enable
    // Pause
    #3000 pwdata = 8'b0000_0000; // Deassert enable signal
    for (a=0; a < COUNT_PAUSE; a=a+1) begin
      @(posedge clk_in[0]);
    end
    #210 pwdata = 8'b0001_0000; // Enable
    #9000 paddr = 3'b011; pwdata = 8'b0000_0000; // Deassert enable signal
    
    #9000 $stop;
  end
  
endmodule
