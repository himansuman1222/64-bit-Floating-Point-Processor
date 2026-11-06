#!/usr/bin/env bash
# Run once from inside this folder:  bash push_to_github.sh
set -e
git init -q 2>/dev/null || true
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/himansuman1222/64-bit-Floating-Point-Processor.git
git add -A
git commit -m "Add 64-bit IEEE 754 floating-point processor (Verilog): ALU, memories, control unit, testbenches" || true
git pull origin main --allow-unrelated-histories --no-edit 2>/dev/null || true
git push -u origin main
