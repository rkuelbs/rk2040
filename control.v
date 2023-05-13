`timescale 1ns / 1ps

module control(
    input [5:0] opcode,
    input [4:0] shiftIn,
    input immSelect,
    output reg [4:0] shiftOut,
    output reg store,
    output reg load,
    output reg push,
    output reg pop,
    output reg reti,
    output reg noFlush,
    output reg shiftReg,
    output reg branch,
    output reg [2:0] branchMode,
    output reg [3:0] aluOp,
    output reg addCalcSelectA
    );
    
    parameter R_TYPE_OP = 2'b00;
    parameter MEMORY_OP = 2'b10;
    parameter BRANCH_OP = 2'b01;
    parameter BRANCH_WITHOUT_FLUSH = 2'b11;
    
    parameter LOAD = 4'b0000;
    parameter STORE = 4'b0001;
    parameter SHIFT_REG = 4'b0100;
    parameter PUSH = 4'b0011;
    parameter POP = 4'b0010;
    parameter RETI = 4'b0111;

    always @(*) begin
        case (opcode[5:4])
        R_TYPE_OP: begin
            aluOp <= opcode[3:0];
            store <= 1'b0;
            load <= 1'b0;
            push <= 1'b0;
            pop <= 1'b0;
            branchMode <= 3'b0;
            shiftReg <= 1'b0;
            shiftOut <= (immSelect) ? 5'b0 : shiftIn;
            branch <= 0;
            addCalcSelectA <= 0;
            reti <= 0;
            end
        MEMORY_OP: begin
            aluOp <= 4'b0;
            
            branch <= 0;
            addCalcSelectA <= 1'b0; // do not send pcInc to addCalc
            case (opcode[3:0])
            LOAD: begin
                branchMode <= 3'b0;
                load <= 1'b1;
                store <= 1'b0;
                push <= 1'b0;
                pop <= 1'b0;
                shiftReg <= 1'b0;
                shiftOut <= 5'b0;
                reti <= 0;
            end
            STORE: begin
                branchMode <= 3'b0;
                load <= 1'b0;
                store <= 1'b1;
                push <= 1'b0;
                pop <= 1'b0;
                shiftReg <= 1'b0;
                shiftOut <= 5'b0;
                reti <= 0;
            end
            SHIFT_REG: begin
                branchMode <= 3'b0;
                load <= 1'b0;
                store <= 1'b0;
                push <= 1'b0;
                pop <= 1'b0;
                shiftReg <= 1'b1;
                shiftOut <= {shiftIn[4], 4'b0};
                reti <= 0;
            end
            PUSH: begin
                branchMode <= 3'b0;
                load <= 1'b0;
                store <= 1'b0;
                push <= 1'b1;
                pop <= 1'b0;
                shiftReg <= 1'b0;
                shiftOut <= 5'b0;
                reti <= 0;
            end
            POP: begin
                branchMode <= 3'b0;
                load <= 1'b1;
                store <= 1'b0;
                push <= 1'b0;
                pop <= 1'b1;
                shiftReg <= 1'b0;
                shiftOut <= 5'b0;
                reti <= 0;
            end
            RETI: begin
                aluOp <= 4'b0;
                branchMode <= opcode[2:0];
                branch <= 1'b1;
                load <= 1'b0;
                store <= 1'b0;
                push <= 1'b0;
                pop <= 1'b0;
                shiftReg <= 1'b0;
                addCalcSelectA <= 0;
                shiftOut <= 5'b0;
                reti <= 1;
            end
            default: begin
                load <= 0;
                store <= 0;
                push <= 0;
                pop <= 0;
                shiftReg <= 0;
                shiftOut <= 0;
                reti <= 0;
            end
            endcase
        end
        BRANCH_OP: begin
            aluOp <= 4'b0;
            branchMode <= opcode[2:0];
            branch <= 1'b1;
            load <= 1'b0;
            store <= 1'b0;
            push <= 1'b0;
            pop <= 1'b0;
            shiftReg <= 1'b0;
            addCalcSelectA <= opcode[3];
            shiftOut <= 5'b0;
            reti <= 0;
            noFlush <= 0;
        end
        BRANCH_WITHOUT_FLUSH: begin
            aluOp <= 4'b0;
            branchMode <= opcode[2:0];
            branch <= 1'b1;
            load <= 1'b0;
            store <= 1'b0;
            push <= 1'b0;
            pop <= 1'b0;
            shiftReg <= 1'b0;
            addCalcSelectA <= opcode[3];
            shiftOut <= 5'b0;
            reti <= 0;
            noFlush <= 1;
        end
        endcase
    end
    
endmodule


