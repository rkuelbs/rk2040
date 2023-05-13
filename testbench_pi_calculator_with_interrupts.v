`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2023 01:51:25 PM
// Design Name: 
// Module Name: testbench_pi_calculator_with_interrupts
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


module testbench_pi_calculator_with_interrupts(

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
