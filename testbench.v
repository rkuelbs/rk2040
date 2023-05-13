`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2023 09:24:56 PM
// Design Name: 
// Module Name: testbench_piCalculator_with_interrupts_P1_P2
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



// THIS TESTBENCH LOADS A PROGRAM THAT CALCULATES DIGITS OF PI USING A SPIGOT ALGORITHM AND STORES THEM IN 
// MEMORY ADDRESSES 1,2,3...
//
// INTERRUPT 5 IS TRIGGERED BY THE FALLING EDGE OF INPUTPORT[5], AND RUNS PROGRAM 2.  THIS INTERRUPT PUSHES R1
// AND R2 TO THE STACK, RUNS PROGRAM 2, STORES THE FINAL OUTPUT (55) TO MEMORY ADDRESS 0x40, AND THEN POPS R2
// AND R1 FROM THE STACK AND RETURNS.
//
// INTERRUPT 7 IS TRIGGERED BY THE FALLING EDGE OF INPUTPORT[7], AND RUNS PROGRAM 2.  THIS INTERRUPT PUSHES R1, R2, 
// AND R3 TO THE STACK, LOADS MEMORY ADDRESS 0x10 TO R1, LOADS 0x20 TO R2, ADDS R1 AND R2 AND SAVES THE OUTPUT IN R3, 
// STORES R3 TO 0x30, AND THEN POPS R3, R2, AND R1 FROM THE STACK AND RETURNS.

module testbench_piCalculator_with_interrupts_P1_P2(

    );
    
    parameter PROGRAM = 3;
    
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
        #250000 inputPort[5] = ~inputPort[5];
        #1000 inputPort[7] = ~inputPort[7];
        #250000 inputPort[5] = ~inputPort[5];  // TRIGGER INTERRUPT 5 AT ABOUT 501040 ns
        #1000 inputPort[7] = ~inputPort[7]; // TRIGGER INTERRRUPT 7 AT ABOUT 502040 ns
    end
    always #10 clk <= ~clk;
    
endmodule
