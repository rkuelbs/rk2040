`timescale 1ns / 1ps

module registerStage2_3(
    input clk,
    input rst,
    input branch2,
    input load2,
    input store2,
    input [3:0] aluOp2,
    input [3:0] RT2,
    input [9:0] address2,
    input [8:0] pcInc2,
    input [23:0] A2,
    input [23:0] B2,
    input pop2,
    input push2,
    output reg branch3,
    output reg load3,
    output reg store3,
    output reg [3:0] aluOp3,
    output reg [3:0] RT3,
    output reg [9:0] address3,
    output reg [8:0] pcInc3,
    output reg [23:0] A3,
    output reg [23:0] B3,
    output reg pop3,
    output reg push3
    );
    
    always @(posedge clk) begin
        if (rst) begin
            branch3 <= 1'b0;
            load3 <= 1'b0;
            store3 <= 1'b0;
            aluOp3 <= 4'b0;
            RT3 <= 4'b0;
            address3 <= 10'b0;
            pcInc3 <= 9'b0;
            A3 <= 24'b0;
            B3 <= 24'b0;
            pop3 <= 0;
            push3 <= 0;
        end
        else begin
            branch3 <= branch2;
            load3 <= load2;
            store3 <= store2;
            aluOp3 <= aluOp2;
            RT3 <= RT2;
            address3 <= address2;
            pcInc3 <= pcInc2;
            A3 <= A2;
            B3 <= B2;
            pop3 <= pop2;
            push3 <= push2;
        end
    end
    
endmodule