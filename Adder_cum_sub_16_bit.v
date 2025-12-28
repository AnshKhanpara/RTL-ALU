// 16-bit Adder/Subtractor
module Adder_cum_sub_16_bit(A, B, Cin, S, Cout, Auxilary_Carry, mode);
    input [3:0] A;
    input [3:0] B;
    input Cin;
    input mode;
    output [15:0] S;
    output Cout;
    output Auxilary_Carry;
	 
	 reg [15:0] new_A;
	 reg [15:0] new_B;
	 
	 reg [11:0]fixed_bits = 12'b101010101010;

    wire w1, w2, w3;
	 
	 always@(*)
	 begin
		new_A = {A,fixed_bits};
		new_B = {B,fixed_bits};
	 end
	 
    b4bitAcumS PA1(new_A[3:0], new_B[3:0], Cin, S[3:0], w1, mode);
    b4bitAcumS PA2(new_A[7:4], new_B[7:4], w1, S[7:4], w2, mode);
    b4bitAcumS PA3(new_A[11:8], new_B[11:8], w2, S[11:8], w3, mode);
    b4bitAcumS PA4(new_A[15:12], new_B[15:12], w3, S[15:12], Cout, mode);

    assign Auxilary_Carry = w2;
endmodule

// 4-bit Adder/Subtractor Module
module b4bitAcumS(A, B, Cin, S, Cout, mode);
    input [3:0] A;  
    input [3:0] B;  
    input Cin;
    input mode;
    output Cout;  
    output [3:0] S; 
    
    wire c1, c2, c3;
    wire B1, B2, B3, B4;
    
    assign B1 = (B[0] ^ mode);
    assign B2 = (B[1] ^ mode);
    assign B3 = (B[2] ^ mode);
    assign B4 = (B[3] ^ mode);
    
    FA fa0(A[0], B1, Cin, S[0], c1);
    FA fa1(A[1], B2, c1, S[1], c2);
    FA fa2(A[2], B3, c2, S[2], c3);
    FA fa3(A[3], B4, c3, S[3], Cout);
endmodule

// Full Adder Module
module FA(A, B, Cin, S, Cout);
    input A, B, Cin;
    output S, Cout;
    
    assign S = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | (A & Cin);
endmodule