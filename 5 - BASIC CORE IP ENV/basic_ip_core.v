module demux_3to8 (
	input wire pclk,
	input wire preset_n,
	input wire pwrite,
	input wire psel,
	input wire penable,
  	input wire [7:0] paddr,
  	input wire [7:0] pwdata,
  	output reg [7:0] prdata,
	output reg pready,
	output reg pslverr 
);

  	reg [7:0] registers [7:0];
	
  	integer i;
  
	always @( posedge pclk or negedge preset_n) begin
		if (!preset_n) begin
          	for (i = 0; i < 16; i = i+1) begin
            	registers[i] = 8'h00;
          	end
			pslverr <= 1'b0;
        	pready <= 1'b0;
		end else begin
			if (psel) begin
              	pslverr <= 1'b0;
				pready <= 1'b1;
              	if (penable) begin
					if (pwrite) begin 
						case (paddr)
                            8'h00: registers[0] <= pwdata;
                            8'h01: registers[1] <= pwdata;
                            8'h02: registers[2] <= pwdata;
                            8'h03: registers[3] <= pwdata;
                            8'h04: registers[4] <= pwdata;
                            8'h05: registers[5] <= pwdata;
                            8'h06: registers[6] <= pwdata;
                            8'h07: registers[7] <= pwdata;
                            default: pslverr <= 1'b1;
                     	endcase
                  	end else begin
                        case (paddr)
                            8'h00: prdata <= registers[0];
                          	8'h01: prdata <= registers[1];
                            8'h02: prdata <= registers[2];
                            8'h03: prdata <= registers[3];
                            8'h04: prdata <= registers[4];
                            8'h05: prdata <= registers[5];
                            8'h06: prdata <= registers[6];
                            8'h07: prdata <= registers[7];
                            default: pslverr <= 1'b1;	
                        endcase
					end
              	end
			end
		end
	end

endmodule
