#!/usr/bin/env python3
"""Tiny two-pass assembler for the FP64 processor.
Usage: python3 sw/assembler.py programs/demo.asm programs/program.hex

Syntax (';' starts a comment, 'label:' defines a label):
  FADD/FSUB/FMUL/FAND/FOR/FXOR/FLT/FEQ  fd, fs1, fs2
  FNOT/FABS/FNEG                         fd, fs1
  FLD fd, addr          ; fd <- DMEM[addr]
  FST fs, addr          ; DMEM[addr] <- fs
  JMP label
  BEQ fs1, fs2, label   ; branch if fs1 == fs2 (FP compare)
  HALT / NOP
"""
import sys, re

OPC = dict(NOP=0x00, FADD=0x01, FSUB=0x02, FMUL=0x03, FAND=0x04, FOR=0x05,
           FXOR=0x06, FNOT=0x07, FLT=0x08, FEQ=0x09, FABS=0x0A, FNEG=0x0B,
           FLD=0x10, FST=0x11, JMP=0x12, BEQ=0x13, HALT=0x1F)
RRR = {'FADD','FSUB','FMUL','FAND','FOR','FXOR','FLT','FEQ'}
RR  = {'FNOT','FABS','FNEG'}

def reg(tok):
    m = re.fullmatch(r'[fF](\d+)', tok.strip())
    if not m or int(m.group(1)) > 31: raise ValueError(f"bad register '{tok}'")
    return int(m.group(1))

def enc(op, rd=0, rs1=0, rs2=0, imm=0):
    return (OPC[op] << 27) | (rd << 22) | (rs1 << 17) | (rs2 << 12) | (imm & 0xFFF)

def assemble(src):
    lines, labels, pc = [], {}, 0
    for raw in src.splitlines():
        line = raw.split(';')[0].strip()
        if not line: continue
        while ':' in line:
            lab, line = line.split(':', 1)
            labels[lab.strip()] = pc
            line = line.strip()
        if line:
            lines.append((pc, line)); pc += 1
    words = []
    for pc, line in lines:
        parts = line.replace(',', ' ').split()
        op, a = parts[0].upper(), parts[1:]
        val = lambda t: labels[t] if t in labels else int(t, 0)
        if op in RRR:   w = enc(op, reg(a[0]), reg(a[1]), reg(a[2]))
        elif op in RR:  w = enc(op, reg(a[0]), reg(a[1]))
        elif op == 'FLD': w = enc(op, rd=reg(a[0]), imm=val(a[1]))
        elif op == 'FST': w = enc(op, rs2=reg(a[0]), imm=val(a[1]))
        elif op == 'JMP': w = enc(op, imm=val(a[0]))
        elif op == 'BEQ': w = enc(op, rs1=reg(a[0]), rs2=reg(a[1]), imm=val(a[2]))
        elif op in ('NOP', 'HALT'): w = enc(op)
        else: raise ValueError(f"unknown mnemonic {op}")
        words.append(w)
    return words

if __name__ == '__main__':
    src, dst = sys.argv[1], sys.argv[2]
    w = assemble(open(src).read())
    padded = w + [0] * (256 - len(w))      # pad with NOPs to full ROM depth
    open(dst, 'w').write("\n".join(f"{x:08x}" for x in padded) + "\n")
    print(f"assembled {len(w)} instructions -> {dst}")
