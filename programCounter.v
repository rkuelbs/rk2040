`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2023 12:12:21 PM
// Design Name: 
// Module Name: programCounter
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


module programCounter(
    input [8:0] pcNext,
    input enable,
    input clk,
    input rst,
    output reg [8:0] pc
    );
    
    always @(posedge clk) begin
        if (rst) begin
            pc <= 8'b0;
        end
        else if (enable) begin
            pc <= pcNext;
        end
    end
    
endmodule
