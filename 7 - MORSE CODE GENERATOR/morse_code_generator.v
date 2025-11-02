module morse_code_generator (
  input clk,
  input rst_n,
  input [5:0] letter_code_i,
  input letter_space_i,
  input word_space_i,
  input start_i,
  output morse_o,
  output busy_o
);
  parameter P_CLK_FREQ = 100;
  
  reg start_i_1d;
  wire start;
  wire half_sec_counter_en;
  wire half_sec;
  wire load;
  wire [39:0] letter_morse_code;
  wire [15:0] space_morse_code;
  wire reg_sel;
  wire [1:0] current_state;
  wire [1:0] dot_space_finish;
  wire have_space_after_letter;
  
  //one-cycle delay of start_i
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      start_i_1d <= 1'b0;
    else
      start_i_1d <= start_i;
  end
  
  assign start = start_i & ~start_i_1d; //Detect positive egde of start_i
  assign load = ~busy_o;  //When current state is IDLE, load data to left shift registers
  
  half_second_counter #(.P_COUNT_MAX(P_CLK_FREQ/2-1)) half_second_counter_inst (
    .clk(clk), 
    .rst_n(rst_n), 
    .enable_i(half_sec_counter_en), 
    .half_sec_o(half_sec));
  
  morse_decoder morse_decoder_inst (
    .letter_code_i(letter_code_i), 
    .letter_space_i(letter_space_i), 
    .word_space_i(word_space_i), 
    .letter_morse_code_o(letter_morse_code), 
    .space_morse_code_o(space_morse_code));
  
  left_shift_register left_shift_register_inst (
    .clk(clk), 
    .rst_n(rst_n), 
    .shift_en_i(half_sec),
    .reg_sel_i(reg_sel),
    .load_i(load),
    .letter_morse_code_i(letter_morse_code),
    .space_morse_code_i(space_morse_code),
    .dot_space_finish_o(dot_space_finish),
    .have_space_after_letter_o(have_space_after_letter)
  );
  
  fsm_controller fsm_controller_inst (
    .clk(clk), 
    .rst_n(rst_n), 
    .start_i(start),
    .dot_space_finish_i(dot_space_finish),
    .have_space_after_letter_i(have_space_after_letter),
    .reg_sel_o(reg_sel),
    .state_o(current_state),
    .half_sec_counter_en_o(half_sec_counter_en)
  );
  
  morse_output morse_output_inst (
    .current_state_i(current_state),
    .morse_o(morse_o),
    .busy_o(busy_o)
  );
  
endmodule

module half_second_counter (
  input clk,
  input rst_n,
  input enable_i,
  output half_sec_o  
);
  parameter P_COUNT_MAX = 49;
  parameter P_COUNT_BITWIDTH = $clog2(P_COUNT_MAX)+1;
  
  reg [P_COUNT_BITWIDTH-1:0] count;
  
  assign half_sec_o = (count == P_COUNT_MAX);
  
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      count <= {P_COUNT_BITWIDTH{1'b0}};
    else if (~enable_i)
      count <= {P_COUNT_BITWIDTH{1'b0}};
    else if (count >= P_COUNT_MAX)
      count <= {P_COUNT_BITWIDTH{1'b0}};
    else 
      count <= count + 1'd1;
  end
  
endmodule


module morse_decoder (
  input [5:0] letter_code_i,
  input letter_space_i,
  input word_space_i,
  output reg [39:0] letter_morse_code_o,
  output reg [15:0] space_morse_code_o
);
  
  always @(letter_code_i) begin
    case (letter_code_i)
      0 : letter_morse_code_o = 40'b1100111111010000000000000000000000000000; //A
      1 : letter_morse_code_o = 40'b1111110011001100110100000000000000000000; //B
      2 : letter_morse_code_o = 40'b1111110011001111110011010000000000000000; //C
      3 : letter_morse_code_o = 40'b1111110011001101000000000000000000000000; //D
      4 : letter_morse_code_o = 40'b1101000000000000000000000000000000000000; //E
      5 : letter_morse_code_o = 40'b1100110011111100110100000000000000000000; //F
      6 : letter_morse_code_o = 40'b1111110011111100110100000000000000000000; //G
      7 : letter_morse_code_o = 40'b1100110011001101000000000000000000000000; //H
      8 : letter_morse_code_o = 40'b1100110100000000000000000000000000000000; //I
      9 : letter_morse_code_o = 40'b1100111111001111110011111101000000000000; //J
      10: letter_morse_code_o = 40'b1111110011001111110100000000000000000000; //K
      11: letter_morse_code_o = 40'b1100111111001100110100000000000000000000; //L
      12: letter_morse_code_o = 40'b1111110011111101000000000000000000000000; //M
      13: letter_morse_code_o = 40'b1111110011010000000000000000000000000000; //N
      14: letter_morse_code_o = 40'b1111110011111100111111010000000000000000; //O
      15: letter_morse_code_o = 40'b1100111111001111110011010000000000000000; //P
      16: letter_morse_code_o = 40'b1111110011111100110011111101000000000000; //Q
      17: letter_morse_code_o = 40'b1100111111001101000000000000000000000000; //R
      18: letter_morse_code_o = 40'b1100110011010000000000000000000000000000; //S
      19: letter_morse_code_o = 40'b1111110100000000000000000000000000000000; //T
      20: letter_morse_code_o = 40'b1100110011111101000000000000000000000000; //U
      21: letter_morse_code_o = 40'b1100110011001111110100000000000000000000; //V
      22: letter_morse_code_o = 40'b1100111111001111110100000000000000000000; //W
      23: letter_morse_code_o = 40'b1111110011001100111111010000000000000000; //X
      24: letter_morse_code_o = 40'b1111110011001111110011111101000000000000; //Y
      25: letter_morse_code_o = 40'b1111110011111100110011010000000000000000; //Z
      26: letter_morse_code_o = 40'b1100111111001111110011111100111111010000; //1
      27: letter_morse_code_o = 40'b1100110011111100111111001111110100000000; //2
      28: letter_morse_code_o = 40'b1100110011001111110011111101000000000000; //3
      29: letter_morse_code_o = 40'b1100110011001100111111010000000000000000; //4
      30: letter_morse_code_o = 40'b1100110011001100110100000000000000000000; //5
      31: letter_morse_code_o = 40'b1111110011001100110011010000000000000000; //6
      32: letter_morse_code_o = 40'b1111110011111100110011001101000000000000; //7
      33: letter_morse_code_o = 40'b1111110011111100111111001100110100000000; //8
      34: letter_morse_code_o = 40'b1111110011111100111111001111110011010000; //9
      default : letter_morse_code_o = 40'b1111110011111100111111001111110011111101; //0
    endcase 
  end
        
  always @(letter_space_i or word_space_i) begin
    if (word_space_i)
      space_morse_code_o = 16'b0000000000000001;
    else if (letter_space_i)
      space_morse_code_o = 16'b000000010000_0000;
    else
      space_morse_code_o = 16'b0100000000000000;
  end
  
endmodule

module left_shift_register (
  input clk,
  input rst_n,
  input shift_en_i,
  input reg_sel_i,
  input load_i,
  input [39:0] letter_morse_code_i,
  input [15:0] space_morse_code_i,
  output [1:0] dot_space_finish_o,
  output have_space_after_letter_o
);
  reg [39:0] left_shift_reg_letter;
  reg [15:0] left_shift_reg_space;
       
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      left_shift_reg_letter <= 40'd0;
    else if (load_i)
      left_shift_reg_letter <= letter_morse_code_i;
    else if (~reg_sel_i & shift_en_i)
      left_shift_reg_letter <= left_shift_reg_letter << 2;
    else
      left_shift_reg_letter <= left_shift_reg_letter;
  end
       
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      left_shift_reg_space <= 16'd0;
    else if (load_i)
      left_shift_reg_space <= space_morse_code_i;
    else if (reg_sel_i & shift_en_i)
      left_shift_reg_space <= left_shift_reg_space << 2;
    else
      left_shift_reg_space <= left_shift_reg_space;
  end
         
  assign dot_space_finish_o = reg_sel_i? left_shift_reg_space[15:14] : left_shift_reg_letter[39:38];
  assign have_space_after_letter_o = left_shift_reg_space[15:14] == 2'b0;
  
endmodule
       
module fsm_controller (
  input clk,
  input rst_n,
  input start_i,
  input [1:0] dot_space_finish_i,
  input have_space_after_letter_i,
  output reg_sel_o,
  output [1:0] state_o,
  output half_sec_counter_en_o
);
  localparam P_IDLE       = 2'd0;
  localparam P_LETTER_ON  = 2'd1;
  localparam P_LETTER_OFF = 2'd2;
  localparam P_SPACE_OFF  = 2'd3;
  
  reg [1:0] current_state;
  reg [1:0] next_state;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
      current_state <= P_IDLE;
    else
      current_state <= next_state;
  end
  
  always @(start_i or dot_space_finish_i or have_space_after_letter_i) begin
    case (current_state)
      P_IDLE: if (~start_i)
                next_state = P_IDLE;
              else if (dot_space_finish_i == 2'b11)
                next_state = P_LETTER_ON;
              else
                next_state = P_IDLE;
      P_LETTER_ON: if (dot_space_finish_i == 2'b00)
                next_state = P_LETTER_OFF;
              else if ((dot_space_finish_i == 2'b01) & ~have_space_after_letter_i)
                next_state = P_IDLE;
              else if ((dot_space_finish_i == 2'b01) & have_space_after_letter_i)
                next_state = P_SPACE_OFF;
              else
                next_state = P_LETTER_ON;
      P_LETTER_OFF: if (dot_space_finish_i == 2'b11)
                next_state = P_LETTER_ON;
              else
                next_state = P_LETTER_OFF;
      P_SPACE_OFF: if (dot_space_finish_i == 2'b01)
                next_state = P_IDLE;
              else
                next_state = P_SPACE_OFF;
      default: next_state = P_IDLE;
    endcase
  end
  
  assign state_o = current_state;
  assign reg_sel_o = (current_state == P_SPACE_OFF); 
  assign half_sec_counter_en_o = (current_state != P_IDLE);
  
endmodule
       
module morse_output (
  input [1:0] current_state_i,
  output morse_o,
  output busy_o
);
  localparam P_IDLE  = 2'd0;
  localparam P_LETTER_ON  = 2'd1;
  
  assign morse_o = (current_state_i == P_LETTER_ON);
  assign busy_o = (current_state_i != P_IDLE);
  
endmodule