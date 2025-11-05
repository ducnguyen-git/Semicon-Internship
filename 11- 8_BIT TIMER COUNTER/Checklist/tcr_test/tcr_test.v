// tcr_test.v
module tcr_test;
  localparam DATA_WIDTH = 8;
  localparam ADDR_WIDTH = 8;
  localparam MASK = 8'b1011_0011; // 8'hB3
  
  reg [3:0] clk_in;
  reg pclk, preset_n, psel, pwrite, penable;
  reg [ADDR_WIDTH-1:0] paddr;
  reg [DATA_WIDTH-1:0] pwdata;
  
  reg mask_compare; // 0 is smaller, 1 is equal or larger
  
  wire [DATA_WIDTH-1:0] prdata;
  wire pready, pslverr;
  wire TMR_OVF, TMR_UDF;
  
  timer_counter_8bit dut(
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
  
  always #10 pclk = ~pclk;
  integer i;
  
  always @(*) begin
    if (prdata < MASK) begin
      	mask_compare = 0;
    end else begin
    	mask_compare = 1;
    end
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    pclk = 1; preset_n = 0; psel = 0; penable = 0; pwrite = 0; paddr = 8'h00;
    #20 preset_n = 1; psel = 1; penable = 0; pwrite = 0; paddr = 8'h03;
    #40 penable = 1;
    #80; //Read reset value
    #40 pwrite = 1; pwdata = 8'hC7;
    #40 pwrite = 0;
    
    for (i=0; i<20; i=i+1) begin
      #40 pwrite = 1; pwdata = i*10;
      #40 pwrite = 0;
    end
    
    #100 $stop;
  end
  
endmodule
