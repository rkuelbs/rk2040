`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2023 09:43:58 PM
// Design Name: 
// Module Name: interruptEdgeDetector
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


module interruptEdgeDetector(
    input [7:0] inputPort,
    input clk,
    input rst,
    output reg [7:0] outputPort
    );
    
    wire [7:0] nextOutput;
    reg [7:0] lastInput;
    
    assign nextOutput = (~inputPort & (inputPort ^ lastInput));
    
    always @(posedge clk) begin
        lastInput <= inputPort;
        if(rst) outputPort <= 0;
        else begin
            outputPort <= nextOutput;
        end
    end
    
endmodule
