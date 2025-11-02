module tb_top();
  reg clk;
  reg rst_n;
  reg [5:0] letter_code_i;
  reg letter_space_i;
  reg word_space_i;
  reg start_i;
  wire morse_o;
  wire busy_o;
  
  morse_code_generator #(.P_CLK_FREQ(100)) morse_code_generator_inst (
    .clk(clk),
  	.rst_n(rst_n),
  	.letter_code_i(letter_code_i),
  	.letter_space_i(letter_space_i),
  	.word_space_i(word_space_i),
  	.start_i(start_i),
  	.morse_o(morse_o),
  	.busy_o(busy_o)
  );
  
  initial begin
    clk = 0;
    letter_code_i = 0;
    letter_space_i = 1;
    word_space_i = 1;
    start_i = 0;
    
    //Do reset and then count from 0
    rst_n = 1;
    #25;
    rst_n = 0;
    #15;
    rst_n = 1;
    
    wait (~busy_o);
    #50;
    start_i = 1;
    #50;
    start_i = 0;
    wait (~busy_o);
    
    
    letter_code_i = 40;
    word_space_i = 0;
    #17;
    start_i = 1;
    #50;
    start_i = 0;
    wait (~busy_o);
    
    for (integer i=0; i<36; i++) begin
      letter_code_i = i;
      word_space_i = 0;
      #17;
      start_i = 1;
      #50;
      start_i = 0;
      wait (~busy_o);
    end
    
    
    #100;
    
    $finish();
  end
  
  always #5 clk = ~clk;  //clk frequency is 1Khz
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
endmodule
  