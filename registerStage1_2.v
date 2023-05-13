`timescale 1ns / 1ps

module registerStage1_2 (
    input clk,
    input rst,
    input enable,
    input addCalcSelectA1,
    input branch1,
    input fwdOneStageA1,
    input fwdOneStageB1,
    input load1,
    input shiftReg1,
    input store1,
    input pop1,
    input push1,
    input reti1,
    input noFlush1,
    input bypassAddCalcA1,
    input [2:0] branchMode1,
    input [3:0] aluOp1,
    input [3:0] RT1,
    input [4:0] shift1,
    input [8:0] immediate1,
    input [8:0] pcInc1,
    input [23:0] A1,
    input [23:0] B1,
    output reg addCalcSelectA2,
    output reg branch2,
    output reg fwdOneStageA2,
    output reg fwdOneStageB2,
    output reg load2,
    output reg shiftReg2,
    output reg store2,
    output reg pop2,
    output reg push2,
    output reg reti2,
    output reg noFlush2,
    output reg bypassAddCalcA2,
    output reg [2:0] branchMode2,
    output reg [3:0] aluOp2,
    output reg [3:0] RT2,
    output reg [4:0] shift2,
    output reg [8:0] immediate2,
    output reg [8:0] pcInc2,
    output reg [23:0] A2,
    output reg [23:0] B2
    );
    
    always @(posedge clk) begin
        if (rst) begin
            addCalcSelectA2 <= 0;
            branch2 <= 0;
            fwdOneStageA2 <= 0;
            fwdOneStageB2 <= 0;
            load2 <= 0;
            shiftReg2 <= 0;
            store2 <= 0;
            branchMode2 <= 0;
            aluOp2 <= 0;
            RT2 <= 0;
            shift2 <= 0;
            immediate2 <= 0;
            pcInc2 <= 0;
            A2 <= 0;
            B2 <= 0;
            pop2 <= 0;
            push2 <= 0;
            reti2 <= 0;
            noFlush2 <= 0;
            bypassAddCalcA2 <= 0;
        end
        else if (enable) begin
            addCalcSelectA2 <= addCalcSelectA1;
            branch2 <= branch1;
            fwdOneStageA2 <= fwdOneStageA1;
            fwdOneStageB2 <= fwdOneStageB1;
            load2 <= load1;
            shiftReg2 <= shiftReg1;
            store2 <= store1;
            branchMode2 <= branchMode1;
            aluOp2 <= aluOp1;
            RT2 <= RT1;
            shift2 <= shift1;
            immediate2 <= immediate1;
            pcInc2 <= pcInc1;
            A2 <= A1;
            B2 <= B1;
            pop2 <= pop1;
            push2 <= push1;
            reti2 <= reti1;
            noFlush2 <= noFlush1;
            bypassAddCalcA2 <= bypassAddCalcA1;
        end
    end
    
endmodule
