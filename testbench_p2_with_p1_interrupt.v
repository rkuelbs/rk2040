`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2023 09:24:56 PM
// Design Name: 
// Module Name: testbench
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

// THIS TESTBENCH RUNS PROGRAM 2, WITH PROGRAM 1 CALLED AS AN INTERRUPT ON THE FALLING EDGE OF INPUTPORT[5]


module testbenchp2_p1(

    );
    
    parameter PROGRAM = 0;
    
    reg clk, rst;
    reg [23:0] inputPort;
    reg [7:0] ADC0, ADC1, ADC2;
    wire [23:0] outputPort;
    wire [3:0] outputPWM;
    
    RK2040 #(
        .PROGRAM    (PROGRAM)
    ) MODULE_UNDER_TEST (
        .clk        (clk),
        .rst        (rst),
        .inputPort  (inputPort),
        .ADC0       (ADC0),
        .ADC1       (ADC1),
        .ADC2       (ADC2),
        .outputPort (outputPort),
        .outputPWM  (outputPWM)
    );
    
    initial begin
        clk <= 0;
        rst <= 1;
        inputPort <= 0;
        ADC0 <= 0;
        ADC1 <= 0;
        ADC2 <= 0;
        #40 rst = 0;
        #350 inputPort[5] = ~inputPort[5];
        #350 inputPort[5] = ~inputPort[5];
    end
    always #10 clk <= ~clk;
    
    
endmodule