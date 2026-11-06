// ---------------------------------------------------------------------------
// fp64_alu : floating-point arithmetic + logical operations
//   Arithmetic : ADD, SUB, MUL, ABS, NEG, LT, EQ   (IEEE 754 binary64)
//   Logical    : AND, OR, XOR, NOT                 (bit-wise on the 64-bit word)
//   Flags      : zero, negative, nan, inf
// ---------------------------------------------------------------------------
`include "fp64_defs.vh"
module fp64_alu (
    input      [63:0] a,
    input      [63:0] b,
    input      [3:0]  alu_op,
    output reg [63:0] result,
    output            flag_zero,
    output            flag_neg,
    output            flag_nan,
    output            flag_inf
);
    wire [63:0] add_y, mul_y;
    wire        lt, eq;

    fp64_addsub u_addsub (.a(a), .b(b), .sub(alu_op == `ALU_SUB), .y(add_y));
    fp64_mul    u_mul    (.a(a), .b(b), .y(mul_y));
    fp64_cmp    u_cmp    (.a(a), .b(b), .lt(lt), .eq(eq));

    always @* begin
        case (alu_op)
            `ALU_ADD, `ALU_SUB: result = add_y;
            `ALU_MUL: result = mul_y;
            `ALU_AND: result = a & b;
            `ALU_OR : result = a | b;
            `ALU_XOR: result = a ^ b;
            `ALU_NOT: result = ~a;
            `ALU_LT : result = lt ? `FP64_ONE : `FP64_ZERO;
            `ALU_EQ : result = eq ? `FP64_ONE : `FP64_ZERO;
            `ALU_ABS: result = {1'b0, a[62:0]};
            `ALU_NEG: result = {~a[63], a[62:0]};
            default : result = 64'd0;
        endcase
    end

    assign flag_zero = (result[62:0] == 63'd0);
    assign flag_neg  = result[63];
    assign flag_nan  = (result[62:52] == 11'h7FF) && (result[51:0] != 0);
    assign flag_inf  = (result[62:52] == 11'h7FF) && (result[51:0] == 0);
endmodule
