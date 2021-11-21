////////////////////////////////////////////////////////////////////////////////
// Engineer: lizhirui
//
// Create Date: 2021/11/21
// Function Name: clog2
//
// Description:
// This function implements c-style log2 function.
//
// Dependencies:
// <None>
//
// Revision: 1.0
//
//
// Inputs:
// value - function argument.
//
// Result:
// the least bits that can indicates 0..(value - 1).
////////////////////////////////////////////////////////////////////////////////

function[31:0] clog2; 
    input[31:0] value; 
    integer i; 
    reg [31:0] j; 
    begin 
        j = value - 1; 
        clog2 = 0; 

        for (i = 0;i < 31;i = i + 1) begin
            if(j[i]) begin
                clog2 = i + 1;
            end 
        end
    end 
endfunction 