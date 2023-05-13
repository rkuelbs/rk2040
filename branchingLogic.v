`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2023 10:04:51 PM
// Design Name: 
// Module Name: branchingLogic
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

module branchingLogic(
    input branch,
    input [2:0] branchMode,
    input equal,
    input lessThan,
    output branchNow,
    output branchFail
    );
    
    // Branch Mode bits: [0] branch on equal, [1] branch on less than, [2] branch on greater than
    
    wire isGreater, isLess;
    wire [2:0] compare;
    
    assign isGreater = ~(equal | lessThan);
    assign isLess = (lessThan & ~equal);
    assign compare = {isGreater, isLess, equal};
    assign branchNow = branch & |(compare & branchMode);
    assign branchFail = branch ^ branchNow;
    
endmodule
