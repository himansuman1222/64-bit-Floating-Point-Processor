// Self-checking ALU testbench: compares RTL against Python golden vectors
`timescale 1ns/1ps
`include "fp64_defs.vh"
`include "vector_count.vh"
module tb_fp64_alu;
    reg  [63:0] vec [0:4*`NUM_VECTORS-1];
    reg  [63:0] a, b, exp;
    reg  [3:0]  op;
    wire [63:0] result;
    wire fz, fn, fnan, finf;
    integer i, errors, nan_ok;

    fp64_alu dut (.a(a), .b(b), .alu_op(op), .result(result),
                  .flag_zero(fz), .flag_neg(fn), .flag_nan(fnan), .flag_inf(finf));

    function is_nan(input [63:0] x);
        is_nan = (x[62:52] == 11'h7FF) && (x[51:0] != 0);
    endfunction

    initial begin
        $readmemh("sim/vectors.mem", vec);
        errors = 0;
        for (i = 0; i < `NUM_VECTORS; i = i + 1) begin
            op = vec[4*i][3:0]; a = vec[4*i+1]; b = vec[4*i+2]; exp = vec[4*i+3];
            #1;
            nan_ok = is_nan(exp) && is_nan(result);
            if (result !== exp && !nan_ok) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("FAIL vec %0d op=%0d a=%h b=%h got=%h exp=%h", i, op, a, b, result, exp);
            end
        end
        $display("--------------------------------------------");
        $display("ALU test: %0d vectors, %0d errors", `NUM_VECTORS, errors);
        if (errors == 0) $display("ALU TEST PASSED"); else $display("ALU TEST FAILED");
        $finish;
    end
endmodule
