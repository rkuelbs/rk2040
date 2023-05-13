`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2023 09:24:44 AM
// Design Name: 
// Module Name: interruptHandler
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

// FSM to provide interrupt instructions
// When interrupt is detected, if next instruction is not a pop or branch, pc should be saved to interrupt return address register
// and branch should take place to ISR address

//cycle 1 -- stall pc and push return address register
//cycle 2 -- store (pc) to return address register (use mux to replace pcInt in IR with pc)
//cycle 3 



module interruptHandler #(
    // STATE DEFINITIONS
    parameter INT_READY = 0,  // if interruptnow
    parameter INT_BRANCHING_1 = 1, // 
    parameter INT_BRANCHING_2 = 2,
    parameter INT_BRANCHING_3 = 3,
    parameter INT_BRANCHING_4 = 4,
    parameter INT_BRANCHING_5 = 5,
    parameter INT_RETURN_1 = 6
    )(
    input clk,
    input rst,
    input reti1,
    input branch1,
    input branch2,
    input [5:0] opcode0,
    input [7:0] interruptSet,
    input [7:0] interruptMask,
    output reg interruptBranching, // sets during branch to override pipeline flush
    output reg stallPC,
    output reg [23:0] interruptInstruction
    );
    
    reg [7:0] interruptRequest; //interrupts requested or currently being handled
    reg [7:0] interruptActive; // interrupts currently being handled (may be multiple if nested)
    reg [2:0] interruptState;  // state of interrupt calling/returning FSM
    wire [7:0] interruptPending; //interrupt requests not yet handled
    reg [2:0] nextState;
    wire interruptAvailable; // set if next instruction is not a branch or pop operation
    reg [9:0] ISRaddress;
    reg [7:0] interruptClear;
    wire interruptNow;
    
    assign interruptPending = (interruptRequest ^ interruptActive);
    assign interruptNow = (interruptPending > interruptActive);
    assign interruptAvailable = ((opcode0[5:4] != 2'b01) && (opcode0 != 6'b100010) && ~branch1 && ~branch2);
    
    always @(*) begin // Set and mask interrupt requests
        interruptRequest <= ((interruptRequest | interruptSet) & interruptMask & ~interruptClear);
    end
    
    integer currentInterrupt;
    
    always @(*) begin
        case (interruptState)
            INT_READY: begin
                interruptClear <= 0;
                interruptBranching <= 0;
                if (reti1) begin
                    stallPC <= 0;
                    interruptInstruction <= 24'h0203EE; //increment SP
                    nextState <= INT_RETURN_1;
                end
                else if (interruptAvailable && interruptNow) begin
                    stallPC <= 1;
                    interruptInstruction <= 24'h8C0ECE; // push return address register (r12)
                    nextState <= INT_BRANCHING_1;
                end
                else begin
                    stallPC <= 0;
                    interruptInstruction <= 24'b0;
                    nextState <= INT_READY;
                end            
            end
            INT_BRANCHING_1: begin
                if (interruptPending[7]) begin // select interrupt to handle
                    currentInterrupt = 7;
                    ISRaddress <= 10'd988;
                end else if (interruptPending[6]) begin
                    currentInterrupt = 6;
                    ISRaddress <= 10'd991;
                end else if (interruptPending[5]) begin
                    currentInterrupt = 5;
                    ISRaddress <= 10'd994;
                end else if (interruptPending[4]) begin
                    currentInterrupt = 4;
                    ISRaddress <= 10'd997;
                end else if (interruptPending[3]) begin
                    currentInterrupt = 3;
                    ISRaddress <= 10'd1000;
                end else if (interruptPending[2]) begin
                    currentInterrupt = 2;
                    ISRaddress <= 10'd1003;
                end else if (interruptPending[1]) begin
                    currentInterrupt = 1;
                    ISRaddress <= 10'd1006;
                end else if (interruptPending[0]) begin
                    currentInterrupt = 0;
                    ISRaddress <= 10'd1009;
                end
                interruptInstruction <= 24'h8C0EBE; // push r11
                nextState <= INT_BRANCHING_2;
            end
            INT_BRANCHING_2: begin
                interruptInstruction <= {7'b1000001, ISRaddress[8:0], 8'h0B};// load r11, r0(ISRaddress[8:0])
                interruptActive[currentInterrupt] <= 1'b1;
                nextState <= INT_BRANCHING_3;
            end            
            INT_BRANCHING_3: begin //state to branch to ISR address and save return address
                interruptInstruction <= 24'h5C00BC; // jump to r11 and store link in r12
                nextState <= INT_BRANCHING_4;
            end
            INT_BRANCHING_4: begin // state to block new interrupts for a cycle
                interruptInstruction <= 24'h0203EE; //INCREMENT SP
                nextState <= INT_BRANCHING_5;
            end
            INT_BRANCHING_5: begin
                interruptInstruction <= 24'h8800eb; //POP 11
                interruptBranching <= 1;
                stallPC <= 0; // (unstall PC so jump can take place)
                nextState <= INT_READY;
            end
            INT_RETURN_1: begin
                interruptInstruction <= 24'h8800EC; // pop return address
                nextState <= INT_READY;
                if (interruptActive[7]) interruptClear <= 8'd128;
                else if (interruptActive[6]) interruptClear <= 8'd64;
                else if (interruptActive[5]) interruptClear <= 8'd32;
                else if (interruptActive[4]) interruptClear <= 8'd16;
                else if (interruptActive[3]) interruptClear <= 8'd8;
                else if (interruptActive[2]) interruptClear <= 8'd4;
                else if (interruptActive[1]) interruptClear <= 8'd2;
                else if (interruptActive[0]) interruptClear <= 8'd1;
            end
        endcase
    end
    
    always @(posedge clk) begin
        if (rst) begin
            ISRaddress <= 0;
            interruptActive <= 8'b0;
            interruptState <= 0;
            interruptClear <= 0;
        end
        else begin
            interruptActive <= (interruptActive & ~interruptClear);
            interruptState <= nextState;
        end
        
    end
    
endmodule