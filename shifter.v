`timescale 1ns / 1ps

module shifter(
    input [23:0] dataIn,
    input [4:0] shift,
    input [4:0] A,
    input shiftRegister,
    output reg [23:0] dataOut
    );
        
    integer i;
    
    wire [71:0] extendedValue;
    wire [5:0] shiftAmt;
    
    assign extendedValue = {{24{dataIn[23]}}, dataIn, 24'b0};
    
    // SELECT SHIFT AMOUNT -- EITHER SHIFT[3:0] or SHIFT REGISTER
    assign shiftAmt[5] = 1'b0;
    assign shiftAmt[4:0] = (shiftRegister) ? A : {1'b0, shift[3:0]};
    
    always @(*) begin
        i = (shift[4]) ? (24 + shiftAmt) : (24 - shiftAmt);
        dataOut <= extendedValue[i +: 24];
    end
    
endmodule
