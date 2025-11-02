module apb_protocol #(
	parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
	// Inputs of APB Protocol
	input pclk, prst_n, psel, penable, pwrite,
  	input [ADDR_WIDTH-1:0] paddr,
  	input [DATA_WIDTH-1:0] pwdata,
	
	// Outputs of APB Protocol
	output reg pready, pslverr,
  	output reg [DATA_WIDTH-1:0] prdata
);
	
	// Memory Declaration
  	reg [DATA_WIDTH-1:0] mem [ADDR_WIDTH-1:0]; // Memory
  
	// State Declaration
  	localparam 	IDLE 	= 2'b00,
				SETUP 	= 2'b01,
				ACCESS 	= 2'b10;
	
	// State declaration of current and next
  	reg [1:0] current_state, next_state;
	
	// Check async active low reset
  	always @(posedge pclk or negedge prst_n) begin
    	if(!prst_n)
          	current_state <= IDLE;
        else 
          	current_state <= next_state;
    end
  
	// State logic for FSM
  	always @(*) begin
		case(current_state)
			// Idle phase
			IDLE : begin
				next_state = SETUP;
			end
				
			// Setup phase
			SETUP : begin
				next_state = ACCESS;
			end
			
			// Access phase
			ACCESS : begin
				next_state = IDLE;
            end
          
          	default: begin
              next_state = IDLE;
            end
		endcase
	end
      
    integer i;
    
    // READ and WRITE transaction
    always @(posedge pclk or negedge prst_n) begin
      if(!prst_n) begin
        for (i=0; i < ADDR_WIDTH; i = i+1) begin
          mem[i] <= 8'h00;
        end
      end else begin
        if(current_state == ACCESS && psel && penable && pwrite) begin
          // WRITE
          mem[paddr] <= pwdata;
          //$display ("Writing 8'h%h to address 8'h%h...", pwdata, paddr);
        end else begin
          mem[paddr] <= mem[paddr];
        end
      end
    end
    
  assign prdata = (current_state == ACCESS && psel && penable && !pwrite) ? mem[paddr] : prdata;
  assign pslverr = (current_state == ACCESS) && (paddr > 8'h07);
  assign pready = (current_state == ACCESS && psel && penable);
endmodule
