module tb_half_adder;
     reg d, e; // Registers for a, b
     wire f, g; // Wires for c, s

  half_adder_behavioural ha(.a(d), .b(e), .c(g), .s(f));

     initial begin
         $dumpvars(1, tb_half_adder); // Enable waveform dumping for simulation

         // Test case 1
         d = 1'b1; e = 1'b1;
       #10 $display (,,$time," | a=%b | b=%b | s=%b | c=%b",d,e,f,g);

         // Test case 2
         d = 1'b0; e = 1'b1;
       #10 $diplay (,,$time," | a=%b | b=%b | s=%b | c=%b",d,e,f,g);

         // Test case 3
         d = 1'b0; e = 1'b0;
       #10 $display (,,$time," | a=%b | b=%b | s=%b | c=%b",d,e,f,g);

         // Test case 4
         d = 1'b1; e = 1'b0;
       #10 $display (,,$time," | a=%b | b=%b | s=%b | c=%b",d,e,f,g);
     end
endmodule
