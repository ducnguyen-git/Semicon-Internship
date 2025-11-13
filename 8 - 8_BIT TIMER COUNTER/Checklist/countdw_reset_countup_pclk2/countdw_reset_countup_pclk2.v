// countdw_reset_countup_pclk2.v
module countdw_reset_countup_pclk2;
  localparam DATA_WIDTH = 8;
  localparam ADDR_WIDTH = 3;
  
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
  
  always @(TMR_OVF or TMR_UDF) begin
    if (TMR_OVF || TMR_UDF) begin
      $display(,$time,,, "faulty");
      paddr = 3'b011; pwdata = 8'b0000_0000;
      #1000 $stop;
    end else begin
      $display(,$time,,, "pass");
    end
  end
  
  always @(paddr or prdata) begin
    if ((pwrite == 1'b0) && (paddr != 3'b000) && (prdata == 8'h00)) begin
      $display(,$time,,, "pass");
    end else if ((pwrite == 1'b0) && (paddr != 3'b000) && (prdata != 8'h00)) begin
      $display(,$time,,, "failed");
    end
  end
  
  reg [DATA_WIDTH-1:0] temp_data;
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    pclk = 1; preset_n = 0; 
    psel = 0; penable = 0; pwrite = 0; paddr = 3'b000; pwdata = 8'h00;
    #20 preset_n = 1;
    
    #40 psel = 1; penable = 0; pwrite = 0;
    #40 penable = 1; 
    // Write TDR
    #80 pwrite = 1; 
    #10 paddr = 3'b010; pwdata = {$random()} % 255; temp_data = pwdata;// Random 0-255
    // Write TCR
    #120 pwrite = 1; paddr = 3'b011; pwdata = 8'b1010_0000; // Load, Count Down, Unenable and choose clock T*2
    #210 pwdata = 8'b0011_0000; // Unload and Enable
    // Reset
    #2000 preset_n = 0; psel = 0; penable = 0; pwrite = 0;
    
    #200 preset_n = 1;
    
    #40 psel = 1; penable = 0; pwrite = 0;
    #40 penable = 1; 
    #100 pwrite = 0; paddr = 3'b010;
    #100 pwrite = 0; paddr = 3'b011;
    #100 pwrite = 0; paddr = 3'b100;
    // Write TDR
    #100 pwrite = 1; paddr = 3'b010; pwdata = temp_data;
    // Write TCR
    #120 pwrite = 1; paddr = 3'b011; pwdata = 8'b1000_0000; // Load, Count Up, Unenable and choose clock T*2
    #210 pwdata = 8'b0001_0000; // Unload and Enable
    
    #12000 paddr = 3'b011; pwdata = 8'b0000_0000; // Deassert enable signal
    
    #1000 $stop;
  end
  
endmodule
