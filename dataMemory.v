`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2023 10:50:37 PM
// Design Name: 
// Module Name: dataMemory
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


module dataMemory(
    input [9:0] readAddr,
    input [9:0] writeAddr,
    input WE,
    input clk,
    input [23:0] writeData,
    input [23:0] inputPort,
    input [7:0] ADC0,
    input [7:0] ADC1,
    input [7:0] ADC2,
    output reg [23:0] readData,
    output [7:0] interruptMask
    );
    
    integer i;
    reg [7:0] dataMemory [0:1023];
    
    assign interruptMask = dataMemory[985];
    
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            dataMemory[i] <= 8'b0;
    end
    
    always @(*) begin
        readData[7:0] <= dataMemory[readAddr];
        readData[15:8] <= dataMemory[readAddr + 1];
        readData[23:16] <= dataMemory[readAddr + 2];
    end
    always @(negedge clk) begin //write at negedge as data should be stable from SPR3
        if (WE && (writeAddr <= 1011)) begin
            dataMemory[writeAddr] <= writeData[7:0];
            dataMemory[writeAddr + 1] <= writeData[15:8];
            dataMemory[writeAddr + 2] <= writeData[23:16];
        end
    end
    
    // INPUT PORT HANDLING
    always @(inputPort) begin
        dataMemory[1021] <= inputPort[7:0];
        dataMemory[1022] <= inputPort[15:8];
        dataMemory[1023] <= inputPort[23:16];
    end
    always @(ADC0) begin
        dataMemory[1018] <= ADC0;
    end
    always @(ADC1) begin
        dataMemory[1015] <= ADC1;
    end
    always @(ADC2) begin
        dataMemory[1012] <= ADC2;
    end
endmodule
