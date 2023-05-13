`timescale 1ns / 1ps

module forwardingLogic(
    input [3:0] RA,
    input [3:0] RB,
    input [3:0] RT2,
    input [3:0] RT3,
    input [3:0] RT4,
    input immSelect,
    input load,
    input store,
    input addCalcSelectA,
    input branch,
    output fwdA1,
    output fwdA2,
    output fwdA3,
    output fwdB1,
    output fwdB2,
    output fwdB3,
    output bypassAddCalcA,
    output stall
    );
    
    // A should always be forwarded on RA/RT match and RA != 0
    // A forwarding 1 cycle should cause stall if ((load | store) & ~addCalcSelectA)
    
    // B should be forwarded if !(immSelect1) and RB/RT match and RB !=0
    // B forwarding 1 cycle should cause stall on (branch1 | load1)
    
    //A can be forwarded straight to address in case of memory operation (load with RB=0 and ~immSelect)
    
    wire stallA, stallB;
    
    assign stall = (stallA | stallB);
    assign stallA = (fwdA1 & ~addCalcSelectA & ((load && (RB || immSelect)) | store));
    assign stallB = (fwdB1 & (branch | load));
    assign fwdA3 = (|RA & (RA == RT4));
    assign fwdA2 = (|RA & (RA == RT3));
    assign fwdA1 = (|RA & (RA == RT2));
    assign fwdB3 = (~immSelect & |RB & (RB == RT4));
    assign fwdB2 = (~immSelect & |RB & (RB == RT3));
    assign fwdB1 = (~immSelect & |RB & (RB == RT2));
    assign bypassAddCalcA = (load && ~RB && ~immSelect);
    
endmodule
