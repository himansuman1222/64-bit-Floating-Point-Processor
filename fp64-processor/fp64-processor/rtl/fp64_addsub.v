// ---------------------------------------------------------------------------
// fp64_addsub : IEEE 754 binary64 adder / subtractor (combinational)
//   * Round-to-nearest-even (guard / round / sticky)
//   * NaN, Infinity, signed zero handled
//   * Subnormal inputs/outputs are flushed to zero (documented limitation)
// ---------------------------------------------------------------------------
`include "fp64_defs.vh"
module fp64_addsub (
    input  [63:0] a,
    input  [63:0] b,
    input         sub,      // 1 = a - b, 0 = a + b
    output reg [63:0] y
);
    reg         sa, sb, s_big, s_small;
    reg  [10:0] ea, eb, e_big, e_small;
    reg  [51:0] fa, fb;
    reg         a_nan, b_nan, a_inf, b_inf, a_zero, b_zero;
    reg  [52:0] ma, mb, mant_big, mant_small;
    reg  [62:0] key_a, key_b;
    reg  [55:0] m_big, m_small, m_sh, lost;
    reg  [56:0] sum;
    reg  [55:0] norm;
    reg  [53:0] mr;
    reg         sticky, guard, rest, lsb, up, found;
    integer     d, i, shift, e;

    always @* begin
        sa = a[63];          sb = b[63] ^ sub;
        ea = a[62:52];       eb = b[62:52];
        fa = a[51:0];        fb = b[51:0];

        a_nan  = (ea == 11'h7FF) && (fa != 0);
        b_nan  = (eb == 11'h7FF) && (fb != 0);
        a_inf  = (ea == 11'h7FF) && (fa == 0);
        b_inf  = (eb == 11'h7FF) && (fb == 0);
        a_zero = (ea == 0);          // subnormals flushed
        b_zero = (eb == 0);
        ma = a_zero ? 53'd0 : {1'b1, fa};
        mb = b_zero ? 53'd0 : {1'b1, fb};
        key_a = a_zero ? 63'd0 : {ea, fa};
        key_b = b_zero ? 63'd0 : {eb, fb};

        // defaults (avoid latches)
        y = 64'd0; sum = 0; norm = 0; mr = 0; e = 0; shift = 0; found = 0;
        m_big = 0; m_small = 0; m_sh = 0; lost = 0; sticky = 0; d = 0;
        mant_big = 0; mant_small = 0; e_big = 0; e_small = 0;
        s_big = 0; s_small = 0; guard = 0; rest = 0; lsb = 0; up = 0; i = 0;

        if (a_nan || b_nan) begin
            y = `FP64_QNAN;
        end else if (a_inf && b_inf) begin
            y = (sa == sb) ? {sa, 11'h7FF, 52'd0} : `FP64_QNAN;
        end else if (a_inf) begin
            y = {sa, 11'h7FF, 52'd0};
        end else if (b_inf) begin
            y = {sb, 11'h7FF, 52'd0};
        end else begin
            // 1) order operands by magnitude
            if (key_b > key_a) begin
                s_big = sb; e_big = eb; mant_big = mb;
                s_small = sa; e_small = ea; mant_small = ma;
            end else begin
                s_big = sa; e_big = ea; mant_big = ma;
                s_small = sb; e_small = eb; mant_small = mb;
            end

            // 2) align smaller operand (3 extra bits: guard/round/sticky)
            d = e_big - e_small;
            m_big   = {mant_big, 3'b000};
            m_small = {mant_small, 3'b000};
            if (d >= 56) begin
                m_sh   = 56'd0;
                sticky = (m_small != 0);
            end else begin
                m_sh   = m_small >> d;
                lost   = m_small << (56 - d);
                sticky = (lost != 0);
            end
            m_sh = m_sh | {55'd0, sticky};

            // 3) add or subtract magnitudes
            if (s_big == s_small) sum = {1'b0, m_big} + {1'b0, m_sh};
            else                  sum = {1'b0, m_big} - {1'b0, m_sh};

            // 4) normalise
            e = e_big;
            if (sum == 0) begin
                y = {(a_zero & b_zero) ? (sa & sb) : 1'b0, 63'd0};
            end else begin
                if (sum[56]) begin
                    norm    = sum[56:1];
                    norm[0] = norm[0] | sum[0];
                    e       = e + 1;
                end else begin
                    found = 0; shift = 0;
                    for (i = 55; i >= 0; i = i - 1)
                        if (!found && sum[i]) begin found = 1; shift = 55 - i; end
                    norm = sum[55:0] << shift;
                    e    = e - shift;
                end

                // 5) round to nearest even
                lsb   = norm[3];
                guard = norm[2];
                rest  = norm[1] | norm[0];
                up    = guard & (rest | lsb);
                mr    = {1'b0, norm[55:3]} + up;
                if (mr[53]) begin mr = mr >> 1; e = e + 1; end

                // 6) pack
                if (e >= 2047)      y = {s_big, 11'h7FF, 52'd0};   // overflow -> Inf
                else if (e <= 0)    y = {s_big, 63'd0};            // underflow -> 0
                else                y = {s_big, e[10:0], mr[51:0]};
            end
        end
    end
endmodule
