`timescale 1ns / 1ps

module RK2040(
    input clk,
    input rst,
    input [23:0] inputPort,
    input [7:0] ADC0,
    input [7:0] ADC1,
    input [7:0] ADC2,
    output [23:0] outputPort,
    output [3:0] outputPWM
    );
    
    parameter PROGRAM = 1;  // parameter to choose program to load into instruction memory
    
    wire addCalcSelectA1, addCalcSelectA2;
    wire branch1, branch2, branch3;
    wire branchFail;
    wire branchNow;
    wire bypassAddCalcA1, bypassAddCalcA2;
    wire dataMemWE;
    wire equal;
    wire fwdOneStageA1, fwdOneStageA2, fwdOneStageB1, fwdOneStageB2;
    wire fwdTwoStagesA1, fwdTwoStagesB1, fwdThreeStagesA1, fwdThreeStagesB1;
    wire immSelect1;
    wire interruptBranching;
    wire irEnable, irReset;
    wire lessThan;
    wire load1, load2, load3;
    wire noFlush1, noFlush2;
    wire pcEnable;
    wire pop1, pop2, pop3, pop4;
    wire push1, push2, push3, push4;
    wire reti1, reti2;
    wire shiftReg1, shiftReg2;
    wire store1, store2, store3, store4;
    wire spr12enable;
    wire spr12reset;
    wire stall, stallPC;
    wire [2:0] branchMode1, branchMode2;
    wire [3:0] aluOp1, aluOp2, aluOp3;
    wire [3:0] RA1;
    wire [3:0] RB1a, RB1b;
    wire [3:0] RT1, RT2a, RT2b, RT3, RT4;
    wire [4:0] shift1a, shift1b, shift2;
    wire [5:0] opcode;
    wire [7:0] interruptMask, interruptSet;
    wire [9:0] addCalcInputA, addCalcInputB;
    wire [9:0] address2, address3a, address3b, address4;
    wire [8:0] immediate1, immediate2;
    wire [8:0] pcInc0, pcInc1, pcInc2, pcInc3;
    wire [8:0] pc, pcNext;
    wire [23:0] A1a, A1b, A2a, A2b, A3, A4;
    wire [23:0] B1a, B1b, B1c, B2a, B2b, B2c, B3;
    wire [23:0] aluInputA, aluResult;
    wire [23:0] instruction0a, instruction0b, interruptInst;
    wire [23:0] memReadData;
    wire [23:0] result3, result4;
    wire [23:0] storeData;
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                              STAGE ZERO                                                              //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    assign pcInc0 = (interruptInst[23:20]) ? pc : (pc + 1); //increment program counter - use unincremented on interrupt to save return address
    assign pcNext = (branchNow) ? address2[8:0] : pcInc0;
    assign pcEnable = ~(stall | stallPC);
    assign instruction0b = (interruptInst[23:16]) ? interruptInst : instruction0a;
    
    programCounter PROGRAM_COUNTER (
        .pcNext (pcNext),
        .enable (pcEnable),
        .clk    (clk),
        .rst    (rst),
        .pc     (pc)
    );
    
    instructionMemory #(
        .PROGRAM (PROGRAM))
    INSTRUCTION_MEMORY (
        .readAddr   (pc),
        .readData   (instruction0a)
    );
    
    assign irReset = (rst | (branchNow & ~noFlush2 & ~reti2 & ~interruptBranching));
    assign irEnable = ~stall;
    
    interruptEdgeDetector EDGE_DETECTOR (
        .inputPort      (inputPort[7:0]),
        .clk            (clk),
        .rst            (rst),
        .outputPort     (interruptSet)
    );
    
    interruptHandler INTERRUPT_HANDLER (
        .clk            (clk),
        .rst            (rst),
        .reti1          (reti1),
        .branch1        (branch1),
        .branch2        (branch2),
        .interruptBranching (interruptBranching),
        .opcode0        (instruction0a[23:18]),
        .interruptSet   (interruptSet),
        .interruptMask  (interruptMask),
        .stallPC        (stallPC),
        .interruptInstruction   (interruptInst)
    );
    
    instructionRegister INSTRUCTION_REGISTER (
        .instruction    (instruction0b),
        .pcInc0         (pcInc0),
        .clk            (clk),
        .rst            (irReset),
        .enable         (irEnable),
        .pcInc1         (pcInc1),
        .opcode         (opcode),
        .immFlag        (immSelect1),
        .RA             (RA1),
        .RB             (RB1a),
        .immediate      (immediate1),
        .RT             (RT1),
        .shift          (shift1a)
    );
    
           
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                              STAGE ONE                                                               //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    assign RB1b = (store1) ? RT1 : RB1a;                                            // mux to load RT from register file for store operation
    assign A1b = (fwdTwoStagesA1) ? result3 : (fwdThreeStagesA1) ? result4 : A1a;   // forwarding mux to forward A from 2 instructions before
    assign B1c = (fwdTwoStagesB1) ? result3 : (fwdThreeStagesB1) ? result4 : B1b;   // forwarding mux to forward B from 2 instructions before
    assign B1b = (immSelect1) ? {{15{immediate1[8]}}, immediate1} : B1a;            // mux to replace B with immediate if immediate bit is set
    
    control CONTROL (
        .opcode         (opcode),
        .shiftIn        (shift1a),
        .immSelect      (immSelect1),
        .shiftOut       (shift1b),
        .store          (store1),
        .load           (load1),
        .push           (push1),
        .pop            (pop1),
        .reti           (reti1),
        .noFlush        (noFlush1),
        .shiftReg       (shiftReg1),
        .branch         (branch1),
        .branchMode     (branchMode1),
        .aluOp          (aluOp1),
        .addCalcSelectA (addCalcSelectA1)
    );
    
    registerFile REGISTER_FILE (
        .readAddrA      (RA1),
        .readAddrB      (RB1b),
        .writeAddr      (RT4),
        .writeData      (result4),
        .clk            (clk),
        .rst            (rst),
        .outputPort     (outputPort),
        .A              (A1a),
        .B              (B1a)
    );
    
    forwardingLogic FORWARDING_LOGIC (
        .RA             (RA1),
        .RB             (RB1b),
        .RT2            (RT2b),
        .RT3            (RT3),
        .RT4            (RT4),
        .immSelect      (immSelect1),
        .load           (load1),
        .store          (store1),
        .addCalcSelectA (addCalcSelectA1),
        .branch         (branch1),
        .fwdA1          (fwdOneStageA1),
        .fwdA2          (fwdTwoStagesA1),
        .fwdA3          (fwdThreeStagesA1),
        .fwdB1          (fwdOneStageB1),
        .fwdB2          (fwdTwoStagesB1),
        .fwdB3          (fwdThreeStagesB1),
        .stall          (stall),
        .bypassAddCalcA (bypassAddCalcA1)
    );
    
    assign spr12reset = (rst | (branchNow & ~noFlush2 & ~reti2 & ~interruptBranching) | stall);
    assign spr12enable = 1;
    
    registerStage1_2 REGISTER_STAGE_1_2 (
    .clk                (clk),
    .rst                (spr12reset),
    .enable             (spr12enable),
    .addCalcSelectA1    (addCalcSelectA1),
    .branch1            (branch1),
    .fwdOneStageA1      (fwdOneStageA1),
    .fwdOneStageB1      (fwdOneStageB1),
    .load1              (load1),
    .shiftReg1          (shiftReg1),
    .store1             (store1),
    .pop1               (pop1),
    .push1              (push1),
    .reti1              (reti1),
    .bypassAddCalcA1    (bypassAddCalcA1),
    .branchMode1        (branchMode1),
    .aluOp1             (aluOp1),
    .RT1                (RT1),
    .shift1             (shift1b),
    .immediate1         (immediate1),
    .pcInc1             (pcInc1),
    .A1                 (A1b),
    .B1                 (B1c),
    .addCalcSelectA2    (addCalcSelectA2),
    .branch2            (branch2),
    .fwdOneStageA2      (fwdOneStageA2),
    .fwdOneStageB2      (fwdOneStageB2),
    .load2              (load2),
    .shiftReg2          (shiftReg2),
    .store2             (store2),
    .pop2               (pop2),
    .push2              (push2),
    .reti2              (reti2),
    .bypassAddCalcA2    (bypassAddCalcA2),
    .branchMode2        (branchMode2),
    .aluOp2             (aluOp2),
    .RT2                (RT2a),
    .shift2             (shift2),
    .immediate2         (immediate2),
    .pcInc2             (pcInc2),
    .A2                 (A2a),
    .B2                 (B2a)
    );
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                              STAGE TWO                                                               //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    assign A2b = (fwdOneStageA2) ? result3 : A2a;                       // forwarding mux to forward A from previous inst
    assign B2b = (fwdOneStageB2) ? result3 : B2a;                       // forwarding mux to forward B from previous inst
    assign addCalcInputA = (addCalcSelectA2) ? {pcInc2[8], pcInc2} : A2b[9:0];       // select addCalc input A as pcInt for relative branching
    assign addCalcInputB = (store2) ? {immediate2[8], immediate2} : B2b[9:0];        // select addCalc input B as immediate for store ops
    assign RT2b = (branchFail) ? 4'b0 : RT2a;                           // dont save branch link if branching fails
    assign address2 = (bypassAddCalcA2) ? A2b : (addCalcInputA + addCalcInputB);     // address calculator
    // address calculator is bypassed if operand B is zero, preventing pipeline stalls for forwarding
    
    branchingLogic BRANCH_LOGIC (
        .branch         (branch2),
        .branchMode     (branchMode2),
        .equal          (equal),
        .lessThan       (lessThan),
        .branchNow      (branchNow),
        .branchFail     (branchFail)
    );
    
    shifter SHIFTER (
        .dataIn         (B2b),
        .shift          (shift2),
        .A              (A2b[4:0]),
        .shiftRegister  (shiftReg2),
        .dataOut        (B2c)
    );
    
    registerStage2_3 REGISTER_STAGE_2_3 (
        .clk            (clk),
        .rst            (rst),
        .branch2        (branch2),
        .load2          (load2),
        .store2         (store2),
        .pop2           (pop2),
        .push2          (push2),
        .aluOp2         (aluOp2),
        .RT2            (RT2b),
        .address2       (address2),
        .pcInc2         (pcInc2),
        .A2             (A2b),
        .B2             (B2c),
        .branch3        (branch3),
        .load3          (load3),
        .store3         (store3),
        .pop3           (pop3),
        .push3          (push3),
        .aluOp3         (aluOp3),
        .RT3            (RT3),
        .address3       (address3a),
        .pcInc3         (pcInc3),
        .A3             (A3),
        .B3             (B3)
    );
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                              STAGE THREE                                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    assign result3 = (store3) ? B3 : (branch3) ? pcInc3 : (load3) ? memReadData : aluResult;    // result multiplexer
    assign address3b = (push3) ? B3[9:0] : address3a;  // use operand B (stack pointer) as address on push instruction
    // this allows stack pointer to bypass address calculator in stage 2, allowing consecutive pushes without pipeline stall
    assign aluInputA = (push3) ? (24'b111111111111111111111101) : A3;  // set operand A to -3 on push instruction, to decrement stack pointer
    
    ALU ALU (
        .A              (aluInputA),
        .B              (B3),
        .aluOp          (aluOp3),
        .out            (aluResult),
        .equal          (equal),
        .lessThan       (lessThan)
    );
    
    registerStage3_4 REGISTER_STAGE_3_4 (
        .clk            (clk),
        .rst            (rst),
        .result3        (result3),
        .RT3            (RT3),
        .store3         (store3),
        .address3       (address3b),
        .A3             (A3),
        .push3          (push3),
        .pop3           (pop3),
        .result4        (result4),
        .RT4            (RT4),
        .store4         (store4),
        .address4       (address4),
        .A4             (A4),
        .push4          (push4),
        .pop4           (pop4)
    );
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                              STAGE FOUR                                                              //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    assign dataMemWE = (store4 || push4);
    assign storeData = (push4) ? A4 : result4;
    
    dataMemory DATA_MEMORY (
        .readAddr       (address3a),
        .writeAddr      (address4),
        .WE             (dataMemWE),
        .clk            (clk),
        .writeData      (storeData),
        .inputPort      (inputPort),
        .ADC0           (ADC0),
        .ADC1           (ADC1),
        .ADC2           (ADC2),
        .readData       (memReadData),
        .interruptMask  (interruptMask)
    );   
     
endmodule
