module Overflow(A, B, Y, Overflow, mode);
    input [3:0] A;
    input [3:0] B;
    input [15:0] Y;
    input mode;
    output reg Overflow;
	 
	 reg [15:0] new_A;
	 reg [15:0] new_B;
	 
	 reg [11:0]fixed_bits = 12'b101010101010;
	 
    always @(*) begin
		  new_A = {A,fixed_bits};
		  new_B = {B,fixed_bits};
        if (mode == 0) begin
            Overflow = ((new_A[15] == new_B[15]) & (Y[15] != new_A[15]));
        end else begin
            Overflow = ((new_A[15] == new_B[15]) & (Y[15] != new_B[15]));
        end
    end
endmodule
