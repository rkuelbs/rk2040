`timescale 1ns / 1ps

module registerStage3_4(
    input clk,
    input rst,
    input [23:0] result3,
    input [3:0] RT3,
    input store3,
    input [9:0] address3,
    input [23:0] A3,
    input push3,
    input pop3,
    output reg [23:0] result4,
    output reg [3:0] RT4,
    output reg store4,
    output reg [9:0] address4,
    output reg [23:0] A4,
    output reg push4,
    output reg pop4
    );
    
    always @(posedge clk) begin
        if (rst) begin
            store4 <= 1'b0;
            RT4 <= 4'b0;
            A4 <= 24'b0;
            address4 <= 10'b0;
            result4 <= 24'b0;
            push4 <= 0;
            pop4 <= 0;
        end
        else begin
            store4 <= store3;
            A4 <= A3;
            RT4 <= RT3;
            address4 <= address3;
            result4 <= result3;
            push4 <= push3;
            pop4 <= pop3;
        end
    end
    
endmodule