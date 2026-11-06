// ---------------------------------------------------------------------------
// fp64_cmp : IEEE 754 binary64 comparator (a < b, a == b). NaN -> both 0.
// ---------------------------------------------------------------------------
module fp64_cmp (
    input  [63:0] a,
    input  [63:0] b,
    output reg    lt,
    output reg    eq
);
    reg a_nan, b_nan, a_zero, b_zero, sa, sb;
    reg [62:0] ka, kb;
    always @* begin
        a_nan  = (a[62:52] == 11'h7FF) && (a[51:0] != 0);
        b_nan  = (b[62:52] == 11'h7FF) && (b[51:0] != 0);
        a_zero = (a[62:52] == 0);
        b_zero = (b[62:52] == 0);
        ka = a_zero ? 63'd0 : a[62:0];
        kb = b_zero ? 63'd0 : b[62:0];
        sa = a_zero ? 1'b0 : a[63];
        sb = b_zero ? 1'b0 : b[63];
        lt = 0; eq = 0;
        if (!(a_nan || b_nan)) begin
            eq = (sa == sb) && (ka == kb);
            if (sa != sb)      lt = sa;             // negative < positive
            else if (!sa)      lt = (ka < kb);
            else               lt = (ka > kb);
        end
    end
endmodule
