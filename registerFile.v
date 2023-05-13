`timescale 1ns / 1ps

module registerFile(
    input [3:0] readAddrA,
    input [3:0] readAddrB,
    input [3:0] writeAddr,
    input [23:0] writeData,
    input clk,
    input rst,
    output [23:0] outputPort,
    output reg [23:0] A,
    output reg [23:0] B
    );
    
    parameter STACK_POINTER = 14;
    parameter OUTPUT_REG = 15;
    reg [23:0] registerFile [1:15];
    
    assign outputPort = registerFile[OUTPUT_REG];    
    
    always @(*) begin
        if (readAddrA == 0)
            A <= 0;
        else
            A <= registerFile[readAddrA];
        if (readAddrB == 0)
            B <= 0;
        else
            B <= registerFile[readAddrB];
    end
    
    integer i;
    
    always @(posedge clk) begin
        if (rst) begin
            for (i = 1; i < 14; i = i + 1)
                registerFile[i] = 0;
            registerFile[STACK_POINTER] <= 24'd964;
            registerFile[OUTPUT_REG] <= ~(24'b0);
        end
        else if (writeAddr != 0)
            registerFile[writeAddr] <= writeData;
    end
    
endmodule
