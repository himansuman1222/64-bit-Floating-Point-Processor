#!/usr/bin/env python3
"""Generate ALU test vectors (golden model = Python's IEEE 754 double, RNE).
Output (sim/vectors.mem): 4 x 64-bit hex words per vector: op, a, b, expected.
Subnormal inputs/results are skipped (the RTL flushes subnormals to zero)."""
import random, struct, math, sys

OPS = dict(ADD=0, SUB=1, MUL=2, AND=3, OR=4, XOR=5, NOT=6, LT=7, EQ=8, ABS=9, NEG=10)
MIN_NORMAL = 2.2250738585072014e-308
QNAN = 0x7FF8000000000000
ONE  = 0x3FF0000000000000

def b2f(x): return struct.unpack('>d', struct.pack('>Q', x))[0]
def f2b(x): return struct.unpack('>Q', struct.pack('>d', x))[0]
def ok(x):  return x == 0 or math.isinf(x) or math.isnan(x) or abs(x) >= MIN_NORMAL

def golden(op, a, b):
    fa, fb = b2f(a), b2f(b)
    if op in ('AND', 'OR', 'XOR', 'NOT'):
        r = {'AND': a & b, 'OR': a | b, 'XOR': a ^ b, 'NOT': ~a & (2**64 - 1)}[op]
        return r
    if op == 'ABS': return a & 0x7FFFFFFFFFFFFFFF
    if op == 'NEG': return a ^ (1 << 63)
    if op == 'LT':  return ONE if fa < fb else 0
    if op == 'EQ':  return ONE if fa == fb else 0
    with_nan = math.isnan(fa) or math.isnan(fb)
    if with_nan: return QNAN
    try:
        if op == 'ADD': r = fa + fb
        elif op == 'SUB': r = fa - fb
        else: r = fa * fb
    except OverflowError:
        return None
    if math.isnan(r): return QNAN
    if not ok(r): return None
    return f2b(r)

def rnd_normal(rng):
    s = rng.getrandbits(1)
    e = rng.randint(1023 - 60, 1023 + 60)
    return (s << 63) | (e << 52) | rng.getrandbits(52)

def main(n=4000, seed=1):
    rng = random.Random(seed)
    corner = [0, 1 << 63, ONE, f2b(-1.0), f2b(2.0), f2b(0.5), f2b(3.14159265358979),
              0x7FF0000000000000, 0xFFF0000000000000, QNAN,
              0x7FEFFFFFFFFFFFFF, 0x0010000000000000]
    vecs = []
    for op in OPS:
        for a in corner:
            for b in corner:
                vecs.append((op, a, b))
    for _ in range(n):
        op = rng.choice(list(OPS))
        a, b = rnd_normal(rng), rnd_normal(rng)
        mode = rng.random()
        if mode < 0.25:  # near-equal operands => heavy cancellation
            b = (a & ~0xFFF) | rng.getrandbits(12); b ^= (rng.getrandbits(1) << 63)
        elif mode < 0.4: # close exponents
            b = (b & ~(0x7FF << 52)) | (((a >> 52) & 0x7FF) + rng.randint(-3, 3) & 0x7FF) << 52
        vecs.append((op, a, b))
    out, cnt = [], 0
    for op, a, b in vecs:
        if op in ('ADD','SUB','MUL','LT','EQ'):
            if (a >> 52) & 0x7FF == 0 and a & ((1<<52)-1): continue   # subnormal input
            if (b >> 52) & 0x7FF == 0 and b & ((1<<52)-1): continue
        exp = golden(op, a, b)
        if exp is None: continue
        out.append(f"{OPS[op]:016x}\n{a:016x}\n{b:016x}\n{exp:016x}")
        cnt += 1
    open('sim/vectors.mem', 'w').write("\n".join(out) + "\n")
    open('sim/vector_count.vh', 'w').write(f"`define NUM_VECTORS {cnt}\n")
    print(f"generated {cnt} vectors")

if __name__ == '__main__':
    main()
