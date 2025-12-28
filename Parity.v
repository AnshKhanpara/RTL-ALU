module Parity(A, y);
    input [3:0] A;
    output reg y;
    integer i;

	 reg [11:0] fixed_bits = 12'b101010101010;
	 
	 reg [15:0] new_A ;

    always @(A) begin
		  new_A = {A,fixed_bits};
		  
		  y = 0;
		  
        for (i = 0; i < 16; i = i + 1) begin
            y = y ^ new_A[i];
        end
    end
endmodule

