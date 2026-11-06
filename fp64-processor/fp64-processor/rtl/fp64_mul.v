// ---------------------------------------------------------------------------
// fp64_mul : IEEE 754 binary64 multiplier (combinational)
//   Round-to-nearest-even, NaN/Inf/zero handled, subnormals flushed to zero.
// ---------------------------------------------------------------------------
`include "fp64_defs.vh"
module fp64_mul (
    input  [63:0] a,
    input  [63:0] b,
    output reg [63:0] y
);
    reg         s;
    reg  [10:0] ea, eb;
    reg  [51:0] fa, fb;
    reg         a_nan, b_nan, a_inf, b_inf, a_zero, b_zero;
    reg  [52:0] ma, mb, mant;
    reg  [105:0] p;
    reg  [53:0] mr;
    reg         guard, rest, lsb, up;
    integer     e;

    always @* begin
        s  = a[63] ^ b[63];
        ea = a[62:52]; eb = b[62:52];
        fa = a[51:0];  fb = b[51:0];
        a_nan  = (ea == 11'h7FF) && (fa != 0);
        b_nan  = (eb == 11'h7FF) && (fb != 0);
        a_inf  = (ea == 11'h7FF) && (fa == 0);
        b_inf  = (eb == 11'h7FF) && (fb == 0);
        a_zero = (ea == 0);
        b_zero = (eb == 0);
        ma = {1'b1, fa};
        mb = {1'b1, fb};

        p = 0; mant = 0; mr = 0; e = 0; guard = 0; rest = 0; lsb = 0; up = 0;
        y = 64'd0;

        if (a_nan || b_nan)                              y = `FP64_QNAN;
        else if ((a_inf && b_zero) || (b_inf && a_zero)) y = `FP64_QNAN;
        else if (a_inf || b_inf)                         y = {s, 11'h7FF, 52'd0};
        else if (a_zero || b_zero)                       y = {s, 63'd0};
        else begin
            p = ma * mb;                       // 53x53 -> 106 bits
            e = ea + eb - 1023;
            if (p[105]) begin
                mant  = p[105:53];
                guard = p[52];
                rest  = |p[51:0];
                e     = e + 1;
            end else begin
                mant  = p[104:52];
                guard = p[51];
                rest  = |p[50:0];
            end
            lsb = mant[0];
            up  = guard & (rest | lsb);
            mr  = {1'b0, mant} + up;
            if (mr[53]) begin mr = mr >> 1; e = e + 1; end

            if (e >= 2047)     y = {s, 11'h7FF, 52'd0};
            else if (e <= 0)   y = {s, 63'd0};
            else               y = {s, e[10:0], mr[51:0]};
        end
    end
endmodule
