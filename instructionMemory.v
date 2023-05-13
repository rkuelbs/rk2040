`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2023 10:33:50 PM
// Design Name: 
// Module Name: instructionMemory
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


module instructionMemory #(
    parameter PROGRAM = 1)
    (
    input [8:0] readAddr,
    output reg [23:0] readData
    );
    
    integer i;
    reg [23:0] instMemory [511:0];
    
    initial begin
    for (i = 0; i < 512; i = i + 1) begin
        instMemory[i] <= 24'b0;
    end
    #5 case (PROGRAM)
        0:
        $readmemh("program0.mem", instMemory);
        1:
        $readmemh("program1.mem", instMemory);
        2:
        $readmemh("program2.mem", instMemory);
        3:
        $readmemh("program3.mem", instMemory);
        4:
        $readmemh("program4.mem", instMemory);
        default:
        $readmemh("program1.mem", instMemory);
    endcase
    end
        
    always @(*) begin
        readData <= instMemory[readAddr];
    end
    
endmodule
