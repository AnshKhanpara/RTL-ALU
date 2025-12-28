module ALU(Y, ALU_Op, Carry, Auxilary_Carry, Overflow, Parity, A, B, Cin);
    // Fixed inputs
    input [3:0] A; 
    input [3:0] B; 
    input Cin; // Carry-in for addition/subtraction
    input [3:0] ALU_Op; // ALU operation selector
    output reg [15:0] Y = 16'h0000; // 16-bit output
    wire [15:0] addition_out;

    // Flags
    output reg Carry; // Carry flag
    output reg Auxilary_Carry; // Auxiliary Carry flag
    output Parity; // Parity flag
    output Overflow; // Overflow flag
    wire Cout;
    wire w2, w3, w4, w5;

    // Fixed input bits 
    reg [11:0] fixed_bits = 12'b101010101010;
    
    // Define new_A and new_B by concatenating A/B with fixed_bits
    reg [15:0] new_A ;
    reg [15:0] new_B ;

    // ALU Operation Mode (0 = Add, 1 = Subtract)
    assign w5 = (ALU_Op == 4'h0) ? 0 : (ALU_Op == 4'h1) ? 1 : 1'bx;

    // Instantiate the other modules 
    Adder_cum_sub_16_bit ACS1(A, B, Cin, addition_out, Cout, w2, w5);
    Parity P1(Y, w3);
    Overflow O1(A, B, addition_out, w4, w5);

    assign Parity = w3;
    assign Overflow = w4;

    always @(*) begin
        Carry = 1'b0;
        Auxilary_Carry = 1'b0;
		  
	     // Define new_A and new_B by concatenating A/B with fixed_bits
		  new_A = {A[3:0], fixed_bits};
		  new_B = {B[3:0], fixed_bits};

        case(ALU_Op)
            4'b0000 : Y = addition_out;  // Addition
            4'b0001 : Y = addition_out;  // Subtraction
            4'b0010 : Y = new_A & new_B;          // Bitwise AND
            4'b0011 : Y = new_A | new_B;          // Bitwise OR
            4'b0100 : Y = new_A ^ new_B;          // Bitwise XOR
            4'b0101 : Y = ~new_A;             // Bitwise NOT for A
            4'b0110 : Y = new_A << 1;         // Left shift
            4'b0111 : Y = new_A >> 1;         // Right shift
            4'b1000 : Y = (new_A == new_B) ? (2'b11) : ((new_A > new_B) ? 1'b1 : 1'b0); // Compare A and B
            default : Y = 16'b0;
        endcase

        if ((ALU_Op == 4'h0) | (ALU_Op == 4'h1)) begin
            Carry = Cout;
            Auxilary_Carry = w2;
        end
    end
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////