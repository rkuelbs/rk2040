`timescale 1ns / 1ps

module ALU(
    input [23:0] A,
    input [23:0] B,
    input [3:0] aluOp,
    output [23:0] out,
    output reg equal,
    output lessThan,
    output overflow
    );
    
    parameter ADD = 2'b0;
    parameter AND = 2'b01;
    parameter OR = 2'b10;
    parameter XOR = 2'b11;
    
    wire aInvert, bNegate;
    wire [24:0] aExt, bExt;
    reg [24:0] outExt;
    
    assign aInvert = aluOp[3];
    assign bNegate = aluOp[2];
    assign aExt = (aInvert) ? {~A[23], ~A} : {A[23], A};
    assign bExt = (bNegate) ? {~B[23], ~B} : {B[23], B};
    assign out = outExt[23:0];
    assign lessThan = outExt[23];
    assign overflow = outExt[24] ^ outExt[23];
    
    always @(*) begin
        equal <= (A == B);
        case (aluOp[1:0])
        ADD: begin            
            outExt <= (aExt + bExt + bNegate);
            end
        AND: begin
            outExt <= (aExt & bExt);
            end
        OR: begin
            outExt <= (aExt | bExt);
            end
        XOR: begin
            outExt <= (aExt ^ bExt);
            end
        endcase
    end
    
endmodule
