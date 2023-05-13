`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2023 10:57:08 AM
// Design Name: 
// Module Name: instructionRegister
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instructionRegister(
    input [23:0] instruction,
    input [8:0] pcInc0,
    input clk,
    input rst,
    input enable,
    output reg [8:0] pcInc1,
    output [5:0] opcode,
    output immFlag,
    output [3:0] RA,
    output [3:0] RB,
    output [8:0] immediate,
    output [3:0] RT,
    output [4:0] shift
    );
    
    reg [23:0] instReg;
    wire clearRegister;
    
    assign opcode = instReg[23:18];
    assign immFlag = instReg[17];
    assign immediate = instReg[16:8];
    assign shift = instReg[16:12];
    assign RB = instReg[11:8];
    assign RA = instReg[7:4];
    assign RT = instReg[3:0];
    
    always @(posedge clk) begin
        if (rst) begin
            pcInc1 <= 9'b0;
            instReg <= 24'b0;
        end
        else if (enable) begin
            pcInc1 <= pcInc0;
            instReg <= instruction;
        end
    end
endmodule
