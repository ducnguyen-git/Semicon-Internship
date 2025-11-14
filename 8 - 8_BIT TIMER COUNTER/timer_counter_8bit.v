module timer_counter_8bit #(
	parameter DATA_WIDTH = 8,
  	parameter ADDR_WIDTH = 3
)(
  input reg [3:0] clk_in,
  input pclk, preset_n, psel, pwrite, penable,
  input [ADDR_WIDTH-1:0] paddr, 
  input [DATA_WIDTH-1:0] pwdata,
  
  output reg [DATA_WIDTH-1:0] prdata,
  output reg pready, pslverr,
  output reg TMR_OVF, TMR_UDF
);
  // Internal Registers
  reg [DATA_WIDTH-1:0] tcnt, tdr, tcr, tsr;
  localparam 	TCNT_ADDR = 8'h01,
  			  	 TDR_ADDR = 8'h02,
  				 TCR_ADDR = 8'h03,
  				 TSR_ADDR = 8'h04;
    
  // Read/Write Controller State Declaration
  localparam 	IDLE   = 2'b00,
  			  	SETUP  = 2'b01,
 			  	ACCESS = 2'b10;
  
  // Read/Write Controller State Status
  reg [1:0] current_state, next_state;
  
  // Read/Write Controller State Transition
  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n)
      current_state <= IDLE;
    else 
      current_state <= next_state;
  end

  // Read/Write Controller FSM Logic
  always @(posedge pclk) begin
    case(current_state)
      // Idle State
      IDLE : begin
        if(psel && !penable)
          next_state = SETUP;
        else 
          next_state = IDLE;
      end

      // Setup State
      SETUP : begin
          next_state = ACCESS;
      end

      // Access State
      ACCESS : begin
        if(!psel && !penable)
          next_state = IDLE;
        else if (psel && !penable)
          next_state = SETUP;
        else
          next_state = ACCESS;
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

  integer i;
  reg [7:0] cur_count_val, next_count_val;

  // Read/Write Controller Functional Transaction
  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n) begin
      prdata <= 8'h00;
      tcnt <= 8'h00; tdr <= 8'h00; tcr <= 8'h00; tsr <= 8'h00;
      
    end else begin
      if(current_state == ACCESS) begin
        // WRITE
        if(pwrite) begin
          case(paddr)
            
            TCNT_ADDR: begin
              tcnt <= cur_count_val;
            end
            
            TDR_ADDR: begin
              tdr <= pwdata;
              tcnt <= cur_count_val;
            end
            
            TCR_ADDR: begin
              tcr <= pwdata;
              tcnt <= cur_count_val;
            end
            
            TSR_ADDR: begin
              tsr <= pwdata;
              tcnt <= cur_count_val;
            end
            
          	default: begin
              tcnt <= cur_count_val;
              tdr <= tdr;
              tcr <= tcr;
              tsr <= tsr;
            end
          endcase
        end
            
        // READ
        else begin
          case(paddr)
            
            TCNT_ADDR: begin
              prdata <= tcnt;
            end
            
            TDR_ADDR: begin
              prdata <= tdr;
            end
            
            TCR_ADDR: begin
              prdata <= tcr;
            end
            
            TSR_ADDR: begin
              prdata <= tsr;
            end
            
          	default: begin
              prdata <= prdata;
            end
          endcase
        end
      end 
    end
  end
	
  // Output signals
  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n) begin
      pready <= 1'b0;
      pslverr <= 1'b0;
    end else begin
      pslverr <= (current_state == ACCESS) && ((paddr < 3'b001) || (paddr > 3'b100));
      pready <= (current_state == ACCESS && psel && penable && !TMR_OVF && !TMR_UDF);
    end
  end
  
  reg tmr_clk_in;
  reg [1:0] cks;
  assign cks = tcr[1:0];
  
  // Select Clock
  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n) begin
      tmr_clk_in <= 1'b0;
    end else begin
      case(cks)
        2'b00: begin 
          tmr_clk_in = clk_in[0];
        end

        2'b01: begin 
          tmr_clk_in = clk_in[1];
        end

        2'b10: begin 
          tmr_clk_in = clk_in[2];
        end

        2'b11: begin 
          tmr_clk_in = clk_in[3];
        end
        
        default: begin
          tmr_clk_in = 1'b0;
        end
      endcase
    end
  end
      
  // Control Logic control signals
  reg [7:0] counter_initial_val;
  reg count_load, count_up_down, count_enable;
  assign count_load = tcr[7];
  assign count_up_down = tcr[5];
  assign count_enable = tcr[4];
  
  always @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      counter_initial_val <= 8'h00;
    end else begin
      counter_initial_val <= tdr;
    end
  end
  
  reg detect_posedge;
  
  // Timer Counter
  detect_edge detect_pos(
    .clk(pclk), 
    .reset_n(preset_n), 
    .signal_in(tmr_clk_in),
    .pos_edge_out(detect_posedge)
	);
  
  always @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      cur_count_val <= 8'h00;
    end else begin
      if (count_load) begin
        cur_count_val <= counter_initial_val;
      end else if (count_enable) begin
      	cur_count_val <= next_count_val;
      end else begin
      	cur_count_val <= cur_count_val;
      end
    end
  end
  
  integer j, k;
  
  always @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      next_count_val <= 8'h00;
      j <= 0; k <= 0;
    end else begin
      if (!count_up_down && count_load) begin
        for (j=0; count_load || count_enable; j=j+1) begin
          @(posedge detect_posedge) next_count_val <= cur_count_val + 8'b1;
        end
      end else if (count_up_down && count_load) begin
        for (k=0; count_load || count_enable; k=k+1) begin
          @(posedge detect_posedge) next_count_val <= cur_count_val - 8'b1;
        end
      end else begin
        j <= 0; k <= 0;
        next_count_val <= next_count_val;
      end
    end
  end
    
  // Overflow/Underflow Comparator
  always @(posedge pclk or negedge preset_n) begin
    if (!preset_n) begin
      TMR_OVF <= 1'b0;
      TMR_UDF <= 1'b0;
    end else begin
      case(count_up_down)
        // Count Up
        1'b0: begin
          if ((cur_count_val == 8'hFF) && (next_count_val == 8'h00)) begin
            TMR_OVF <= 1'b1;
          end else if (tsr[0]) begin
            TMR_OVF <= 1'b0;
          end else begin
            TMR_OVF <= TMR_OVF;
          end
        end
        // Count Down
        1'b1: begin
          if ((cur_count_val == 8'h00) && (next_count_val == 8'hFF)) begin
            TMR_UDF <= 1'b1;
          end else if (tsr[1]) begin
            TMR_UDF <= 1'b0;
          end else begin
            TMR_UDF <= TMR_UDF;
          end
        end
      endcase
    end
  end
endmodule

// Prescaler
module prescaler(
  // Input clock signal
  input wire clk_in, reset_n,
  // Output divided clock signals
  output reg clk_0, clk_1, clk_2, clk_3
);
  // Clock division numbers
  localparam 	DIV_0 = 2,
  				DIV_1 = 4,
  				DIV_2 = 8,
  				DIV_3 = 16;
  // Width of each clock
  localparam 	WIDTH_0 = $clog2(DIV_0),
                WIDTH_1 = $clog2(DIV_1),
                WIDTH_2 = $clog2(DIV_2),
                WIDTH_3 = $clog2(DIV_3);
  // Counter registers
  reg [WIDTH_0-1:0] counter_0;
  reg [WIDTH_1-1:0] counter_1;
  reg [WIDTH_2-1:0] counter_2;
  reg [WIDTH_3-1:0] counter_3;
  
  always @(posedge clk_in or negedge reset_n) begin
    if(!reset_n) begin
      counter_0 <= 0; counter_1 <= 0; counter_2 <= 0; counter_3 <= 0; 
      clk_0 <= 1'b0; clk_1 <= 1'b0; clk_2 <= 1'b0; clk_3 <= 1'b0; 
    end else begin
      
      // CLK_IN[0]
      if (counter_0 == (DIV_0 - 1)) begin
        counter_0 <= 0;
        clk_0 <= ~clk_0; // Toggle the output clock
      end else begin
        counter_0 <= counter_0 + 1;
      end
      
      // CLK_IN[1]
      if (counter_1== (DIV_1 - 1)) begin
        counter_1 <= 0;
        clk_1 <= ~clk_1; // Toggle the output clock
      end else begin
        counter_1 <= counter_1 + 1;
      end
      
      // CLK_IN[2]
      if (counter_2== (DIV_2 - 1)) begin
        counter_2 <= 0;
        clk_2 <= ~clk_2; // Toggle the output clock
      end else begin
        counter_2 <= counter_2 + 1;
      end
      
      // CLK_IN[3]
      if (counter_3 == (DIV_3 - 1)) begin
        counter_3 <= 0;
        clk_3 <= ~clk_3; // Toggle the output clock
      end else begin
        counter_3 <= counter_3 + 1;
      end
      
    end
  end
  
endmodule


// detect_edge module
module detect_edge(
  input clk, reset_n, signal_in,
  output reg pos_edge_out
);
  reg delay_signal;
  
  always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
      delay_signal <= 1'b0;
    end else begin
      delay_signal <= signal_in;
    end
  end
  
  always @(*) begin
    pos_edge_out = signal_in && (~delay_signal);
  end
endmodule