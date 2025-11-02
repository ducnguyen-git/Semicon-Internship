// Behavioural model
module half_adder_behavioural(
     input a, b,
     output reg c, s
);
     always @(*) begin
         s <= a ^ b;
         c <= a & b;
     end
endmodule
